// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./Vault.sol";
import "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";
import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";

contract Portfolio_V2 is ERC20 {
    // STATE VARIABLES
    Vault public vault;
    address[] public tokenAddresses;
    uint256[] public percentageHoldings;
    address payable constant WETH = payable(0xd0A1E359811322d97991E03f863a0C30C2cF029C);
    ISwapRouter constant uniswapRouter = ISwapRouter(0xE592427A0AEce92De3Edee1F18E0157C05861564);
    uint256 public ownerFee;
    address public owner;

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
        vault = new Vault(tokenAddresses_);
        owner = owner_;
        ownerFee = ownerFee_; // Number from 0-10000 (where 10000 represents 100%)
    }

    // ------------------------------  Initalise Portfolio ----------------------------------- //

    function initialisePortfolio() public payable onlyOwner zeroTotalSupply {
        require(msg.value > 0, "Eth required");
        ethToWeth();
        uint256 _totalWethAmount = getBalance(WETH, address(this));
        for (uint256 i = 0; i < tokenAddresses.length; i++) {
            uint256 _percentageWethAmount = (_totalWethAmount *
                percentageHoldings[i]) / 100;
            uint256 numTokensAcquired = swap(
                _percentageWethAmount,
                tokenAddresses[i]
            );
            // Deposit initial holding in vault
            vault.deposit(tokenAddresses[i], numTokensAcquired);
        }
        _mint(owner, 100 * (10**decimals()));
    }

    // --------------------------------------- Swap ------------------------------------------- //

    function swap(uint256 wethAmount, address tokenAddress)
        private
        returns (uint256)
    {
        uint256 _numTokensAcquired = 0;
        if (tokenAddress == WETH) {
            _numTokensAcquired = wethAmount;
            IERC20(tokenAddress).transfer(address(vault), _numTokensAcquired);
        } else {
            // swapToken(tokenInAddress, tokenInAmount, tokenOutAddress, recipient))
            _numTokensAcquired = swapToken(WETH, wethAmount, tokenAddress, address(vault));
        }
        return _numTokensAcquired;
    }

    function ethToWeth() public payable {
        (bool sent, bytes memory data) = WETH.call{value: msg.value}("");
        require(sent, "Failed to swap Eth for Weth");
    }


    // ------------------------------ Generalised Token Swap ---------------------------------- //

    function swapToken(address tokenInAddress, uint256 tokenInAmount, address tokenOutAddress, address _recipient)
        private
        returns(uint256)
    {
        TransferHelper.safeApprove(tokenInAddress, address(uniswapRouter), tokenInAmount);
        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter
            .ExactInputSingleParams({
                tokenIn: tokenInAddress,
                tokenOut: tokenOutAddress,
                fee: 3000,
                recipient: _recipient,
                deadline: block.timestamp,
                amountIn: tokenInAmount,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });
        uint256 numTokensAcquired = uniswapRouter.exactInputSingle(params);
        return numTokensAcquired;
    }

    // ---------------------------------- Buy / Sell / Deposit ---------------------------------- //

    function buy() public payable nonZeroTotalSupply {
        ethToWeth();
        uint256 vaultValuePrior = deposit(msg.value);
        // The number of tokens to mint is determined by the formula:
        // t = (SUPPLY_b * WETH) / NAV_b
        // where:
        // t = tokens to issue
        // SUPPLY_b = total supply of tokens before the issuance
        // NAV_b = net asset value (in vault) after the deposits
        // WETH = amount of Weth deposited for issuance
        uint256 tokensToMint = (totalSupply() * msg.value) / vaultValuePrior;
        uint256 ownerTokens = (tokensToMint * ownerFee) / 10000;
        _mint(msg.sender, tokensToMint - ownerTokens);
        _mint(owner, ownerTokens);
    }

    function sell(uint256 tokensToSell) public nonZeroTotalSupply {
        require(balanceOf(msg.sender) >= tokensToSell, "Insufficient funds");
        // Get total supply before burning
        uint256 prevSupply = totalSupply();
        _burn(msg.sender, tokensToSell);
        for (uint256 i = 0; i < tokenAddresses.length; i++) {
            // How much of the token is in existence?
            uint256 assetQuantity = vault.assetQuantities(tokenAddresses[i]);
            // Withdraw holding from vault. The transfer of tokens to user is done inside the vault
            vault.withdraw(
                tokenAddresses[i],
                msg.sender,
                (assetQuantity * tokensToSell) / prevSupply
            );
        }
    }

    function deposit(uint256 _totalWethAmount) private returns (uint256) {
        uint256 vaultValuePrior = 0;
        for (uint256 i = 0; i < tokenAddresses.length; i++) {
            // Swap WETH for a different token which is transferred to the vault
            uint256 wethToSpend = (_totalWethAmount * percentageHoldings[i]) /
                100;
            uint256 numTokensAcquired = swap(wethToSpend, tokenAddresses[i]);
            // Calculate contribution of token to vault value, which = quantity of token * price of token
            vaultValuePrior +=
                (vault.assetQuantities(tokenAddresses[i]) * wethToSpend) /
                numTokensAcquired;
            // Deposit holding in vault
            vault.deposit(tokenAddresses[i], numTokensAcquired);
        }
        return vaultValuePrior;
    }

    // ----------------------------------- Misc Functions ----------------------------------- //

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

    // -------------------------------------- Modifiers -------------------------------------- //

    modifier onlyOwner() {
        require(owner == msg.sender);
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
