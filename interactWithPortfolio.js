const Web3 = require("web3");
const ethers = require("ethers");
const testPortfolioABI = require("./testPortfolioABI.json");

// Connect to Rinkeby (may be other ways to do this than Infura)
const infuraId = "1c722de80b77412f86091fdf4d04b74b";
const apiKey = "https://rinkeby.infura.io/v3/" + infuraId;
const web3 = new Web3(new Web3.providers.HttpProvider(apiKey));

// Input the mnemonic for your wallet
const mnemonicPhrase = "";
const myWallet = ethers.Wallet.fromMnemonic(mnemonicPhrase);

const testPortfolioAddress = "0x7157Ea1F87Cc4CbeE63137D3CB5ecBd44eE1960a";
const deployedContract = new web3.eth.Contract(
  testPortfolioABI,
  testPortfolioAddress
);

async function buy(ethAmountInWei) {
  let setCall = deployedContract.methods.buy().encodeABI();
  const tx = {
    from: myWallet.address,
    to: contractAddress,
    data: setCall,
    value: ethAmountInWei,
  };
  estGas = await web3.eth.estimateGas(tx);
  tx.gas = parseInt(estGas * 1.02);
  const signedTx = await web3.eth.accounts.signTransaction(
    tx,
    myWallet.privateKey
  );
  result = await web3.eth.sendSignedTransaction(signedTx.rawTransaction);
}

async function sell(numFolioCoins) {
  let setCall = deployedContract.methods.sell(numFolioCoins).encodeABI();
  const tx = {
    from: myWallet.address,
    to: contractAddress,
    data: setCall,
  };
  estGas = await web3.eth.estimateGas(tx);
  tx.gas = parseInt(estGas * 1.02);
  const signedTx = await web3.eth.accounts.signTransaction(
    tx,
    myWallet.privateKey
  );
  result = await web3.eth.sendSignedTransaction(signedTx.rawTransaction);
}

// This buys 500 Wei worth of Folio coin, then sells it
var weiToSpend = 500;
var weiFolioCoinRatio = 1000;
var tokensPurchased = weiToSpend * weiFolioCoinRatio;
buy(weiToSpend);
sell(tokensPurchased);
