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
    zkevm: {
      url: `https://rpc.public.zkevm-test.net`,
      accounts: [DEPLOYER],
    },
    arbitrum: {
      url: `https://arb1.arbitrum.io/rpc`,
      accounts: [DEPLOYER],
    },
  },
};
