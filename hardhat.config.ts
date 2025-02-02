import "@matterlabs/hardhat-zksync-deploy";
import "@matterlabs/hardhat-zksync-solc";
import "@matterlabs/hardhat-zksync-verify";
module.exports = {
  zksolc: {
    version: "1.3.5",
    compilerSource: "binary",
    settings: {},
  },
  defaultNetwork: "zkSyncMainnet",

  networks: {
    zkSyncTestnet: {
      url: "https://zksync2-testnet.zksync.dev",
      ethNetwork:
        "https://eth-goerli.g.alchemy.com/v2/shSKR8jKGLh4lCKTN64fKEy55sy_xHGU", // Can also be the RPC URL of the network (e.g. `https://goerli.infura.io/v3/<API_KEY>`)
      zksync: true,
    },
    zkSyncMainnet: {
      url: "https://zksync2-mainnet.zksync.io",
      ethNetwork:
        "https://eth-mainnet.g.alchemy.com/v2/k7Uc6KVzsceZFgNzHLHfnkRRSBO0RUdU",
      zksync: true,
    },
  },
  solidity: {
    version: "0.8.17",
  },
};
