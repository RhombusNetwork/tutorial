pragma solidity ^0.5.0;

import "../contracts/Ilighthouse.sol";

contract Gamble {

    ILighthouse  public myLighthouse;        // Lighthouse to obtain a random number

    address[20] public accounts;             // Array of users registered
    uint public numAccounts = 0;             // Should be <= 19, this holds number of registered users

    mapping(address => uint) public balances;     // Stores users deposited ether in a wallet
    mapping(address => uint) public toBet;        // Holds ether users have decided to gamble on an upcoming dice roll
    mapping(address => uint) public chosenNumber; // Holds the users chosen number to bet on in an upcoming dice roll

    constructor(ILighthouse _myLighthouse) public {
        myLighthouse = _myLighthouse;
    }

// Pass in sender address manually because truffle proxy contracts interfer with msg.sender
    function deposit(address msgSender) external payable {

      bool exists = false;
      for(uint i = 0; i < numAccounts; i++){
        if( accounts[i] == msgSender){
          exists = true;
          break;
        }
      }

      if(exists == false){
        accounts[numAccounts] = msgSender;
        numAccounts++;
      }

      balances[msgSender] += msg.value;
    }

// Allows users to withdraw all their ether
    function withdraw(address payable msgSender) public {
      uint amount = balances[msgSender];
      balances[msgSender] = 0;
      msgSender.call.value(amount).gas(20000)("");    // fallback function logs withdraw in a storage write, requires 20000 gas
    }


// Functions to display the internal state
    function checkAccountLength() public returns(uint) {
      return accounts.length;
    }

    function checkNumAccounts() public returns(uint) {
      return numAccounts;
    }

    function checkAccounts(uint index) public returns(address) {
      require(index < 20, "No more than 20 accounts can be registered at a time");
      return accounts[index];
    }

    function checkBalance(address msgSender) public returns(uint) {
      return balances[msgSender];
    }

    function checkBet(address msgSender) public returns(uint) {
      return toBet[msgSender];
    }

    function checkNumber(address msgSender) public returns(uint) {
      return chosenNumber[msgSender];
    }

// User places a bet on a number they think will win the dice roll
    function gamble(address msgSender, uint money, uint number) public {
      balances[msgSender] -= money;
      toBet[msgSender] += money;
      chosenNumber[msgSender] = number;
    }

// Rolls the dice for all players who bet on this round, giving a 6x return if they win
    function diceRoll() public {
      uint winningNumber;
      bool ok;
      (winningNumber,ok) = myLighthouse.peekData(); // obtain random number from Rhombus Lighthouse

      for(uint i = 0; i < numAccounts; i++){
        if( toBet[accounts[i]] != 0 && chosenNumber[accounts[i]] == winningNumber){
          balances[accounts[i]] += toBet[accounts[i]] * 6;
        }
        toBet[accounts[i]] = 0;
      }
    }

}
