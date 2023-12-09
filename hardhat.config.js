require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();
require("hardhat-deploy");

const DEPLOYEY = process.env.PRIVATE_KEY;

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.19",
  namedAccounts: {
    deployer: {
      default: 0,
    },
  },
  networks: {
    zkevm: {
      url: `https://rpc.public.zkevm-test.net`,
      accounts: [DEPLOYEY],
    },
  },
};
