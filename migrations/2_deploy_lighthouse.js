var Lighthouse = artifacts.require("Lighthouse");
var Gamble = artifacts.require("Gamble");

module.exports = function(deployer, network) {
// Seperates rinkeby network deployment settings from local development testing deploy setttings
  if(network == "rinkeby") {

    var address = '0x613D2159db9ca2fBB15670286900aD6c1C79cC9a';   //address of RNG lighthouse on rinkeby
    deployer.deploy(Gamble, address);

  } else {

    // First deploy the lighthouse, then use the lighthouse's address to deploy gamble. This allows
    // gamble to know which lighthouse to obtain data from.
    deployer.deploy(Lighthouse).then(function() {
      return deployer.deploy(Gamble, Lighthouse.address);
    });

  }
};
