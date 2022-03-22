// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.7;

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./Vault.sol";

contract PortfolioTesting is ERC20 {

    Vault vault;
    uint256 ethToTokenRatio; 
    address[] tokenAddresses;
    uint256[] percentageHoldings;

    constructor() {
        ethToTokenRatio = 1000;
        tokenAddresses = ["0xc778417E063141139Fce010982780140Aa0cD5Ab"];
        percentageHoldings = [100];
        vault = new Vault(tokenAddresses);
    }

    function buy() public payable returns(uint256) {
        uint256 memory tokensToMint = msg.value * ethToTokenRatio; 
        vault.deposit("0xc778417E063141139Fce010982780140Aa0cD5Ab", msg.sender, msg.value);
        _mint(msg.sender, tokensToMint);
        return (tokensToMint);
    }

    function sell(uint256 tokensToSell) public returns(uint256) {
        uint256 memory ethToWithdraw = tokensToSell/ethToTokenRatio;
        vault.withdraw("0xc778417E063141139Fce010982780140Aa0cD5Ab", ethToWithdraw);
        _burn(msg.sender, tokensToSell);
        return(ethToWithdraw);
    }
}
