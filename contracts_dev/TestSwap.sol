// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

// Needs to track which coins exist inside a portfolio
// Needs to track who owns each of those coins

interface IfakeUniswap {
    function swapWethForToken(address _tokenToBuy, address _recipient, uint256 _amountWethToSell) external returns(uint256);
    function increment() external;
}

contract TestSwap {

    address constant fakeUniswap = 0xFbd8c741Be3E6A0260AEa0875cd8801D3ACB0dA1;
    address constant DAI = 0x5592EC0cfb4dbc12D3aB100b257153436a1f0FEa;
    address constant LINK = 0x01BE23585060835E02B77ef475b0Cc51aA1e0709;
    address constant WETH = 0xc778417E063141139Fce010982780140Aa0cD5Ab;

    function swapToken(uint256 _amountWethToSell, address _recipient, address _tokenToBuy) public {
        IERC20(WETH).transfer(fakeUniswap, _amountWethToSell);
        IfakeUniswap(fakeUniswap).swapWethForToken(_tokenToBuy, _recipient, _amountWethToSell);
    }

    function contractBalanceOf(_tokenAddress) public view returns(uint256) {
        return IERC20(_tokenAddress).balanceOf(address(this));
    }
}
