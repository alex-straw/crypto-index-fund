// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.7;

// Needs to track which coins exist inside a portfolio
// Needs to track who owns each of those coins

contract Vault_v2 {
    // assets: Token address -> user address -> quantity owned 
    mapping(address => mapping(address => uint256)) private assets;

    address portfolioAddress;

    constructor(address[] memory tokenAddresses) {
        portfolioAddress = msg.sender;

        for (uint256 i=0; i<tokenAddresses.length; i++) {
            assets[tokenAddresses[i]][portfolioAddress] = 0;
        }
    }

    modifier isPortfolio {
        require(msg.sender == portfolioAddress);
        _;
    }

    function deposit(address tokenAddress, address userAddress, uint256 amount) external isPortfolio {
        assets[tokenAddress][userAddress] += amount;
    }

    function withdraw(address tokenAddress, address userAddress, uint256 amount) external isPortfolio {
        require(assets[tokenAddress][userAddress] >= amount, "Insufficient funds");
        assets[tokenAddress][userAddress] -= amount;
    }
}