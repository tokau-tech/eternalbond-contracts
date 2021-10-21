
const web3 = require('web3');

const TokAuStarry = artifacts.require("TokAuStarry");
const StarryBatchMintTransferHelper = artifacts.require("StarryBatchMintTransferHelper");

module.exports = async function (deployer, network, accounts) {
    const starry = await TokAuStarry.deployed();
    const helper = await deployer.deploy(StarryBatchMintTransferHelper, starry.address);
}
