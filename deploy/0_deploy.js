module.exports = async ({ getNamedAccounts, deployments, ethers }) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  console.log("\n");

  const MockUSDC = await deploy("MockToken", {
    from: deployer,
    log: true,
    args: ["USD Coin", "USDC"],
  });
  console.log("Deployed USDC at :", MockUSDC.address, "\n");

  const MockUSDT = await deploy("MockToken", {
    from: deployer,
    log: true,
    args: ["USD Tether", "USDT"],
  });
  console.log("Deployed USDT at :", MockUSDT.address, "\n");

  const TF = await deploy("ThunderFi", {
    from: deployer,
    log: true,
    args: [MockUSDC.address, 6],
  });
  console.log("Deployed ThunderFi at :", TF.address, "\n");
};
