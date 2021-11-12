import { ethers } from 'ethers'
import Safe, { SafeFactory, EthersAdapter } from '@gnosis.pm/safe-core-sdk' 
import HDWalletProvider from '@truffle/hdwallet-provider'
import dotenv from 'dotenv'
// import ContractBook from '../constants/contracts.json'
import { createRequire } from 'module'
const require = createRequire(import.meta.url)
const ContractBook = require('../constants/contracts.json')

dotenv.config()

const networkConfig = {
    "bscTestNet": {
        name: "bscTestNet",
        provider: `https://data-seed-prebsc-2-s3.binance.org:8545/`,
        networkId: 97,
        devSafe: ContractBook.gnosisSafe.bscTestNet.devSafe
    },
    "bscMainNet": {
        name: "bscMainNet",
        provider: `https://bsc-dataseed.binance.org`,
        networkId: 57,
        projectSafe: ContractBook.gnosisSafe.bscMainNet.project,
        teamSafe: ContractBook.gnosisSafe.bscMainNet.team
    },
    "rinkeby": {
        name: "rinkeby",
        provider: `https://rinkeby.infura.io/v3/${process.env.INFURA_KEY_RINKEBY}`,
        networkId: 4,
        devSafe: ContractBook.gnosisSafe.rinkeby.devSafe
    }
}

const contractNetworkConfig = {
    97: {
        multiSendAddress: "0xA238CBeb142c10Ef7Ad8442C6D1f9E89e07e7761",
        safeMasterCopyAddress: "0xE51abdf814f8854941b9Fe8e3A4F65CAB4e7A4a8",
        safeProxyFactoryAddress: "0xE89ce3bcD35bA068A9F9d906896D3d03Ad5C30EC"
    }
}

const web3Provider = new HDWalletProvider(
    {   //bscTestNet
        privateKeys: [
            process.env.ADMIN_PRIVATE_KEY || '',
            process.env.ADMIN_PRIVATE_KEY1 || '',
            process.env.ADMIN_PRIVATE_KEY2 || '',
        ],
        providerOrUrl: networkConfig.bscTestNet.provider,  //bscTestNet
        // providerOrUrl: networkConfig.rinkeby.provider, //rinkeby
        addressIndex: 0,
    }
)
const provider = new ethers.providers.Web3Provider(web3Provider, {
    name: networkConfig.bscTestNet.name,
    chainId: networkConfig.bscTestNet.networkId
    // name:  networkConfig.rinkeby.name,
    // chainId: networkConfig.rinkeby.networkId
})

const createSafe = async (threshold=2, contractNetworkConfig=null) => {
    try {
        console.log(`given contract network config: ${ JSON.stringify(contractNetworkConfig, null, 2) }`)
        const safeFactory = await SafeFactory.create({ 
            ethAdapter: new EthersAdapter({
                ethers,
                signer: provider.getSigner(0)
            }), 
            contractNetworks: contractNetworkConfig
        })
        const owners = [await provider.getSigner(0).getAddress(), await provider.getSigner(1).getAddress(), await provider.getSigner(2).getAddress()]
        const safeAccountConfig = {
            owners,
            threshold: threshold
        }
        const safeSdk = await safeFactory.deploySafe(safeAccountConfig)
        console.log(`created safe address: ${safeSdk.getAddress()}`)
        return safeSdk
    } catch (error) {
        console.log(`create safe error: ${error}`)
    }
}

const getSafeInstance = async (owner, safeAddress, contractNetworkConfig=null) => {
    try {
        const ethAdapterOwner = new EthersAdapter({
            ethers,
            signer: owner
        })
        const safeSdk = await Safe.default.create({
            ethAdapter: ethAdapterOwner,
            safeAddress: safeAddress,
            contractNetworks: contractNetworkConfig
        })
        console.log(`safe instance address: ${await safeSdk.getAddress()}`)
        return safeSdk
    } catch (error) {
        console.log(`get safe instance error: ${error}`)
    }
}

const basicInfo = async () => {
    // console.log(ContractBook.bscTestNet.OreLockerVault.address)
    // console.log(await owner1.getAddress())
    // console.log(await ethAdapterOwner1.getSignerAddress())
    const safeSdk = await getSafeInstance(provider.getSigner(0), networkConfig.rinkeby.devSafe)
    console.log(await safeSdk.getContractVersion())
}

const signTxOffline = async (safeAddress, owner, tx, contractNetworkConfig=null) => {
    const safeSdk = await getSafeInstance(owner, safeAddress, contractNetworkConfig)
    const singnature = await safeSdk.signTransaction(tx)
    return tx
}

const signTxOnline = async (safeSdk, signer, tx) => {
    const ethAdapterOwnerSigner = new EthersAdapter({ ethers, signer })
    const safeSdkSigner = await safeSdk.connect({ ethAdapter: ethAdapterOwnerSigner, safeAddress: await safeSdk.getAddress() })
    const txHash = await safeSdkSigner.getTransactionHash(tx)
    const approveTxResponse = await safeSdkSigner.approveTransactionHash(txHash)
    await approveTxResponse.transactionResponse?.wait()
    return tx
}

const executeTransaction = async (safeSdk, tx) => {
    const txResponse = await safeSdk.executeTransaction(tx)
    await txResponse.transactionResponse?.wait()
}


const changeThreshold = async (newThreshold) => {
    const safeSdk = await getSafeInstance(provider.getSigner(0), networkConfig.rinkeby.devSafe)
    console.log(`safeSdk obj: ${safeSdk}
                 safeSdk json print: ${JSON.stringify(safeSdk, null, 2)}`)
    var changeThresholdTx = await safeSdk.getChangeThresholdTx(newThreshold)
    // await signTxOffline(networkConfig.rinkeby.devSafe, provider.getSigner(1), changeThresholdTx)
    // await signTxOnline(safeSdk, provider.getSigner(2), changeThresholdTx)
    // await executeTransaction(safeSdk, changeThresholdTx)
}

const bscTestNetExecuteTransaction = async (transaction) => {
    const safeSdk = await getSafeInstance(provider.getSigner(0), networkConfig.bscTestNet.devSafe, contractNetworkConfig)
    const executingTransaction = await safeSdk.createTransaction(transaction)
    console.log(`safe: ${safeSdk.getAddress()} owners: ${await safeSdk.getOwners()}`)
    // await signTxOffline(safeSdk.getAddress(), await provider.getSigner(1), executingTransaction, contractNetworkConfig)
    const executeTxResponse = await safeSdk.executeTransaction(executingTransaction, { //
        gasLimit: 5000000,
        gasPrice: 15*10**9
    })
    console.log(`executeTxResponse: ${ JSON.stringify(executeTxResponse, null, 2) }`)
    await executeTxResponse.transactionResponse?.wait()
}

const main = async () => {
    // const safeSdk = await createSafe() //rinkeby
    // const safeSdk = await createSafe(2, contractNetworkConfig)
    const safeSdk = await getSafeInstance(provider.getSigner(0), networkConfig.bscTestNet.devSafe, contractNetworkConfig)
    console.log(`safeSdk obj: ${safeSdk}
                 safeSdk json print: ${JSON.stringify(safeSdk, null, 2)}`)
    // await changeThreshold(2);
    process.exitCode = 0;
}

const bscTestSetLockerPeriods = async () => {
    const oreLockerVaultSetLockerPeriodsAbi = [
        "function setLockerPeroids(uint[] _periods, uint[] _boostRates)",
    ]
    const setLockerPeriodsInterface = new ethers.utils.Interface(oreLockerVaultSetLockerPeriodsAbi);
    const encodedData = setLockerPeriodsInterface.encodeFunctionData('setLockerPeroids', [
        [60*7, 60*14, 60*28],
        [40, 100, 240]
    ]);
    console.log(`encodedData: ${encodedData}`)
    const tx = [{   //safe proxy executes it
        to: ContractBook.bscTestNet.OreLockerVault.address,
        value: '0x00',
        // safeTxGas: 5000000,
        // gasPrice: 15*10**9,
        data: encodedData
    }]
    await bscTestNetExecuteTransaction(tx)
    process.exitCode = 0;
}

await bscTestSetLockerPeriods()
process.exit()