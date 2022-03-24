// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.7;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./Vault.sol";

contract TestPortfolio is ERC20 {
    Vault vault;
    uint256 public ethToTokenRatio;
    address[] public tokenAddresses;
    uint256[] public percentageHoldings;
    address payable WETH = payable(0xc778417E063141139Fce010982780140Aa0cD5Ab);

    constructor(string memory name_, string memory symbol_)
        payable
        ERC20(name_, symbol_)
    {
        ethToTokenRatio = 1000;
        tokenAddresses.push(0xc778417E063141139Fce010982780140Aa0cD5Ab);
        percentageHoldings.push(100);
        vault = new Vault(tokenAddresses);
        (bool sent, bytes memory data) = WETH.call{value: msg.value}("");
        require(sent, "Failed to send Ether");
    }

    function buy() public payable {
        uint256 tokensToMint = msg.value * ethToTokenRatio;
        vault.deposit(
            0xc778417E063141139Fce010982780140Aa0cD5Ab,
            msg.sender,
            msg.value
        );
        _mint(msg.sender, tokensToMint);
    }

    function sell(uint256 tokensToSell) public {
        uint256 ethToWithdraw = tokensToSell / ethToTokenRatio;
        vault.withdraw(
            0xc778417E063141139Fce010982780140Aa0cD5Ab,
            msg.sender,
            ethToWithdraw
        );
        _burn(msg.sender, tokensToSell);
    }

    // FUNCTIONS FOR DEBUGGING

    function getEthBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getWethBalance() public view returns (uint256) {
        return ERC20(WETH).balanceOf(address(this));
    }
}
