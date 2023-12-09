module.exports = async ({ getNamedAccounts, deployments, ethers }) => {
  const { deploy } = deployments;
  const { deployer, seller, purchaser } = await getNamedAccounts();

  const provider = ethers.provider;
  const signerDeployer = provider.getSigner(deployer);
  // const signerSeller = provider.getSigner(seller);
  // const signerPurchaser = provider.getSigner(purchaser);

  const MockUSDC = await deploy("MockToken", {
    from: deployer,
    args: ["USD Coin", "USDC"],
  });
  console.log("\nDeployed USDC Mocks at   :", MockUSDC.address);

  const MockUSDT = await deploy("MockToken", {
    from: deployer,
    args: ["USD Tether", "USDT"],
  });
  console.log("Deployed USDT at   :", MockUSDT.address);

  const mockUsdc = new ethers.Contract(
    MockUSDC.address,
    MockUSDC.abi,
    signerDeployer
  );
  await mockUsdc.mint(deployer);
  await mockUsdc.mint(seller);
  await mockUsdc.mint(purchaser);

  await deploy("ThunderFi", {
    from: deployer,
    log: true,
    args: [MockUSDC.address, 6],
  });
};
