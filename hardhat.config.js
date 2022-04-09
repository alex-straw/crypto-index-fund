require("@nomiclabs/hardhat-waffle");
require("dotenv").config();

const RINKEBY_API_KEY = process.env.RINKEBY_API_KEY;
const KOVAN_API_KEY = process.env.KOVAN_API_KEY;
const PRIVATE_KEY = process.env.PRIVATE_KEY;

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: "0.8.7",
  networks: {
    rinkeby: {
      url: `${RINKEBY_API_KEY}`,
      accounts: [`${PRIVATE_KEY}`],
    },
    kovan: {
      url: `${KOVAN_API_KEY}`,
      accounts: [`${PRIVATE_KEY}`],
    },
  },
  mocha: {
    timeout: 40000
  }
};
