const MCodeContract = artifacts.require("MCode");

module.exports = async function (deployer, network, accounts) {
    // deployment steps
    await deployer.deploy(MCodeContract);
};
