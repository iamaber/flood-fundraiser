const FloodFund = artifacts.require("FloodFund");

module.exports = async function(deployer, network, accounts) {
  await deployer.deploy(FloodFund);
  const floodFundInstance = await FloodFund.deployed();

  // Set fundraiser addresses (using accounts from Ganache)
  await floodFundInstance.setFundraisers(
    accounts[7],  // Sylhet
    accounts[8],  // Chittagong North
    accounts[9]   // Chittagong South
  );
};