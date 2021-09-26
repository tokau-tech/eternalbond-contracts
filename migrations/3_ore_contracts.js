
const EBChef = artifacts.require("EBChef");
const OreMinter = artifacts.require("OreMinter");
const OreLockerVault = artifacts.require("OreLockerVault");

const TokAu = artifacts.require("TokAu");
const TokAuTreasures = artifacts.require("TokAuTreasures");

module.exports = async function (deployer, network, accounts) {
    var tokauToken = await TokAu.deployed();
    var tokauTreasures = await TokAuTreasures.deployed();

    var oreTokenId = 0;
    var oreLockerVaultEmissionRate = 1;

    var ebChef = await deployer.deploy(EBChef);
    await ebChef.initialize(0);  // for test
    var oreMinter = await deployer.deploy(OreMinter);
    await oreMinter.initialize(ebChef.address, tokauTreasures.address);
    var oreLockerVault = await deployer.deploy(OreLockerVault);
    await oreLockerVault.initialize(ebChef.address, tokauToken.address, oreTokenId, oreLockerVaultEmissionRate);
}