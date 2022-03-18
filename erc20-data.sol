// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/**
 * @title ERC20 Data
 * Kovan Testnet
 */
contract Storage {

    struct ERC20 {
        string ticker;
        uint256 vaultQuantity;
        address contractAddress;  // if true, that person already voted
        address tokenProxy; // For Price-Feeds https://kovan.etherscan.io/address/0x562C092bEb3a6DF77aDf0BB604F52c018E4f2814#internaltx
        uint256 proportionHoldings;
        uint256 priceUSD;
    }

    // Sample Transaction (Both for Rinkeby)
    // "LINK", "0x01BE23585060835E02B77ef475b0Cc51aA1e0709", "0xd8bD0a1cB028a31AA859A21A3758685a95dE4623", 50
    // "WETH", "0xc778417E063141139Fce010982780140Aa0cD5Ab", "0x8A753747A1Fa494EC906cE90E9f37563A8AF630e", 50

    uint8 id = 0;

    mapping(uint8 => ERC20) ERC20Map;

    function addToBasket (string calldata _ticker, address _contractAddress, address _tokenProxy, uint256 _proportionHoldings) external {
        ERC20Map[id].ticker = _ticker;
        ERC20Map[id].vaultQuantity = 0; // Initial qty is always 0
        ERC20Map[id].contractAddress = _contractAddress;
        ERC20Map[id].tokenProxy = _tokenProxy;
        ERC20Map[id].proportionHoldings = _proportionHoldings;
        ERC20Map[id].priceUSD = 0; // Default set to 0
        id ++;
    }

    function getTokenAddress(uint8 _id) public view returns (address) {
        return ERC20Map[_id].contractAddress;
    }
}
