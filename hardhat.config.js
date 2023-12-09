require("@nomicfoundation/hardhat-toolbox");
require("hardhat-deploy");
require("dotenv").config();

const DEPLOYER = process.env.PK_DEPLOYER;
const SELLER = process.env.PK_SELLER;
const PURCHASER = process.env.PK_PURCHASER;

const GOERLI_RPC = process.env.GOERLI_RPC;
const ARBITRUM_RPC = process.env.ARBITRUM_RPC;

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.20",
  namedAccounts: {
    deployer: {
      default: 0,
    },
    seller: {
      default: 1,
    },
    purchaser: {
      default: 2,
    },
  },
  networks: {
    hardhat: {
      chainId: 31337,
    },
    arbitrum: {
      chainId: 42161,
      url: ARBITRUM_RPC,
      accounts: [DEPLOYER, SELLER, PURCHASER],
    },
    goerli: {
      chainId: 5,
      url: GOERLI_RPC,
      accounts: [DEPLOYER, SELLER, PURCHASER],
    },
  },
};
