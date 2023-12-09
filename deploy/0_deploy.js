module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  await deploy("ThunderFi", {
    from: deployer,
    log: true,
    args: ["0xaf88d065e77c8cc2239327c5edb3a432268e5831", 6],
  });
};
