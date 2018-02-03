// Specifically request an abstraction for Scythereum
var Scythereum = artifacts.require("Scythereum");
var token;

var balance0;
var balance1;
var balance2;
var votes0;
var votes1;
var votes2;
var timeTravel = function (time) {
  return new Promise((resolve, reject) => {
    web3.currentProvider.sendAsync({
      jsonrpc: "2.0",
      method: "evm_increaseTime",
      params: [time], // 86400 is num seconds in day
      id: new Date().getTime()
    }, (err, result) => {
      if(err){ return reject(err) }
      return resolve(result)
    });
  });
}
var mineblock = function(num) {
    var prom;
    for (i=0;i<num;i++) {
        prom = new Promise((resolve, reject) => {
        web3.currentProvider.sendAsync({
            jsonrpc: "2.0",
            method: "evm_mine",
            id: new Date().getTime()
        }, function(err, result) {
          if(err){ return reject(err) }
          return resolve(result)
        });
      });
    }
    return prom;
};
contract('Scythereum', function(accounts) {

  it("migrate should put 1e21 SYTH in the first account and 0 in account 2", function() {
    return Scythereum.deployed().then(function(instance) {
        token = instance;
        return token.balanceOf(accounts[0]);
    }).then(function(bal1) {
        assert.equal(bal1.valueOf(), Math.pow(10,21), "1e21 wasn't in accounts[0]");
        return token.balanceOf(accounts[1]);
    }).then(function(bal2) {
        assert.equal(bal2.valueOf(), 0, "0 wasn't in the accounts[1]");
    });
  });

  it("should send coin correctly", function() {
    var meta;

    // Get initial balances of first and second account.

    var account_zero_starting_balance;
    var account_one_starting_balance;
    var account_zero_ending_balance;
    var account_one_ending_balance;

    var amount = 10;

    return Scythereum.deployed().then(function(instance) {
      token = instance;
      return token.balanceOf.call(accounts[0]);
    }).then(function(balance) {
      account_zero_starting_balance = balance.toNumber();
      return token.balanceOf.call(accounts[1]);
    }).then(function(balance) {
      account_one_starting_balance = balance.toNumber();
      return token.transfer(accounts[1], amount, {from: accounts[0]});
    }).then(function() {
      return token.balanceOf.call(accounts[0]);
    }).then(function(balance) {
      account_zero_ending_balance = balance.toNumber();
      balance0 = balance.toNumber();
      return token.balanceOf.call(accounts[1]);
    }).then(function(balance) {
      account_one_ending_balance = balance.toNumber();
      assert.equal(account_zero_ending_balance, account_zero_starting_balance - amount, "Amount wasn't correctly taken from the sender");
      assert.equal(account_one_ending_balance, account_one_starting_balance + amount, "Amount wasn't correctly sent to the receiver");
    });
  });

  it("should not be able to mint any tokens to account[2]", function() {
    return Scythereum.deployed().then(function(instance) {
        token = instance;
        return token.mintToken(accounts[2],10000);
    }).then(assert.fail)
    .catch(function(err) {
        assert.include(err.message,'not a function','minting of tokens should be an internal function');
    });
  });

  it("should freeze account and prevent transfers", function() {
    return Scythereum.deployed().then(function(instance) {
        token = instance;
        return token.freezeAccount(accounts[0],true);
    }).then(function() {
        return token.transfer(accounts[1], 100);
    }).then(assert.fail)
    .catch(function(err) {
        assert.include(err.message,'invalid opcode','send from frozen account should throw an error');
    });
  });

  var newMemberAward;
  it("should be able to add account[2] as a member and get newMemberAward", function() {
    return Scythereum.deployed().then(function(instance) {
        token = instance;
        return token.newMemberAward.call();
    }).then(function(award) {
        newMemberAward = award;
        return token.addMember(accounts[1]);
    }).then(function() {
        return token.balanceOf(accounts[1]);
    }).then(function(bal1) {
        assert.equal(bal1.valueOf(),newMemberAward.toNumber() , "accounts[2] balance should be newMemberAward" );
    });
  });


});

