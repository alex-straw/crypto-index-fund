const Web3 = require("web3");
const portfolioFactoryABI = require("../abi/portfolioFactoryABI.json");

// Connect to Rinkeby (may be other ways to do this than Infura)
const infuraId = "1c722de80b77412f86091fdf4d04b74b";
const apiKey = "https://rinkeby.infura.io/v3/" + infuraId;
const web3 = new Web3(new Web3.providers.HttpProvider(apiKey));

const portfolioFactoryAddress = "0x94A2FdaEE4CC0813EF4F3dc5826BF67BFc45A495";
const portfolioFactory = new web3.eth.Contract(
  portfolioFactoryABI,
  portfolioFactoryAddress
);

// Unable to subscribe to events through Infura Web3 provider
portfolioFactory.events.CreatePortfolio(
  {
    fromBlock: "earliest",
  },
  function (error, event) {
    if (!error) {
      console.log(event);
    } else {
      console.log(error);
    }
  }
);
