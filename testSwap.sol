// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

// Needs to track which coins exist inside a portfolio
// Needs to track who owns each of those coins

interface IfakeUniswap {
    function swapWethForToken(address _tokenToBuy, address _recipient, uint256 _amountWethToSell) external;
    function increment() external;
}

contract TestSwap {

    address fakeUniswap = 0x1fCb5Ef0826112f904ABdBBB0493158737Ceb726;

    address DAI = 0x5592EC0cfb4dbc12D3aB100b257153436a1f0FEa;
    address LINK = 0x01BE23585060835E02B77ef475b0Cc51aA1e0709;
    address WETH = 0xc778417E063141139Fce010982780140Aa0cD5Ab;

    function swapToken(uint256 _amountWethToSell, address _recipient, address _tokenToBuy) public {
        IERC20(WETH).transfer(fakeUniswap, _amountWethToSell);
        IfakeUniswap(fakeUniswap).swapWethForToken(_tokenToBuy, _recipient, _amountWethToSell);
    }

    function contractDAIBalance() public view returns(uint256) {
        return IERC20(DAI).balanceOf(address(this));
    }

    function contractLINKBalance() public view returns(uint256) {
        return IERC20(LINK).balanceOf(address(this));
    }

    function contractWETHBalance() public view returns(uint256) {
        return IERC20(WETH).balanceOf(address(this));
    }
}
