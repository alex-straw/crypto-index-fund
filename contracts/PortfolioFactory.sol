// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.7;
import "./Portfolio_v2.sol";

// This contract will be the primary point of contact for the front end of the Dapp
// It will be permanently deployed and the front end will know its address
// It should do the following:
// 1) Provide mechanism for creating contracts
// 2) Provide mechanism for 'looking up' existing contracts
contract PortfolioFactory {
    // Portfolio creation event
    event CreatePortfolio(
        address address_,
        string indexed name_,
        string indexed symbol_,
        address[] tokenAddresses_,
        uint256[] percentageHoldings_,
        address indexed owner_,
        uint256 ownerFee_
    );

    address[] public portfolios;

    function create(
        string memory name_,
        string memory symbol_,
        address[] memory tokenAddresses_,
        uint256[] memory percentageHoldings_,
        uint256 ownerFee_
    ) public returns (address) {
        Portfolio_V2 portfolio = new Portfolio_V2(
            name_,
            symbol_,
            tokenAddresses_,
            percentageHoldings_,
            msg.sender,
            ownerFee_
        );
        emit CreatePortfolio(
            address(portfolio),
            name_,
            symbol_,
            tokenAddresses_,
            percentageHoldings_,
            msg.sender,
            ownerFee_
        );
        portfolios.push(address(portfolio));
        return address(portfolio);
    }
}
