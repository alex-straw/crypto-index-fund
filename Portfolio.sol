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
    ERC20 WETH = ERC20(0xc778417E063141139Fce010982780140Aa0cD5Ab);

    constructor(
        string memory name_,
        string memory symbol_,
        address[] memory tokenAddresses_,
        uint256[] memory percentageHoldings_
    ) ERC20(name_, symbol_) {
        // $10 worth of Eth 24/3/22
        // Would be cool to use Chainlink to work out what $10 worth of Eth is and ensure we get good price
        require(
            msg.value > 3268779871915400,
            "Creating a Portfolio requires more Eth"
        );
        tokenAddresses = tokenAddresses_;
        percentageHoldings = percentageHoldings_;
        vault = new Vault(tokenAddresses_);
        uniswapRouter = ISwapRouter(0xE592427A0AEce92De3Edee1F18E0157C05861564);

        // Buy the underlying tokens with the amount of Eth in msg.value
        // First, convert Eth to Weth
        WETH.transfer(msg.value);
        uint256 wethBalance = WETH.balanceOf(address(this));
        // Loop through tokens to buy
        for (i = 0; i < tokenAddresses_.length; i++) {
            // Work out WETH to spend
            wethToSpend = wethBalance * (percentageHoldings_[i] / 100);
            // Swap WETH for token and assign it to the vault
            swapWethForToken(wethToSpend, tokenAddresses[i], address(vault));
        }
        _mint(msg.sender, 99);
        _mint(address(vault), 1);
    }

    function swapFromWeth(
        uint256 wethAmount,
        address tokenOut,
        address recipient
    ) private {
        require(
            WETH.balanceOf(address(this)) >= wethAmount,
            "Insufficient funds"
        );
        TransferHelper.safeApprove(
            address(WETH),
            address(swapRouter),
            wethAmount
        );
        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter
            .ExactInputSingleParams({
                tokenIn: address(WETH),
                tokenOut: tokenOut,
                fee: 3000,
                recipient: recipient,
                deadline: block.timestamp,
                amountIn: wethAmount,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });
        uint256 wethAmount = swapRouter.exactInputSingle(params);
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
