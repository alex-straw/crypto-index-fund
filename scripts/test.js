var mocha = require('mocha')
var describe = mocha.describe
var it = mocha.it
var expect = require('chai').expect
var assert = require('chai').assert
var chai = require('chai');  


async function getTotalSupply(contract) {
  return (await contract.totalSupply.call()).toString()
}

async function main() {

  // --------------------------- Constructor --------------------------- //
  let _name = "Portfolio";
  let _ticker = "FOLO";
  let _tokenAddresses = ["0xa36085F69e2889c224210F603D836748e7dC0088", "0xd0A1E359811322d97991E03f863a0C30C2cF029C"];
  let _percentageHoldings = [40, 60];
  let _ownerFee = 100;
  let _initialiseAmount = "10000000000"

  // ---------------------------- Initialise ---------------------------- //

  /*

  PROCESS JUSTIFICATION:
  
  Typically Hardhat is used to deploy contracts on a local blockchain for quick testing of 
  contracts without the need for test ETH.  However, as this project uses Uniswap which
  in turn relies on real liqudity provided by individuals, this must be tested a live test
  net.  However, Hardhat's it and describe functionality etc., are not built to be used in
  this way and do not work.  I.e., this needs to be ran using:

  > npx hardhat run scripts/test.js --network kovan

  instead of:

  > npx hardhat test

  Consequently, to get these tests running it requires real test Ether and a different strategy
  for testing than is recommended in Hardhat tutorials.  Also, I've upped the timeout time for
  MOCHA to around 40,000 ms as these transactions must be mined into a real block.  


  */

  /*
  1. First deploy PortfolioFactory.sol
  2. Call the create function on PortfolioFactory.sol with relevant constructor arguments
  3. Retrieve the portfolio address from Portfolio Factory's public array variable 'portfolios'
  */
  const [deployer] = await ethers.getSigners();
  console.log("Deploying contracts with the account:", deployer.address);
  console.log("Account balance:", (await deployer.getBalance()).toString());

  const Portfolio = await ethers.getContractFactory("PortfolioFactory");
  const PortfolioFactory = await Portfolio.deploy();

  await PortfolioFactory.create(
    _name,
    _ticker,
    _tokenAddresses,
    _percentageHoldings,
    _ownerFee);

  const PortfolioAddress = await PortfolioFactory.portfolios(0);  // Get the portfolio address
  await PortfolioAddress.initialisePortfolio({value: _initialiseAmount});  // Initialise the portfolio
  
  console.log("Portfolio factory address:", await PortfolioFactory.address)
  console.log("Portfolio address: ", await PortfolioAddress)

  // ---------------------------- Init Testing ---------------------------- //
  assert.equal(await getTotalSupply(hardhatPortfolio), "100000000000000000000");

}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
});