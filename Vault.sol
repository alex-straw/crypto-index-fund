// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.7;

contract Vault {

    address[] public tokens;
    uint256[] tokenPercentages;
    uint256[] public quantities;
    uint256 netAssetValue;

    constructor(address[] memory tokens_, uint256[] memory tokenPercentages_) {
        tokens = tokens_;
        tokenPercentages = tokenPercentages_;
        quantities = new uint256[](tokens_.length);
        netAssetValue = 0;
    }

    // To issue new tokens, we need to know the following:
    // 1. The amount (in Eth) that a user wants to spend on new tokens
    // 2. The value of the underlying assets (i.e. the value of the vault)
    //      - This must be determined using Chainlink price feeds and the quantity of ERC20 tokens in the vault
    // 3. The number of BasketCoin tokens in supply before the issuance
    // 
    // The formula for the number of tokens to issue is then:
    // TokensToIssue = SpendAmount / VaultValuePerBasketCoin
    // Where VaultValuePerBasketCoin = VaultValue / BasketCoinSupply
    function issue(uint256 ethAmount, uint256 currentSupply) public returns(uint256) {
        // Determine value of underlying assets
        uint256 nav = 0;
        uint256[] memory purchases;
        for (uint i=0; i<tokens.length; i++) {
            address tokenAddress = tokens[i];
            uint256 tokenPrice = getPriceFeed(tokenAddress);
            uint256 tokenQuantity = quantities[i];
            nav += tokenPrice * tokenQuantity;

            purchases[i] = (ethAmount * tokenPercentages[i] * tokenPrice) / 100;
        }
        netAssetValue = nav;
        // Purchase new underlying assets
        purchaseOnDex(purchases);

        // Determine number of tokens to issue
        uint256 tokensToIssue = ethAmount / (nav / currentSupply);

        // Issue tokens
        return tokensToIssue;
    }

    function getPriceFeed(address token) private pure returns(uint256) {
        return 10;
    }

    function purchaseOnDex(uint256[] memory purchaseAmounts) private {
    
    }

    function withdraw() public {
        address payable to = payable(msg.sender);
        to.transfer(address(this).balance);
    }

    receive() external payable {}
    
}
