pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./Vault.sol";


// ------------------------------ Temporary Interface for Fake Uniswap ------------------------------ // 

interface IfakeUniswap {
    function swapWethForToken(address _tokenToBuy, address _recipient, uint256 _amountWethToSell) external returns(uint256);
    function increment() external;
}

// -------------------------------------------------------------------------------------------------- // 

contract portfolio_V2 is ERC20 { 
    Vault public vault;
    address[] public tokenAddresses;
    uint256[] public percentageHoldings;
    address payable WETH = payable(0xc778417E063141139Fce010982780140Aa0cD5Ab);
    address constant fakeUniswap = 0xFbd8c741Be3E6A0260AEa0875cd8801D3ACB0dA1; // Rinkeby

    uint256 public _totalWethAmount;
    uint256 public _percentageWethAmount;

    address public Owner;
    bool initialised = false;

    constructor(
        string memory name_,
        string memory symbol_,
        address[] memory tokenAddresses_,
        uint256[] memory percentageHoldings_
    ) payable ERC20(name_, symbol_) {
        require(
            tokenAddresses_.length == percentageHoldings_.length,
            "Please specify the same number of token addresses as percentage holdings"
        );
        require(
            sum(percentageHoldings_) == 100,
            "Percentage holdings must sum to 100"
        );
        require(msg.value > 0, "Eth required");
        tokenAddresses = tokenAddresses_;
        percentageHoldings = percentageHoldings_;
        vault = new Vault(tokenAddresses_);            // Deposit holding in vault
        ethToWeth();
        Owner = msg.sender;
    }

    // ------------------------------  Initalise Portfolio ----------------------------------- //

    function initialisePortfolio() onlyOwner notInitialised public {
        _totalWethAmount = getBalance(0xc778417E063141139Fce010982780140Aa0cD5Ab, address(this));
        for (uint i=0; i < tokenAddresses.length; i++) {
            _percentageWethAmount = _totalWethAmount * percentageHoldings[i] / 100;
            uint256 numTokensAcquired = swap(_percentageWethAmount, tokenAddresses[i]);
            _mint(Owner, 100 * (10**decimals())); 
            initialised = true;
            // Deposit initial holding in vault
            vault.deposit(tokenAddresses[i], Owner, numTokensAcquired);
        }
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
            return _numTokensAcquired;

        } else {
            // tokenAddress can only be LINK or DAI
            uint256 _numTokensAcquired = IfakeUniswap(fakeUniswap).swapWethForToken(tokenAddress, address(vault), wethAmount);
            IERC20(WETH).transfer(fakeUniswap, wethAmount);  // Arbitrary transfer for debugging 
            return _numTokensAcquired;
        }
    }

    function ethToWeth() public payable {
        (bool sent, bytes memory data) = WETH.call{value: msg.value}("");
        require(sent, "Failed to swap Eth for Weth");
    }

    // ---------------------------------- Buy / Sell / Deposit ---------------------------------- //

    function buy() public payable isInitialised {
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
        _mint(msg.sender, tokensToMint);
    }

    function sell(uint256 tokensToSell) public isInitialised {
        uint256 proportionToSell = tokensToSell / balanceOf(msg.sender);
        for (uint8 i = 0; i < tokenAddresses.length; i++) {
            // How much of the token do they own?
            uint256 userAssets = vault.getUserQuantity(
                tokenAddresses[i],
                msg.sender
            );
            // Withdraw holding from vault, transfer tokens to user done inside the vault
            vault.withdraw(
                tokenAddresses[i],
                msg.sender,
                userAssets * proportionToSell
            );
        }
        _burn(msg.sender, tokensToSell);
    }

    function deposit(uint256 _totalWethAmount) private isInitialised returns (uint256) {
        uint256 vaultValuePrior = 0;
        for (uint8 i = 0; i < tokenAddresses.length; i++) {
            // Swap WETH for a different token which is transferred to the vault
            _percentageWethAmount = _totalWethAmount * percentageHoldings[i] / 100;
            uint256 numTokensAcquired = swap(_percentageWethAmount, tokenAddresses[i]);
            // Calculate contribution of token to vault value, which = quantity of token * price of token
            vaultValuePrior += vault.getTotalQuantity(tokenAddresses[i]) * (_percentageWethAmount / numTokensAcquired);
            // Deposit holding in vault
            vault.deposit(tokenAddresses[i], msg.sender, numTokensAcquired);
        }
        return vaultValuePrior;
    }

    // ----------------------------------- Misc Functions ----------------------------------- // 


    function sum(uint256[] memory list) private pure returns (uint256) {
        uint256 s = 0;
        for (uint8 i = 0; i < list.length; i++) {
            s += list[i];
        }
        return s;
    }

    function getBalance(address _tokenAddress, address _address) public view returns(uint256) {
        return IERC20(_tokenAddress).balanceOf(_address);
    }

    // -------------------------------------- Modifiers -------------------------------------- // 

    modifier onlyOwner() {
        require(Owner==msg.sender);
        _;
    }

    modifier isInitialised() {
        require(initialised==true);
        _;
    }

    modifier notInitialised() {
        require(initialised==false);
        _;
    }
}
