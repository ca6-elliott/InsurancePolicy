const Insurance = artifacts.require("Insurance");

module.exports = async function (deployer) {
  await deployer.deploy(Insurance);
  const insurance = await Insurance.deployed();
  console.log("Insurance contract deployed at:", insurance.address);
};
