
import HDWalletProvider from '@truffle/hdwallet-provider'
import { createRequire } from 'module'
const require = createRequire(import.meta.url)
const Web3 = require('web3');
// const HDWalletProvider = require('@truffle/hdwallet-provider');

const contractBook = require('../constants/contracts.json');
const { BN } = require('@openzeppelin/test-helpers');

require("dotenv").config();

var web3 = new Web3(new HDWalletProvider(
    // {  //bscTestNet
    //     privateKeys: [
    //       process.env.ADMIN_PRIVATE_KEY
    //     ],
    //     providerOrUrl: `https://data-seed-prebsc-2-s3.binance.org:8545/`,
    //     addressIndex: 0,
    // }
    {  //bscMainNet
        privateKeys: [
          process.env.ADMIN_PRIVATE_KEY
        ],
        providerOrUrl: `https://bsc-dataseed.binance.org/`,
        addressIndex: 0,
      }
));

const grantRole = async () => {
    var tokauTreasures = new web3.eth.Contract(require('../build/contracts/TokAuTreasures.json').abi, contractBook.bscTestNet.TokAuTreasures.address);
    await tokauTreasures.grantRole(web3.utils.soliditySha3("MINTER_ROLE"), '0x4eb38bC24370c4F796bfa7C68c1781F20b683b3B');
}

const oreLockerOwnershipTransfer = async (book, safeAddress) => {
    var ebChef = new web3.eth.Contract(require('../build/contracts/EBChef.json').abi, book.EBChef.address);
    var oreMinter = new web3.eth.Contract(require('../build/contracts/OreMinter.json').abi, book.OreMinter.address);
    var tokau = new web3.eth.Contract(require('../build/contracts/TokAu.json').abi, book.TokAu.address);
    // var tokauTreasures = new web3.eth.Contract(require('../build/contracts/TokAuTreasures.json').abi, book.TokAuTreasures.address); // not ownable
    var tokauStarry = new web3.eth.Contract(require('../build/contracts/TokAuStarry.json').abi, book.TokAuStarry.address);
    var tokauTreasurePeriphery = new web3.eth.Contract(require('../build/contracts/TokAuTreasurePeriphery.json').abi, book.TokAuTreasurePeriphery.address);
    var oreLockerVault = new web3.eth.Contract(require('../build/contracts/OreLockerVault.json').abi, book.OreLockerVault.address);


    console.log(`tokauTreasurePeriphery owner: ${await tokauTreasurePeriphery.methods.owner().call()}`);
    console.log(`tokauStarry owner: ${await tokauStarry.methods.owner().call()}`);
    // console.log(`ebChef owner: ${await ebChef.methods.owner().call()}`);
    // console.log(`oreMinter owner: ${await oreMinter.methods.owner().call()}`);
    // console.log(`oreLockerVault owner: ${await oreLockerVault.methods.owner().call()}`);
    
    await transferOwnership(tokauTreasurePeriphery, "0x9dd19e479de6d8d28ff837ca9a00dfd7b3c3684c", safeAddress);
    await transferOwnership(tokauStarry, "0x9dd19e479de6d8d28ff837ca9a00dfd7b3c3684c", safeAddress);
    // await transferOwnership(ebChef, "0x4eb38bC24370c4F796bfa7C68c1781F20b683b3B", safeAddress);
    // await transferOwnership(oreMinter, "0x4eb38bC24370c4F796bfa7C68c1781F20b683b3B", safeAddress);
    // await transferOwnership(oreLockerVault, "0x4eb38bC24370c4F796bfa7C68c1781F20b683b3B", safeAddress);
}

const transferOwnership = async (contract, from, newOwner) => {
    try {
        console.log(`before, transfering contract-${contract.address} owner from ${from} to ${newOwner}`);
        await contract.methods.transferOwnership(newOwner).send({ 
            from: from, 
            gas: 200000, 
            gasPrice: 10*10**9
        }).on('receipt', (receipt) => {
            console.log(receipt);
        }).on('error', (error) => {
            console.log(error);
        });
    } catch (error) {
        console.log(`error: ${error}`);
    }
}

const oreLockerVaultChangePeriods = async (book, from) => {
    var oreLockerVault = new web3.eth.Contract(require('../build/contracts/OreLockerVault.json').abi, book.OreLockerVault.address);
    var TIMEUNIT = 86400;
    try {
        await oreLockerVault.methods.setLockerPeroids([TIMEUNIT*7, TIMEUNIT*14, TIMEUNIT*28], [7, 14, 40]).send({
            from: from, 
            gas: 8000000, 
            gasPrice: 10*10**9
        }).on('error', (error) => {
            console.log(`error: ${error}`);
        });
        process.exitCode = 0;
    } catch (error) {
        console.log(`catch error: ${error}`);
    }
}

const oreLockerVaultParameters = (buybackAmount, buybackOrePrice, targetAPY, tokauAmountPerU, eventLastTime) => {
    const buybackTotalValue = buybackAmount * buybackOrePrice;
    const targetTokauValueLock = buybackTotalValue / (eventLastTime/365*targetAPY/100);
    const targetTokauAmountLock = targetTokauValueLock * tokauAmountPerU;
    const orePerDay = buybackAmount / eventLastTime;

    // const boostRateNormal = targetTokauAmountLock / eventLastTime / 10**9
    const boostRateNormal = buybackAmount * 10**11 / targetTokauAmountLock
    console.log(`
        buybackTotalValue: ${buybackTotalValue}
        targetTokauValueLock: ${targetTokauValueLock}
        targetTokauAmountLock: ${targetTokauAmountLock} 
        orePerDay: ${orePerDay}
        boostRateNormal: ${boostRateNormal}
        boostRateSmall(1/2): ${boostRateNormal/2*0.8}
        boostRateBig(1/2): ${boostRateNormal*2*1.2}`)
}
// oreLockerVaultParameters(4000, 5, 20, 17500000, 28)
// oreLockerVaultParameters(10000, 5, 20, 17500000, 56)

await oreLockerOwnershipTransfer(contractBook.bscMainNet, contractBook.gnosisSafe.bscMainNet.project);
// await oreLockerVaultChangePeriods(contractBook.bscMainNet, "0x4eb38bC24370c4F796bfa7C68c1781F20b683b3B");
process.exit();