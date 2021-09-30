const web3 = require("web3");

const EBChef = artifacts.require("EBChef");
const OreMinter = artifacts.require("OreMinter");
const OreLockerVault = artifacts.require("OreLockerVault");

const TokAu = artifacts.require("TokAu");
const TokAuTreasures = artifacts.require("TokAuTreasures");

module.exports = async function (deployer, network, accounts) {
    var tokauTokenAddress = "";
    if (network == "bscMainNet") {
        tokauTokenAddress = "0xC409eC8a33f31437Ed753C82EEd3c5F16d6D7e22";
    } else if (network == "bscTestNet") {
        tokauTokenAddress = "0xd08f0B68400C4DD2e15BC2d55a3b26536C9F6E6f";
    } else {
        var tokauToken = await TokAu.deployed();
        tokauTokenAddress = tokauToken.address;
    }

    var tokauTreasures = await TokAuTreasures.deployed();

    var oreTokenId = 0;
    var oreLockerVaultEmissionRate = 1;

    var ebChef = await deployer.deploy(EBChef);
    await ebChef.initialize(0);  // for test
    var oreMinter = await deployer.deploy(OreMinter);
    await oreMinter.initialize(ebChef.address, tokauTreasures.address);
    await tokauTreasures.grantRole(web3.utils.soliditySha3("MINTER_ROLE"), oreMinter.address);

    var oreLockerVault = await deployer.deploy(OreLockerVault);
    await oreLockerVault.initialize(ebChef.address, tokauToken.address, oreTokenId, oreLockerVaultEmissionRate);
    await ebChef.addVault(oreLockerVault.address);
}