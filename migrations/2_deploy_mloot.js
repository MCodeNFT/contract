const MLootContract = artifacts.require("MLoot");

module.exports = async function (deployer, network, accounts) {
    // deployment steps
    await deployer.deploy(MLootContract);
};
