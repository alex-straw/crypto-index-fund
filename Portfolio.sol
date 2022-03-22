// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.7;

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./Vault.sol";

contract Portfolio is ERC20 {

    address[] public tokens;
    uint256[] public tokenPercentages;
    Vault vault;

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
        vault = new Vault(tokens_, tokenPercentages_);
    }

    function issue() public payable {
        uint256 tokensToIssue = vault.issue(msg.value, totalSupply());
        _mint(msg.sender, tokensToIssue);
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
