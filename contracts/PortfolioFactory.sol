// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.7;

import "./Portfolio.sol";

/*
This contract is for creating and tracking Portfolios
It is the primary point of contact for the front end of the Dapp
It does the following:
1) Provides mechanism for creating contracts
2) Provides mechanism for 'looking up' existing contracts
*/
contract PortfolioFactory {
    // -------  State ------- //
    address[] public portfolios;

    // -------  Events ------- //
    event CreatePortfolio(
        address address_,
        string indexed name_,
        string indexed symbol_,
        address[] tokenAddresses_,
        uint256[] percentageHoldings_,
        address indexed owner_,
        uint256 ownerFee_
    );

    // -------  Functions ------- //
    function create(
        string memory name_,
        string memory symbol_,
        address[] memory tokenAddresses_,
        uint256[] memory percentageHoldings_,
        uint256 ownerFee_
    ) public {
        Portfolio portfolio = new Portfolio(
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
    }
}
