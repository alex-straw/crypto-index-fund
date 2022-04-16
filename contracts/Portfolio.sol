// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";
import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";

interface IWETH9 {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint256 value) external payable;
}

contract Portfolio is ERC20 {

    /*
     * Events are emitted the three main public functions
    */

    event Buy(
        address indexed _from, 
        uint256 _depositAmount, 
        uint256 _priorValueLocked,
        uint256 _tokensMinted
    );

    event RedeemAssets(
        address indexed _from, 
        uint256 _tokensBurned
    );

    event SellAssets(
        address indexed _from,
        uint256 _tokensBurned, 
        uint256 returnedEth
    );

    // -------  State ------- //
    address[] public tokenAddresses;
    uint256[] public percentageHoldings;
    address payable constant WETH = payable(0xd0A1E359811322d97991E03f863a0C30C2cF029C);
    ISwapRouter constant uniswapRouter = ISwapRouter(0xE592427A0AEce92De3Edee1F18E0157C05861564);
    uint256 public ownerFee;
    address public owner;
    mapping(address => uint256) public assetQuantities;
    
    // --------------------------  Functions  ------------------------- //
    /*
     * Create a new Portfolio token representing a set of underlying assets.
     *
     * @param  name_   the name of the Portfolio
     * @param  symbol_   the symbol for the Portfolio token
     * @param  tokenAddresses_   the addresses of the ERC20 tokens that make up the Portfolio
     * @param  percentageHoldings_   the desired percentage holding for each token specified in tokenAddresses_
     * @param  owner_   the address of the Portfolio owner
     * @param  ownerFee_   the size of the fee paid to the owner by buyers (in basis points)
     */
    constructor(
        string memory name_,
        string memory symbol_,
        address[] memory tokenAddresses_,
        uint256[] memory percentageHoldings_,
        address owner_,
        uint256 ownerFee_
    ) ERC20(name_, symbol_) {
        require(
            tokenAddresses_.length == percentageHoldings_.length,
            "Please specify the same number of token addresses as percentage holdings"
        );
        require(
            sum(percentageHoldings_) == 100,
            "Percentage holdings must sum to 100"
        );
        require(
            ownerFee >= 0 && ownerFee < 10000,
            "Owner Fee must be between 0 (0%) and 10000 (100%)"
        );
        tokenAddresses = tokenAddresses_;
        percentageHoldings = percentageHoldings_;
        owner = owner_;
        ownerFee = ownerFee_; // Number from 0-10000 (where 10000 represents 100%)

        for (uint256 i=0; i<tokenAddresses.length; i++) {
            assetQuantities[tokenAddresses[i]] = 0;
        }
    }

    // ---------------------  Initalise Portfolio --------------------- //

    function initialisePortfolio() public payable onlyOwner zeroTotalSupply {
        require(msg.value > 0, "Eth required");
        //ethToWeth();
        IWETH9(WETH).deposit{value:msg.value}();
        uint256 _totalWethAmount = getBalance(WETH, address(this));
        for (uint256 i = 0; i < tokenAddresses.length; i++) {
            uint256 _percentageWethAmount = (_totalWethAmount * percentageHoldings[i]) / 100;
            uint256 numTokensAcquired = swapIn(WETH, tokenAddresses[i], _percentageWethAmount, address(this));
            // Update assetQuantities to keep track of ERC20s held
            assetQuantities[tokenAddresses[i]] += numTokensAcquired;
        }
        _mint(owner, 100 * (10**decimals()));
    }


    // -------------------------- Buy & Deposit ----------------------- //

    /*
     * Purchase underlying assets with Eth and issue new Portfolio tokens to the buyer.
     *
     * @param  msg.value   the amount of Eth to spend
     */
    function buy() public payable nonZeroTotalSupply {
        // Convert payable amount to Weth
        IWETH9(WETH).deposit{value:msg.value}();
        // Buy tokens from uniswap and estimate priorValueLocked: This is 
        // the value of of the portfolio in terms of ETH prior to this purchase.
        uint256 priorValueLocked = deposit(msg.value);
        /*
        The number of tokens to mint, t, is determined by the formula:
        t = (SUPPLY_b * WETH) / NAV_b
        where:
        t = tokens to issue
        SUPPLY_b = total supply of tokens before the issuance
        NAV_b = net asset value (in the portfolio) after the deposits
        WETH = amount of Weth deposited for issuance
        */
        uint256 tokensToMint = (totalSupply() * msg.value) / priorValueLocked;
        uint256 ownerTokens = (tokensToMint * ownerFee) / 10000;
        _mint(msg.sender, tokensToMint - ownerTokens);
        _mint(owner, ownerTokens);

        emit Buy(msg.sender, msg.value, priorValueLocked, tokensToMint - ownerTokens);
    }

    /*
     * Spend Weth held by this contract on the tokens required by the portfolio.
     *
     * @param  _totalWethAmount   the amount of Weth to spend
     * @return                    the value of the Portfolio's holdings prior to the deposit
     */
    function deposit(uint256 _totalWethAmount) private returns (uint256) {
        uint256 priorValueLocked = 0;
        for (uint256 i = 0; i < tokenAddresses.length; i++) {
            uint256 wethToSpend = (_totalWethAmount * percentageHoldings[i]) / 100;
            uint256 numTokensAcquired = swapIn(WETH, tokenAddresses[i], wethToSpend, address(this));
            // Calculate contribution of token to Portfolio value, which = quantity of token * price of token
            priorValueLocked += (assetQuantities[tokenAddresses[i]] * wethToSpend) / numTokensAcquired;
            // Update portfolio holdings of each asset 
            assetQuantities[tokenAddresses[i]] += numTokensAcquired;
        }
        return priorValueLocked;
    }

    // -------------------- Sell & Redeem Mechanisms ------------------ //

    /*
     * Sell Portfolio holding and receive underlying assets.
     *
     * @param  tokensToSell   the number of owned tokens to sell
     */
    function redeemAssets(uint256 tokensToSell) public nonZeroTotalSupply {
        require(balanceOf(msg.sender) >= tokensToSell, "Insufficient funds");
        // Get total supply before burning tokens
        uint256 prevSupply = totalSupply();
        _burn(msg.sender, tokensToSell);
        for (uint256 i = 0; i < tokenAddresses.length; i++) {
            // How much of the underlying asset is held in the portfolio
            uint256 assetQuantity = assetQuantities[tokenAddresses[i]];
            // Withdraw holding from the portfolio
            uint256 numTokensToWithdraw = (assetQuantity * tokensToSell) / prevSupply;
            assetQuantities[tokenAddresses[i]] -= numTokensToWithdraw;
            IERC20(tokenAddresses[i]).transfer(msg.sender, numTokensToWithdraw);
        }
        emit RedeemAssets(msg.sender, tokensToSell);
    }

    /*
     * Swap Portfolio holdings on Uniswap for Weth.  Swap this Weth for Ether
     * and transfer to msg.sender.
     *
     * @param  tokensToSell   the number of owned tokens to sell
     */
    function sellAssets(uint256 tokensToSell) public nonZeroTotalSupply {
        require(balanceOf(msg.sender) >= tokensToSell, "Insufficient funds");
        // Get total supply before burning tokens
        uint256 prevSupply = totalSupply();
        _burn(msg.sender, tokensToSell);
        uint256 wethAcquired = 0;
        for (uint256 i = 0; i < tokenAddresses.length; i++) {
            // How much of the underlying asset is held in the portfolio
            uint256 assetQuantity = assetQuantities[tokenAddresses[i]];
            // Withdraw holding from the portfolio
            uint256 numTokensToWithdraw = (assetQuantity * tokensToSell) / prevSupply;            
            // Swap all the user's assets to Weth and send to the contract's address
            // Keep track of the amount of WETH acquired
            assetQuantities[tokenAddresses[i]] -= numTokensToWithdraw;

            if (tokenAddresses[i] == WETH) {
                wethAcquired += numTokensToWithdraw;
            } else {
                wethAcquired += callUniswap(tokenAddresses[i], WETH, numTokensToWithdraw, address(this));
            }
        }
        // Swap Weth for ETH by calling the IWETH9 withdraw function.
        IWETH9(WETH).withdraw(wethAcquired);
        // Transfer all at once to reduce gas fees.
        payable(msg.sender).transfer(wethAcquired);

        emit SellAssets(msg.sender, tokensToSell, wethAcquired);
    }

    // --------------------------- Swap tokens ------------------------ //

    function swapIn(address tokenIn, address tokenOut, uint256 tokenInAmount, address recipient)
        private
        returns (uint256)
    {
        uint256 _numTokensAcquired = 0;
        if (tokenOut == WETH) {
            _numTokensAcquired = tokenInAmount;
        } else {
            // Use UniSwap to get the desired token by sending it WETH
            _numTokensAcquired = callUniswap(tokenIn, tokenOut, tokenInAmount, recipient);
        }
        return _numTokensAcquired;
    }

    function callUniswap(address _tokenIn, address _tokenOut, uint256 _tokenInAmount, address _recipient)
        private
        returns (uint256)
    {
        TransferHelper.safeApprove(_tokenIn, address(uniswapRouter), _tokenInAmount);
        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter
            .ExactInputSingleParams({
                tokenIn: _tokenIn,
                tokenOut: _tokenOut,
                fee: 3000,
                recipient: _recipient,
                deadline: block.timestamp,
                amountIn: _tokenInAmount,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });
        uint256 numTokensAcquired = uniswapRouter.exactInputSingle(params);
        return numTokensAcquired;
    }

    // ------------------------- Misc Functions ----------------------- //

    function sum(uint256[] memory list) private pure returns (uint256) {
        uint256 s = 0;
        for (uint256 i = 0; i < list.length; i++) {
            s += list[i];
        }
        return s;
    }

    function getBalance(address _tokenAddress, address _address)
        private
        view
        returns (uint256)
    {
        return IERC20(_tokenAddress).balanceOf(_address);
    }

    // Receive --> Necessary for the contract to transfer WETH to ETH
    receive() external payable {}

    // --------------------------- Modifiers -------------------------- //

    modifier onlyOwner() {
        require(
            owner == msg.sender,
            "Only the owner can initialise the Portfolio."
        );
        _;
    }

    modifier nonZeroTotalSupply() {
        require(
            totalSupply() > 0,
            "Total supply is 0.  Contract must be initialised."
        );
        _;
    }

    modifier zeroTotalSupply() {
        require(
            totalSupply() == 0,
            "Total supply is greater than 0 and does not need to be initialised."
        );
        _;
    }
}
