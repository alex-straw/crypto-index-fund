// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.7;

contract Vault {

    struct ERC20 {
        string ticker;
        uint256 vaultQuantity;
        address tokenAddress;  // if true, that person already voted
        address tokenProxy; // For Price-Feeds https://kovan.etherscan.io/address/0x562C092bEb3a6DF77aDf0BB604F52c018E4f2814#internaltx
        uint256 proportionHoldings;
        uint256 tokenPrice;
        uint256 purchaseQtyPending;
    }

    uint8 id = 0;
    uint256 basketTokensMinted = 0;

    // https://rinkeby.etherscan.io/address/0x5eD8BD53B0c3fa3dEaBd345430B1A3a6A4e8BD7C --> Call Mint to get DAI
    // Price feeds are LINK/USD, BAT/USD

    // Sample Transaction (Both for Rinkeby), 
    // LINK / ETH
    // "LINK", "0x01BE23585060835E02B77ef475b0Cc51aA1e0709", "0xFABe80711F3ea886C3AC102c81ffC9825E16162E", 100

    // WETH / USD
    // "WETH", "0xc778417E063141139Fce010982780140Aa0cD5Ab", "0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419", 0

    // BAT / USD
    // "BAT", "0xDA5B056Cfb861282B4b59d29c9B395bcC238D29B", "0x031dB56e01f82f20803059331DC6bEe9b17F7fC9", 0

    mapping(uint8 => ERC20) ERC20Map;

    function addToBasket (string calldata _ticker, address _tokenAddress, address _tokenProxy, uint256 _proportionHoldings) external {
        ERC20Map[id].ticker = _ticker;
        ERC20Map[id].vaultQuantity = 0; // Initial qty is always 0
        ERC20Map[id].tokenAddress = _tokenAddress;
        ERC20Map[id].tokenProxy = _tokenProxy;
        ERC20Map[id].proportionHoldings = _proportionHoldings;
        ERC20Map[id].tokenPrice = 0; // Default set to 0
        ERC20Map[id].purchaseQtyPending = 0;
        id ++;
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

    function issue(uint256 ethAmount) public returns(uint256) {
        // Determine value of underlying assets
        uint256 totalValueLocked = 0; // Re-calculate TVL before issuing new tokens

        for (uint i=0; i< id; i++) {
            // Store non-stale price feed value in struct
            ERC20Map[id].tokenPrice = getPriceFeed(ERC20Map[id].tokenAddress);

            // Add eth value of tokens together and record in TVL variable
            totalValueLocked += ERC20Map[id].tokenPrice * ERC20Map[id].vaultQuantity;

            // Quantity of token that must be purchased
            // Eth amount to spend * percentage.  Divide by the "TOKEN/ETH" ratio (e.g., LINK/ETH ~= 0.05)
            ERC20Map[id].purchaseQtyPending = ethAmount * ERC20Map[id].proportionHoldings / (100*ERC20Map[id].tokenPrice);

            // Buy tokens, send to vault
            purchaseTokens(ERC20Map[id].tokenAddress, ERC20Map[id].tokenProxy, ERC20Map[id].purchaseQtyPending);

            ERC20Map[id].vaultQuantity += ERC20Map[id].purchaseQtyPending; // Keeps track of amount of tokens held in vault
            ERC20Map[id].purchaseQtyPending = 0; // Order completed.  Set pending orders for token 'id' to 0.

            if (basketTokensMinted !=0) {
                return getTokenIssueAmount(totalValueLocked, ethAmount, basketTokensMinted);
            }
            return 100;
        }
    }

    function getTokenIssueAmount(uint256 _totalValueLocked, uint256 _ethAmount, uint256 _basketTokensMinted) private pure returns(uint256 issueQty) {
        return issueQty = _ethAmount / (_totalValueLocked / _basketTokensMinted);
    }

    function getPriceFeed(address token) private pure returns(uint256) {
        return 10;
    }

    function purchaseTokens(address _tokenAddress, address _contractProxy, uint256 _quantity) private {
        // Purchase tokens on Uniswap
        // Send tokens to vault
    }

    function withdraw() public {
        address payable to = payable(msg.sender);
        to.transfer(address(this).balance);
    }

    receive() external payable {}
    
}
