const TokAu = artifacts.require("TokAu");
const TokAuStarry = artifacts.require("TokAuStarry");
const TokAuTreasurePeriphery = artifacts.require("TokAuTreasurePeriphery");
const TokAuTreasures = artifacts.require("TokAuTreasures");

module.exports = async function(deployer) {
    await deployer.deploy(TokAu);
    await deployer.deploy(TokAuStarry);
    await deployer.deploy(TokAuTreasurePeriphery);
    await deployer.deploy(TokAuTreasures);
}