require("@nomiclabs/hardhat-waffle");
require("dotenv").config();

const RINKEBY_API_KEY = process.env.RINKEBY_API_KEY;
const KOVAN_API_KEY = process.env.KOVAN_API_KEY;
const PRIVATE_KEY = process.env.PRIVATE_KEY;

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
 module.exports = {
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {
    },
    kovan: {
      url: KOVAN_API_KEY,
      accounts: [PRIVATE_KEY]
    },
    rinkeby: {
      url: RINKEBY_API_KEY,
      accounts: [PRIVATE_KEY]
    }
  },
  solidity: {
    compilers: [{version: "0.8.0"},
    {version: "0.8.7"},
    {version: "0.6.6"}],
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts"
  },
  mocha: {
    timeout: 3000000
  }
}
