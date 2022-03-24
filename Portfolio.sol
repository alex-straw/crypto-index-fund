// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.7;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./Vault.sol";
import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";

contract TestPortfolio is ERC20 {
    Vault vault;
    address[] public tokenAddresses;
    uint256[] public percentageHoldings;
    ISwapRouter uniswapRouter;

    constructor(
        string memory name_,
        string memory symbol_,
        address[] memory tokenAddresses_,
        uint256[] memory percentageHoldings_
    ) ERC20(name_, symbol_) {
        tokenAddresses = tokenAddresses_;
        percentageHoldings = percentageHoldings_;
        vault = new Vault(tokenAddresses_);
        uniswapRouter = ISwapRouter(0xE592427A0AEce92De3Edee1F18E0157C05861564);
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
}
