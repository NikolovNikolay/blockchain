var ConvertLib = artifacts.require("./ConvertLib.sol");
var MetaCoin = artifacts.require("./MetaCoin.sol");
var Splitter = artifacts.require("./Splitter.sol");

module.exports = function(deployer) {
  deployer.deploy(Splitter);
};
