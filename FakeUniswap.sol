// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

// Rinkeby Address: 0x1fCb5Ef0826112f904ABdBBB0493158737Ceb726

contract FakeUniswap {

    // Fake Uniswap contract for testing multi-ERC20 portfolios
    // 1. Transfer DAI and LINK tokens to this address first (from MetaMask)

    address DAI;
    address WETH;
    address LINK;
    address owner;

    mapping(address => uint256) exchangeRate; // WETH to token exchange rate

    constructor () {
        DAI = 0x5592EC0cfb4dbc12D3aB100b257153436a1f0FEa;
        LINK = 0x01BE23585060835E02B77ef475b0Cc51aA1e0709;
        WETH = 0xc778417E063141139Fce010982780140Aa0cD5Ab;

        exchangeRate[DAI] = 5000;
        exchangeRate[LINK] = 200;
        owner = msg.sender;

    }

    modifier onlyOwner(){
        require(msg.sender == owner);
        _;
    }

    function getBalance(address _token, address _account) public view returns(uint256) {
        return IERC20(_token).balanceOf(_account);
    }

    function swapWethForToken(address _tokenToBuy, address _recipient, uint256 _amountWethToSell) public {
        require(getBalance(WETH, msg.sender) >= _amountWethToSell, "Sender does not have enough WETH");
        require(getBalance(_tokenToBuy, address(this)) >= _amountWethToSell * exchangeRate[_tokenToBuy], "Contract has insufficient funds");
        // User transfers WETH
        // Add transfer function to MVP Portfolio
        // IERC20(WETH).transfer(THIS_CONTRACT, AMOUNTWETH);
        // Contract transfers _tokenToBuy
        IERC20(_tokenToBuy).transfer(_recipient, _amountWethToSell*exchangeRate[_tokenToBuy]);
    }

    // DEBUG FUNCTIONS

    function contractLinkBalance() public view returns(uint256) {
        return IERC20(LINK).balanceOf(address(this));
    }

    function contractDAIBalance() public view returns(uint256) {
        return IERC20(DAI).balanceOf(address(this));
    }

    function withdrawToken(address _tokenAddress) public onlyOwner {
        IERC20(_tokenAddress).transfer(owner, IERC20(_tokenAddress).balanceOf(address(this)));
    }
}
