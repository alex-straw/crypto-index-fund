require("@nomiclabs/hardhat-waffle");
require("dotenv").config();

console.log(process.env);
const INFURA_API_KEY = process.env.INFURA_API;
const KOVAN_API_KEY = process.env.KOVAN_API;
const PRIVATE_KEY = process.env.WALLET_PK;

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: "0.8.7",
  networks: {
    rinkeby: {
      url: `${INFURA_API_KEY}`,
      accounts: [`${PRIVATE_KEY}`],
    },
    kovan: {
      url: `${KOVAN_API_KEY}`,
      accounts: [`${PRIVATE_KEY}`],
    },
  },
};
