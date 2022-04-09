async function main() {
    const [deployer] = await ethers.getSigners();
  
    console.log("Deploying contracts with the account:", deployer.address);
  
    console.log("Account balance:", (await deployer.getBalance()).toString());
  
    const Portfolio = await ethers.getContractFactory("Portfolio");
    const _Portfolio = await Portfolio.deploy(
        "Portfolio", 
        "FOLO", 
        ["0xa36085F69e2889c224210F603D836748e7dC0088", "0xd0A1E359811322d97991E03f863a0C30C2cF029C"],
        [40,60],
        "0xF1C37BC188643DF4Bf15Fd437096Eb654d30abc1", 
        100);
  
    console.log("Portfolio address:", _Portfolio.address);
  }
  
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });