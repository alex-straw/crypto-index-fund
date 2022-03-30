// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.7;
pragma abicoder v2;

import "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";
import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract SwapToken {
    ISwapRouter public immutable swapRouter;

    address public constant DAI = 0xc7AD46e0b8a400Bb3C915120d284AafbA8fc4735;
    ERC20 daiContract = ERC20(DAI);
    address public constant WETH = 0xc778417E063141139Fce010982780140Aa0cD5Ab;
    ERC20 wethContract = ERC20(WETH);

    uint24 public constant poolFee = 3000;

    constructor() {
        swapRouter = ISwapRouter(0xE592427A0AEce92De3Edee1F18E0157C05861564);
    }

    function getDaiBalance() public view returns (uint256) {
        return daiContract.balanceOf(address(this));
    }

    function getWethBalance() public view returns (uint256) {
        return wethContract.balanceOf(address(this));
    }

    // This function checks the contract has enough Dai, and then swaps the specified amount of Dai for
    // as much Weth as possible using the UniSwap protocol
    function swapDaiToWeth(uint256 daiAmount) public returns (uint256) {
        require(getDaiBalance() >= daiAmount, "Insufficient funds");
        TransferHelper.safeApprove(DAI, address(swapRouter), daiAmount);
        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter
            .ExactInputSingleParams({
                tokenIn: DAI,
                tokenOut: WETH,
                fee: poolFee,
                recipient: address(this),
                deadline: block.timestamp,
                amountIn: daiAmount,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });
        uint256 wethAmount = swapRouter.exactInputSingle(params);
        return wethAmount;
    }
}
