require("@nomicfoundation/hardhat-toolbox");
require("hardhat-deploy");
require("dotenv").config();

const DEPLOYER = process.env.PRIVATE_KEY;

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.20",
  namedAccounts: {
    deployer: {
      default: 0,
    },
  },
  networks: {
    hardhat: {
      chainId: 31337,
    },
    arbitrum: {
      chainId: 42161,
      url: `https://arb1.arbitrum.io/rpc`,
      accounts: [DEPLOYER],
    },
  },
};
