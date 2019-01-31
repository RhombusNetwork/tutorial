var HDWalletProvider = require("truffle-hdwallet-provider");
var mnemonic = ""; // Enter the mnemonic for your rinkeby account (testnet deployment only)
module.exports = {

  networks: {
    development: {
      host: "127.0.0.1",
      port: 8545,
      network_id: "*" // Match any network id

    },

    rinkeby: {
      provider: function() {
        return new HDWalletProvider(mnemonic, "https://rinkeby.infura.io/v3/[your infura link here]");
      },
      network_id: 4
    }

  }
};
