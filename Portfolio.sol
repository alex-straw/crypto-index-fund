// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.7;

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./Vault_v2.sol";


contract Portfolio { 

    struct Token {
        string ticker;
        uint256 vaultQuantity;
        address tokenAddress;  // if true, that person already voted
        address uniswapProxy; // For Price-Feeds https://kovan.etherscan.io/address/0x562C092bEb3a6DF77aDf0BB604F52c018E4f2814#internaltx
        uint256 proportionHoldings;
        uint256 tokenPrice;
    }

    uint8 id = 0;
    uint256 basketTokensMinted = 0;
    mapping(uint8 => Token) ERC20Map;
    Vault_v2 vault;


    // https://rinkeby.etherscan.io/address/0x5eD8BD53B0c3fa3dEaBd345430B1A3a6A4e8BD7C --> Call Mint to get DAI
    // Price feeds are LINK/USD, BAT/USD

    // Sample Transaction (Both for Rinkeby), 
    // LINK / ETH
    // "LINK", "0x01BE23585060835E02B77ef475b0Cc51aA1e0709", "0xFABe80711F3ea886C3AC102c81ffC9825E16162E", 100

    // WETH / USD
    // "WETH", "0xc778417E063141139Fce010982780140Aa0cD5Ab", "0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419", 0

    // BAT / USD
    // "BAT", "0xDA5B056Cfb861282B4b59d29c9B395bcC238D29B", "0x031dB56e01f82f20803059331DC6bEe9b17F7fC9", 0

    constructor(address[] memory tokenAddresses) {
        vault = new Vault_v2(tokenAddresses);
    }

    function addToBasket (string calldata _ticker, address _tokenAddress, address _uniswapProxy, uint256 _proportionHoldings) external {
        ERC20Map[id].tokenAddress = _tokenAddress;
        ERC20Map[id].uniswapProxy = _uniswapProxy;
        ERC20Map[id].proportionHoldings = _proportionHoldings;
        ERC20Map[id].tokenPrice = 0; // Default set to 0
        id ++;
    }

    function getVaultAddress() public view returns(Vault_v2) {
        return vault;
    }

    function issue(uint256 ethAmount) public returns(uint256) {
        // Determine value of underlying assets
        uint256 totalValueLocked = 0; // Re-calculate TVL before issuing new tokens

        for (uint i=0; i< id; i++) {
		uint256 ethToSwap = ethAmount * ERC20Map[id].proportionHoldings / 100;
		uint256 amtPurchased = swapTokens(ERC20Map[id].tokenAddress, ethToSwap, ERC20Map[id].uniswapProxy);

		ERC20Map[id].tokenPrice = ethToSwap / amtPurchased;
		ERC20Map[id].vaultQuantity += amtPurchased; // Keeps track of amount of tokens held in vault

		// Add eth value of tokens together and record in TVL variable
		totalValueLocked += ERC20Map[id].tokenPrice * ERC20Map[id].vaultQuantity;
        }
	if (basketTokensMinted !=0) {
            return getTokenIssueAmount(totalValueLocked, ethAmount, basketTokensMinted);
        }
    	return 100;
    }

    function getTokenIssueAmount(uint256 _totalValueLocked, uint256 _ethAmount, uint256 _basketTokensMinted) private pure returns(uint256 issueQty) {
        return issueQty = _ethAmount / (_totalValueLocked / _basketTokensMinted);
    }

    function swapTokens(address _tokenAddress, uint256 _ethToSwap, address _uniswapProxy) private returns(uint256){
        // Purchase tokens on Uniswap
        // Send tokens to vault
	return 10;
    }

    function withdraw() public {
        address payable to = payable(msg.sender);
        to.transfer(address(this).balance);
    }

    receive() external payable {}
   
}
