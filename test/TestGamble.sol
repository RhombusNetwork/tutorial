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

// Global variable to track successful ether withdraw from Gamble
  bool paid = false;

  function() external payable {
    paid = true;    // Logs successful withdraw
  }


/* ----- Sample test cases of different lighthouse return values (int, decimal, string) ----- */

  /* Writes the current Amazon stock price ($1588.22 USD) into the lighthouse,
     which should be interpreted as an integer with 18 decimal places
     To get the stock value, take the value from the lighthouse, and divide by 1e18. */
    function testWriteDecimal() public {

      uint stockValue = 0x79656c6c6f77;  // Writes the value in Hex. Corresponds to 1588.22 as a decimal value
      uint nonce = 1234;
      newlighthouse.write(stockValue, nonce);

  // Checks that contracts are able to read an integer value from the lighthouse corresponding to the hex value written
  // The value read here must be divided manually by 1e18 to obtain the stock price in order to be used
      uint readValue = 0;
      bool ok = false;
      (readValue, ok) = newlighthouse.peekData();

      Assert.equal(readValue, stockValue, "write failed");
    }

  /* Writes the current New York City temperature (34 degrees F) into the lighthouse */
    function testWriteInt() public {

      uint NYCtemp = 0x22; // Corresponds to 34 degrees as a decimal value
      uint nonce = 1234;
      newlighthouse.write(NYCtemp, nonce);

      uint readValue = 0;
      bool ok = false;
      (readValue, ok) = newlighthouse.peekData();

      Assert.equal(readValue, NYCtemp, "write failed");
    }

  /* Writes a random color (or any string) into the lighthouse,
     which should be interpreted as a byte array representation of a color.
     To get the color (or string), take the uint value from the lighthouse, convert it to hex, and then convert to a byte array.
     *** The string derived can only be maximum of 16 ASCII characters */
    function testWriteColor() public {

      uint color = 0x626c7565;    // A hex representation of the color 'blue'
      uint nonce = 1234;
      newlighthouse.write(color, nonce);

  // Checks that contracts are able to read an integer value from the lighthouse corresponding to the hex value written
  // The value read here must be converted manually to a byte array representation of a string to be useful
      uint readColor = 0;
      bool ok = false;
      (readColor, ok) = newlighthouse.peekData();

      Assert.equal(readColor, color, "write failed");
    }


/* -------------------------------- Lighthouse tests ---------------------------- */

  // Tests if I can write a dice value (6) into the lighthouse
    function testWrite() public {

  // Create the value and nonce we will be writing into the lighthouse
      uint dataValue = 6;
      uint nonce = 1234;

      require(dataValue < 7, "Lighthouse dice roll outcome must be 1-6");
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

// Tests if there is exactly 7 ether deposited
   function testEtherAmount() public{
     uint balance = newgamble.checkBalance(address(this));
     Assert.equal(balance, 7 ether, "Did not deposit 7 Ether");
   }

// Tests that this contract address is added to accounts array
   function testNumAccounts() public{
     uint NA = newgamble.checkNumAccounts();
     Assert.equal(NA, 1, "Number of accounts is not one");
   }

   function testAccountRegister() public{
     uint index = (newgamble.checkNumAccounts() - 1);
     address ADDR = newgamble.checkAccounts(index);
     Assert.equal(ADDR, address(this), "Incorrect address saved");
   }

// Tests that accounts array has a limit of 20 users
   function testAccountLength() public{
     uint accLen = newgamble.checkAccountLength();
     Assert.equal(accLen, 20, "Account Length is wrong");
   }

/* -------------------------------- Gamble tests ---------------------------- */

// Sets up a gamble scenario where user loses. Checks successful ether transfer into toBet, and dice roll
   function testGamble() public{
     newgamble.gamble(address(this), 5 ether, 5);

     uint balance = newgamble.checkBalance(address(this));
     Assert.equal(balance, 2 ether, "Balances should have two ether after transfer");

     uint bet = newgamble.checkBet(address(this));
     Assert.equal(bet, 5 ether, "toBet does not have five ether");

     uint chosenNumber = newgamble.checkNumber(address(this));
     Assert.equal(chosenNumber, 5, "Number selected is not 5");
   }

   function testDiceRoll() public{
     newgamble.diceRoll();

     uint bet = newgamble.checkBet(address(this));
     Assert.equal(bet, 0 ether, "toBet should have lost its ether");

     uint balance = newgamble.checkBalance(address(this));
     Assert.equal(balance, 2 ether, "Balances ether amount changed");
   }

// Sets up a winning gamble scenario like above
   function testGambleWin() public{
     newgamble.gamble(address(this), 1 ether, 6);

     uint balance = newgamble.checkBalance(address(this));
     Assert.equal(balance, 1 ether, "Balances should have one ether after transfer");

     uint bet = newgamble.checkBet(address(this));
     Assert.equal(bet, 1 ether, "toBet does not have one ether");

     uint chosenNumber = newgamble.checkNumber(address(this));
     Assert.equal(chosenNumber, 6, "Number selected is not 6");
   }

    function testDiceRollWin() public{
      newgamble.diceRoll();

      uint bet = newgamble.checkBet(address(this));
      Assert.equal(bet, 0 ether, "toBet should have lost its ether");

      uint balance = newgamble.checkBalance(address(this));
      uint remainingEther = 7 ether;      //1 from before + 6 from win
      Assert.equal(balance, remainingEther, "Balances ether amount incorrect");
    }

// Tests successful withdraw from the Gamble smart contract
    function testWithdraw() public{
      newgamble.withdraw(address(this));

      uint balance = newgamble.checkBalance(address(this));
      Assert.equal(balance, 0 ether, "Balances ether amount incorrect");

      Assert.isTrue(paid, "This test contract account was not paid");
      paid = false;

    }


}
