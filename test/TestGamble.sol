pragma solidity ^0.5.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/Gamble.sol";
import "../contracts/Lighthouse.sol";

contract TestGamble{

// Create new instances of smart contracts to perform tests on.
  Lighthouse newlighthouse = new Lighthouse();
  Gamble newgamble = new Gamble(ILighthouse(address(newlighthouse)));

// Give this test contract 5 ether to work with (sent from account[0] in ganache)
  uint public initialBalance = 10 ether;

// Create the value and nonce we will be writing into the lighthouse
  uint dataValue = 6;
  uint nonce = 1234;
// Global variable to track successful ether withdraw from Gamble
  bool paid = false;

  function() external payable {
    paid = true;    // Logs successful withdraw
  }

  /* -------------------------------- Lighthouse tests ---------------------------- */

// Tests if I can write a value (6) into the lighthouse
  function testWrite() public {

    newlighthouse.write(dataValue, nonce);

    uint luckyNum = 0;
    bool ok = false;

    (luckyNum, ok) = newlighthouse.peekData();

    Assert.equal(luckyNum, dataValue, "write failed");
  }


  /* -------------------------------- Ether Transfer tests ---------------------------- */

  function testSendEther() public{

// Deposits 3 ether then checks to ensure deposit successful -- balance has ether
     newgamble.deposit.value(7 ether)(address(this));
     uint balance = newgamble.checkBalance(address(this));

     Assert.isNotZero(balance, "No money in Gamble");
   }

// Tests if there is exactly 3 ether deposited
   function testEtherAmount() public{
     uint balance = newgamble.checkBalance(address(this));
     uint sevenEther = 7 ether;
     Assert.equal(balance, sevenEther, "Did not deposit 7 Ether");
   }

// Tests that this contract address is added to accounts array
   function testNumAccounts() public{
     uint NA = newgamble.checkNumAccounts();
     uint one = 1;
     Assert.equal(NA, one, "Number of accounts is not one");
   }

   function testAccountRegister() public{
     uint index = (newgamble.checkNumAccounts() - 1);
     address ADDR = newgamble.checkAccounts(index);
     address thisAddress = address(this);
     Assert.equal(ADDR, thisAddress, "Incorrect address saved");
   }

// Tests that accounts array has a limit of 20 users
   function testAccountLength() public{
     uint accLen = newgamble.checkAccountLength();
     uint actualLen = 20;
     Assert.equal(accLen, actualLen, "Account Length is wrong");
   }

/* -------------------------------- Gamble tests ---------------------------- */

// Sets up a gamble scenario where user loses. Checks successful ether transfer into toBet, and dice roll
   function testGamble() public{
     newgamble.gamble(address(this), 5 ether, 5);

     uint balance = newgamble.checkBalance(address(this));
     uint remainingEther = 2 ether;
     Assert.equal(balance, remainingEther, "Balances should have two ether after transfer");

     uint bet = newgamble.checkBet(address(this));
     uint fiveEther = 5 ether;
     Assert.equal(bet, fiveEther, "toBet does not have five ether");

     uint chosenNumber = newgamble.checkNumber(address(this));
     uint five = 5;
     Assert.equal(chosenNumber, five, "Number selected is not 5");
   }

   function testDiceRoll() public{
     newgamble.diceRoll();

     uint bet = newgamble.checkBet(address(this));
     uint zeroEther = 0 ether;
     Assert.equal(bet, zeroEther, "toBet should have lost its ether");

     uint balance = newgamble.checkBalance(address(this));
     uint remainingEther = 2 ether;
     Assert.equal(balance, remainingEther, "Balances ether amount changed");
   }

// Sets up a winning gamble scenario like above
   function testGambleWin() public{
     newgamble.gamble(address(this), 1 ether, 6);

     uint balance = newgamble.checkBalance(address(this));
     uint remainingEther = 1 ether;
     Assert.equal(balance, remainingEther, "Balances should have one ether after transfer");

     uint bet = newgamble.checkBet(address(this));
     uint oneEther = 1 ether;
     Assert.equal(bet, oneEther, "toBet does not have one ether");

     uint chosenNumber = newgamble.checkNumber(address(this));
     uint six = 6;
     Assert.equal(chosenNumber, six, "Number selected is not 6");
   }

    function testDiceRollWin() public{
      newgamble.diceRoll();

      uint bet = newgamble.checkBet(address(this));
      uint zeroEther = 0 ether;
      Assert.equal(bet, zeroEther, "toBet should have lost its ether");

      uint balance = newgamble.checkBalance(address(this));
      uint remainingEther = 7 ether;      //1 + 6
      Assert.equal(balance, remainingEther, "Balances ether amount incorrect");
    }

// Tests successful withdraw from the Gamble smart contract
    function testWithdraw() public{
      newgamble.withdraw(address(this));

      uint balance = newgamble.checkBalance(address(this));
      uint remainingEther = 0 ether;
      Assert.equal(balance, remainingEther, "Balances ether amount incorrect");

      Assert.isTrue(paid, "This test contract account was not paid");
      paid = false;

    }

}
