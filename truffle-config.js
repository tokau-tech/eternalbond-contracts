const HDWalletProvider = require('@truffle/hdwallet-provider');

require("dotenv").config();

module.exports = {
  networks: {
    develop: {
      host: "127.0.0.1",
      port: 7545,
      network_id: '5777',
      gas: 7500000,    //defalut block limit 6721975
    },
    bscTestNet: {
      provider: () => new HDWalletProvider({
        privateKeys: [
          process.env.ADMIN_PRIVATE_KEY
        ],
        providerOrUrl: `https://data-seed-prebsc-1-s1.binance.org:8545`,
        addressIndex: 0,
      }),
      networkCheckTimeout: 1000000,
      network_id: 97,
      confirmations: 10,
      timeoutBlocks: 200,
      skipDryRun: true
    },
    bscMainNet: {
      provider: () => new HDWalletProvider({
        privateKeys: [
          process.env.ADMIN_PRIVATE_KEY
        ],
        providerOrUrl: `https://bsc-dataseed.binance.org/`,
        addressIndex: 0,
      }),
      networkCheckTimeout: 1000000,
      network_id: 56,
      confirmations: 10,
      timeoutBlocks: 200,
      skipDryRun: true
    },
    rinkeby: {
      provider: () => new HDWalletProvider({
        privateKeys: [
          process.env.ADMIN_PRIVATE_KEY
        ],
        // mnemonic: {
        //   phrase: process.env.MNEMONIC_RINKEBY,
        // },
        providerOrUrl: `https://rinkeby.infura.io/v3/${process.env.INFURA_KEY_RINKEBY}`,
        addressIndex: 0,
      }),
      network_id: 4,
      skipDryRun: true,
      gas: 8500000,
      gasPrice: 1 * 1000000000,
      timeoutBlocks: 200,      //不添加的话部署可能timeout
    },
    mainnet: {
      provider: () => new HDWalletProvider({
        privateKeys: [
          process.env.ADMIN_PRIVATE_KEY
        ],
        providerOrUrl: `https://mainnet.infura.io/v3/${process.env.INFURA_KEY_MAINNET}`,
        addressIndex: 0,
      }),
      network_id: 1,
      skipDryRun: true,
      gas: 100000,
      gasPrice: 90 * 1000000000,
      timeoutBlocks: 200, 
    },
  },
  compilers: {
    solc: {
      version: "0.8.3",
    },
  },
  // Truffle DB is currently disabled by default; to enable it, change enabled: false to enabled: true
  //
  // Note: if you migrated your contracts prior to enabling this field in your Truffle project and want
  // those previously migrated contracts available in the .db directory, you will need to run the following:
  // $ truffle migrate --reset --compile-all

  db: {
    enabled: false
  }
};
