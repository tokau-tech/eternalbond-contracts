const TokAu = artifacts.require("TokAu");
const TokAuStarry = artifacts.require("TokAuStarry");
const TokAuTreasurePeriphery = artifacts.require("TokAuTreasurePeriphery");
const TokAuTreasures = artifacts.require("TokAuTreasures");

module.exports = async function(deployer, network, accounts) {
    var tokau = await deployer.deploy(TokAu);
    var tokauStarry = await deployer.deploy(TokAuStarry);
    var tokauTreasurePeriphery = await deployer.deploy(TokAuTreasurePeriphery);
    var tokauTreasures = await deployer.deploy(TokAuTreasures);
    await tokauTreasures.initialize("https://api-testnets.tokau.io/");
}