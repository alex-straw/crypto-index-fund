# FinTech Group Project - Backend

Backend for group 4 project: creating portfolios of crypto assets.

## Smart contracts

We have two smart contracts, one public and one private:

1. Portfolio.sol
2. Vault.sol
3. PortfolioFactory.sol (not in MVP)

## Test Portfolio

We have deployed a Test Portfolio at the following address: 

0x5F58DDAf12Ca3535356953a0a459Ab38A3e5796a

It's super simple, containing only Eth!

Please use it to test the *buy* and *sell* functions described below. 

Also, it is an ERC20 token, which means it has many other useful methods, such as balanceOf and totalSupply. 

The ERC20 specification, with all the functions, can be found [here](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol).

## Core Functionality

### 1. Creating a portfolio (not part of MVP)

Use the constructor of PortfolioFactory.sol to create a portfolio containing *k* tokens:

**Input:** 

The index of each of the following arrays should correspond to the same ERC20 token.

1. A list of token addresses. \
   Rules: Must be ERC20 smart contract addresses. Must be of length k. \
   Example: ["0xabc...","0xdef..."]
2. A list of uniswap smart contract addresses corresponding to the above ETH/token swap. \
   Rules: Must be of length k. 
   Example: ["0xghi...","0xjkl..."]
3. A list of percentage holdings of each of the specified tokens. 
   Rules: Must be of length k. Must sum to 100.
   Example: [20,20,50,10]

**Returns:**

The contract (portfolio) address.


### 2. Buy into an existing portfolio

First, you need the contract (portfolio) address. 

Send a transaction to the *buy* function, with Ether in msg.value. 

The function doesn't return anything.


### 3. Sell position in existing portfolio

First, you need the contract (portfolio) address.

Send a transaction to the *sell* function, and pass as argument the number of Folio coins to sell. 

The function doesn't return anything.


## Additional Functionality

1. Get info about portfolio
2. View events (such as token minting/burning/new portfolio creation etc)


