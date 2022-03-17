// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.7;

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract BasketCoin is ERC20 {

    // struct Token = {
    //     tokenName: "",
    //     tokenPercentages: 50,
    //     price: 10
    // }

    address[] tokens;
    uint256[] tokenPercentages;
    uint256[] tokenPrices;

    constructor(
        string memory name_,
        string memory symbol_,
        address[] memory tokens_,
        uint256[] memory tokenPercentages_) ERC20(name_, symbol_
        ) 
        {
            require(tokens_.length == tokenPercentages_.length, "Please specify the same number of tokens and percentages");
            require(sum(tokenPercentages_) == 100, "Percentage allocation must sum to 100");
            tokens = tokens_;
            tokenPercentages = tokenPercentages_;
        }

    function getTokensInBasket() public view returns(address[] memory) {
        return tokens;
    }

    function getPercentageAllocations() public view returns(uint256[] memory) {
        return tokenPercentages;
    }

    // 1. Take Eth amount as input
    // 2. Calculate BasketCoin price:
    //      a. Get price of each token in basket
    //      b. Get proportions of each token in basket
    //      c. Calculate price of BasketCoin
    // 3. Calculate amount of each token in the basket to buy
    // 4. Buy those tokens and transfer them to the Vault
    // 5. Mint tokens based on Eth amount and token price
    function issue(uint256 amountToMint) public {
        address newCoinHolder = msg.sender;
        _mint(newCoinHolder, amountToMint);
    }

    function liquidate(uint256 amountToLiquidate) public {
        address newCoinHolder = msg.sender;
        _burn(newCoinHolder, amountToLiquidate);
    }

    function sum(uint256[] memory numbers) private pure returns(uint256) {
        uint256 total = 0;
        for (uint i=0; i<numbers.length; i++) {
            total += numbers[i];
        }
        return total;
    }

}
