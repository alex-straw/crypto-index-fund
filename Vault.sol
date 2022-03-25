// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.7;

// Needs to track which coins exist inside a portfolio
// Needs to track who owns each of those coins

contract Vault {
    // totalAssets: token address => total quantity owned
    mapping(address => uint256) public totalAssets;
    // Tracks user ownership of assets in vault
    // userAssets: token address -> user address -> quantity owned by user
    mapping(address => mapping(address => uint256)) private userAssets;
    address portfolioAddress;

    constructor(address[] memory tokenAddresses) {
        portfolioAddress = msg.sender;

        for (uint256 i = 0; i < tokenAddresses.length; i++) {
            totalAssets[tokenAddresses[i]] = 0;
            userAssets[tokenAddresses[i]][portfolioAddress] = 0;
        }
    }

    modifier isPortfolio() {
        require(msg.sender == portfolioAddress);
        _;
    }

    function deposit(
        address tokenAddress,
        address userAddress,
        uint256 amount
    ) external isPortfolio {
        totalAssets[tokenAddress] += amount;
        userAssets[tokenAddress][userAddress] += amount;
    }

    function withdraw(
        address tokenAddress,
        address userAddress,
        uint256 amount
    ) external isPortfolio {
        require(
            userAssets[tokenAddress][userAddress] >= amount,
            "Insufficient funds"
        );
        totalAssets[tokenAddress] -= amount;
        userAssets[tokenAddress][userAddress] -= amount;
    }
}
