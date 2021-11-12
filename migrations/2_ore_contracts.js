const web3 = require("web3");
const web3Eth = require("web3-eth");

const EBChef = artifacts.require("EBChef");
const OreMinter = artifacts.require("OreMinter");
const OreLockerVault = artifacts.require("OreLockerVault");

const TokAu = artifacts.require("TokAu");
const TokAuTreasures = artifacts.require("TokAuTreasures");


module.exports = async function (deployer, network, accounts) {
    var contractBook = require('../constants/contracts.json');
    var tokauTokenAddress = "";
    var tokauTreasureBaseUri = "";
    var safeAddress = "";
    var TIMEUNIT = 60;
    if (network == "bscMainNet") {
        TIMEUNIT = 86400;
        tokauTokenAddress = contractBook.bscMainNet.TokAu.address;
        tokauTreasureBaseUri = "https://api.tokau.io/tt/";
    } else if (network == "bscTestNet") {
        tokauTokenAddress = contractBook.bscTestNet.TokAu.address;
        tokauTreasureBaseUri = "https://api-testnets.tokau.io/tt/";
    } else if (network == "rinkeby") {
        tokauTokenAddress = contractBook.rinkeby.TokAu.address;
        tokauTreasureBaseUri = "https://api-testnets.tokau.io/tt/";
    } else {
        await deployer.deploy(TokAu);
        var tokauToken = await TokAu.deployed();
        tokauTokenAddress = tokauToken.address;
    }

    await deployer.deploy(TokAuTreasures);
    var tokauTreasures = await TokAuTreasures.deployed();
    await tokauTreasures.initialize(tokauTreasureBaseUri);

    var oreTokenId = 0;
    var oreLockerVaultEmissionRate = 1;


    // var tokauTreasures = await TokAuTreasures.at(contractBook.bscMainNet.TokAuTreasures.address);
    // var oreMinter = await OreMinter.at(contractBook.rinkeby.OreMinter.address);
    // var ebChef = await EBChef.at(contractBook.bscMainNet.EBChef.address);
    // var oreLockerVault = await OreLockerVault.at(contractBook.bscMainNet.OreLockerVault.address);

    var ebChef = await deployer.deploy(EBChef);
    await ebChef.initialize(0);  // for test

    var oreLockerVault = await deployer.deploy(OreLockerVault);
    await oreLockerVault.initialize(ebChef.address, tokauTokenAddress, oreTokenId, oreLockerVaultEmissionRate);
    await oreLockerVault.setLockerPeroids([TIMEUNIT*7, TIMEUNIT*14, TIMEUNIT*28], [7, 18, 40]); //4000, 5, 17500000, 28

    var oreMinter = await deployer.deploy(OreMinter);
    await oreMinter.initialize(ebChef.address, tokauTreasures.address);

    await tokauTreasures.grantRole(web3.utils.soliditySha3("MINTER_ROLE"), oreMinter.address);

    await ebChef.setMinter(oreMinter.address);
    await ebChef.addVault(oreLockerVault.address);

}