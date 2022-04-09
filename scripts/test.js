var mocha = require('mocha')
var describe = mocha.describe
var it = mocha.it
var expect = require('chai').expect
var assert = require('chai').assert

async function main() {

  // --------------------------- Constructor --------------------------- //
  let _name = "Portfolio";
  let _ticker = "FOLO";
  let _tokenAddresses = ["0xa36085F69e2889c224210F603D836748e7dC0088", "0xd0A1E359811322d97991E03f863a0C30C2cF029C"];
  let _percentageHoldings = [40, 60];
  let _owner = "0xF1C37BC188643DF4Bf15Fd437096Eb654d30abc1";
  let _ownerFee = 100;

  // ---------------------------- Initialise ---------------------------- //
  let _initialiseAmount = "10000000000"


  const [deployer] = await ethers.getSigners();
  console.log("Deploying contracts with the account:", deployer.address);
  console.log("Account balance:", (await deployer.getBalance()).toString());

  const Portfolio = await ethers.getContractFactory("Portfolio");
  const hardhatPortfolio = await Portfolio.deploy(
    _name,
    _ticker,
    _tokenAddresses,
    _percentageHoldings,
    _owner,
    _ownerFee);

  await hardhatPortfolio.initialisePortfolio({value: _initialiseAmount});

  console.log(hardhatPortfolio.address)

  const supply = await hardhatPortfolio.totalSupply.call();

  console.log(supply)

  async function test() {
    expect((await hardhatPortfolio.totalSupply().toString()).to.equal("100000000000000000000"));
  };

  test()
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
});