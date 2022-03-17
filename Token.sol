// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.7;

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract BasketCoin is ERC20 {

    address[] tokensInBasket;

    constructor(string memory name_, string memory symbol_, address[] memory tokensInBasket_) ERC20(name_, symbol_) {
        
        tokensInBasket = tokensInBasket_;
        
    }

    function getTokensInBasket() public view returns(address[] memory) {
        return tokensInBasket;
    }

    // 1. Take Eth amount as input
    // 2. Calculate BasketCoin price:
    //      a. Get price of each token in basket
    //      b. Get proportions of each token in basket
    //      c. Calculate price of BasketCoin
    // 3. Calculate amount of each token in the basket to buy
    // 4. Buy those tokens and transfer them to the Vault
    // 5. Mint tokens based on Eth amount and token price
    function issue(uint256 amountInEth) public {

        uint256 basketTokensToMint = 1;
        address newCoinHolder = msg.sender;

        _mint(newCoinHolder, basketTokensToMint);
    }

}
