var Scythereum = artifacts.require("./Scythereum.sol");

module.exports = function(deployer) {
  //deployer.link(ConvertLib, MetaCoin);
  deployer.deploy(Scythereum, 1000, "Scythes", "CYTH", 10, 2);
};
