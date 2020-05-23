const Gamble = artifacts.require("Gamble");
const Lighthouse = artifacts.require("Lighthouse");

contract("GambleTestsJS", function( accounts ) {
  // Simulates a Rhombus Lighthouse by putting the "Random Number" of 6 inside
  it("Write a value into lighthouse", function() {
    let dataValue = 6;
    let nonce = 1234;

    let lighthouse;

    let luckyNum = 0;
    let ok = false;

    return Lighthouse.deployed().then( function(instance) {
      lighthouse = instance;

      lighthouse.write(dataValue, nonce);
    })
    .then( function(){
      lighthouse.peekData().then( function (result){
        luckyNum = result[0];
        ok = result[1];
      });
    })

    assert.equal( dataValue, luckyNum, "write failed");
  });

  // An account deposits ether into my Gamble Smart contract
  it("Can send ether", function(){
    let gamble;
    let balance = 50;
    const address = accounts[0];

    return Gamble.deployed().then( function(instance){
      gamble = instance;

      gamble.deposit( accounts[0], {value: 7e+6, from: accounts[0] });

      return gamble.checkBalance( address );
    })

    .then( function(returned){
      balance = returned.toNumber();

      assert.equal( balance, 7e+6, "transfer failed");
    })
  });

  // That account is registered into my accounts array as an user
  it("Can register accounts", function(){
    let gamble;
    let numAccounts
    let accountAddress;

    return Gamble.deployed().then( function(instance){
      gamble = instance;

      return gamble.checkNumAccounts();
    })

    .then( function(returned){
      numAccounts = returned.toNumber();

      assert.equal( numAccounts, 1, "Number of accounts is not 1");
      return gamble.checkAccounts(0);
    })

    .then( function(returned){
      accountAddress = returned;

      assert.equal( accountAddress, accounts[0], "Registered incorrect account address");
    })
  });

  // An user decides to place his bet -- outcome is a loss
  it("Can gamble and lose", function(){
    let gamble;

    return Gamble.deployed().then( function(instance){
      gamble = instance;
      gamble.gamble(accounts[0], 5e+6, 5);
      return gamble.checkBalance(accounts[0]);
    })

    .then( function(balance){
      assert.equal( balance, 2e+6, "Balances should have 2 ether left after placing bet")
      return gamble.checkBet(accounts[0]);
    })

    .then( function(toBet){
      assert.equal( toBet, 5e+6, "toBet should have 5 ether placed")
      return gamble.checkNumber(accounts[0]);
    })

    .then( function(chosenNumber){
      assert.equal( chosenNumber, 5, "The number stored should 5")

      gamble.diceRoll();
      return gamble.checkBet(accounts[0]);
    })

    .then( function(toBet){
      assert.equal( toBet, 0, "toBet should have lost its ether after dice roll and lose")
      return gamble.checkBalance(accounts[0]);
    })

    .then( function(balance){
      assert.equal( balance, 2e+6, "Balance should not have gained ether after dice roll lose")
    })
  });

  // An user decides to place a bet -- outcome is a win
  it("Can gamble and win", function(){
    let gamble;

    return Gamble.deployed().then( function(instance){
      gamble = instance;
      gamble.gamble(accounts[0], 1e+6, 6);
      return gamble.checkBalance(accounts[0]);
    })

    .then( function(balance){
      assert.equal( balance, 1e+6, "Balances should have 1 ether left after placing bet")
      return gamble.checkBet(accounts[0]);
    })

    .then( function(toBet){
      assert.equal( toBet, 1e+6, "toBet should have 1 ether placed")
      return gamble.checkNumber(accounts[0]);
    })

    .then( function(chosenNumber){
      assert.equal( chosenNumber, 6, "The number stored should be 6")

      gamble.diceRoll();
      return gamble.checkBet(accounts[0]);
    })

    .then( function(toBet){
      assert.equal( toBet, 0, "toBet should have lost its ether after dice roll and win")
      return gamble.checkBalance(accounts[0]);
    })

    .then( function(balance){
      assert.equal( balance, 7e+6, "Balance should have gained ether after dice roll win, 1 + 6 = 7")
    })
  });

  // An user decides to withdraw all their ether out of my Gamble contract
  it("Can withdraw ether", function(){
    let gamble;
    let initialBalance;
    let finalBalance;

    return Gamble.deployed().then( function(instance){
      gamble = instance;

      return gamble.checkBalance(accounts[0]);
    })

    .then(function(returned){
      initialBalance = returned;
      assert.equal( initialBalance, 7e+6, "Balance should still be 7 ether")

      gamble.withdraw(accounts[0]);
      return gamble.checkBalance(accounts[0]);
    })

    .then( function(returned){
      finalBalance = returned;
      assert.equal( finalBalance, 0, "Balance should have been withdrawn and is now 0 ether")
    })

  });

});
