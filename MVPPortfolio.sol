// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.7;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./Vault.sol";

// Example portfolio of Weth and Dai
contract MVPPortfolio is ERC20 {
    // STATE VARIABLES
    Vault vault;
    address[] public tokenAddresses;
    uint256[] public percentageHoldings;
    address payable WETH = payable(0xc778417E063141139Fce010982780140Aa0cD5Ab);

    // TEMPORARY STATE VARIABLES
    address payable DAI = payable(0x5592EC0cfb4dbc12D3aB100b257153436a1f0FEa);

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
        vault = new Vault(tokenAddresses_);
        deposit(getWeth());
        _mint(msg.sender, 100);
    }

    function buy() public payable {
        uint256 wethAmount = getWeth();
        uint256 vaultValuePrior = deposit(wethAmount);
        // The number of tokens to mint is determined by the formula:
        // t = (SUPPLY_b * WETH) / NAV_b
        // where:
        // t = tokens to issue
        // SUPPLY_b = total supply of tokens before the issuance
        // NAV_b = net asset value (in vault) after the deposits
        // WETH = amount of Weth deposited for issuance
        uint256 tokensToMint = (totalSupply() * wethAmount) / vaultValuePrior;
        _mint(msg.sender, tokensToMint);
    }

    function sell(uint256 tokensToSell) public {
        uint256 proportionToSell = tokensToSell / balanceOf(msg.sender);
        for (uint256 i = 0; i < tokenAddresses.length; i++) {
            // How much of the token do they own?
            uint256 userAssets = vault.getUserQuantity(
                tokenAddresses[i],
                msg.sender
            );
            // Withdraw holding from vault
            vault.withdraw(
                tokenAddresses[i],
                msg.sender,
                userAssets * proportionToSell
            );
        }
        _burn(msg.sender, tokensToSell);
    }

    // HELPER FUNCTIONS

    function getWeth() public payable returns (uint256) {
        (bool sent, bytes memory data) = WETH.call{value: msg.value}("");
        require(sent, "Failed to swap Eth for Weth");
        return msg.value;
    }

    function deposit(uint256 wethAmount) private returns (uint256) {
        uint256 vaultValuePrior = 0;
        for (uint256 i = 0; i < tokenAddresses.length; i++) {
            // TODO: Swap Weth for token...
            uint256 swappedAmount = swap(
                wethAmount * (percentageHoldings[i] / 100),
                WETH,
                tokenAddresses[i]
            );
            // Calculate contribution of token to vault value, which = quantity of token * price of token
            uint256 vaultContribution = vault.getTotalQuantity(
                tokenAddresses[i]
            ) * (wethAmount / swappedAmount);
            vaultValuePrior += vaultContribution;
            // Deposit holding in vault
            vault.deposit(tokenAddresses[i], msg.sender, swappedAmount);
        }
        return vaultValuePrior;
    }

    function sum(uint256[] memory list) private pure returns (uint256) {
        uint256 s = 0;
        for (uint256 i = 0; i < list.length; i++) {
            s += list[i];
        }
        return s;
    }

    // Needs to be implemented properly using Uniswap
    // For now, stubbed the method to return hardcoded values for WETH and DAI
    function swap(
        uint256 wethAmount,
        address fromAddress,
        address toAddress
    ) private returns (uint256) {
        uint256 swappedAmount = 0;
        if (toAddress == WETH) {
            swappedAmount = wethAmount;
        } else if (toAddress == DAI) {
            swappedAmount = wethAmount * 3119;
        }
        return swappedAmount;
    }

    // FUNCTIONS FOR DEBUGGING

    function getEthBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getWethBalance() public view returns (uint256) {
        return ERC20(WETH).balanceOf(address(this));
    }
}
