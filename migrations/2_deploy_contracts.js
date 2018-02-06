var Scythereum = artifacts.require("./Scythereum.sol");

module.exports = function(deployer) {
  //deployer.link(ConvertLib, MetaCoin);
  deployer.deploy(Scythereum, "Scythes", "CYTH", 10, 4);
};
