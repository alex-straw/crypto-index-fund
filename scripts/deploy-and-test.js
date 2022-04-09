async function initialisePortfolio(hardhatPortfolio, ethAmount) {
  
  const [owner] = await ethers.getSigners();

  await owner.sendTransaction({
    to: hardhatPortfolio.initialisePortfolio(),
    value: ethAmount
  });

  console.log(hardhatPortfolio.totalSupply());
}


async function main() {

  // --------------------------- Constructor --------------------------- //
  let _name = "Portfolio";
  let _ticker = "FOLO";
  let _tokenAddresses = ["0xa36085F69e2889c224210F603D836748e7dC0088", "0xd0A1E359811322d97991E03f863a0C30C2cF029C"];
  let _percentageHoldings = [40, 60];
  let _owner = "0xF1C37BC188643DF4Bf15Fd437096Eb654d30abc1";
  let _ownerFee = 100;

// ---------------------------- Initialise ---------------------------- //
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

  console.log(hardhatPortfolio.address);

  await hardhatPortfolio.initialisePortfolio({value: "1000000000"}); 

  const supply = await hardhatPortfolio.totalSupply();
  console.log(supply)

}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
});