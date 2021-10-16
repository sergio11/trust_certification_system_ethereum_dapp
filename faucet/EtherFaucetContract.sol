// SPDX-License-Identifier: MIT
pragma solidity ^0.7.1;
pragma experimental ABIEncoderV2;
import "../ownable/Ownable.sol";

contract EtherFaucetContract is Ownable {
    
    uint private topupAmountInEthers = 3 ether;
    mapping(address => bool) private accountsAlreadyFunded;
    
    // events
    event OnDeposit(address sender, uint amount);
    event OnGetSeedFunds(address sender, uint amount);
    
    
    // Public API
    function deposit() public onlyOwner payable returns(bool success) {
        emit OnDeposit(msg.sender, msg.value);
        return true;
    }

    function getSeedFunds() public shouldBeHaveFunds accountHasNotAlreadyFunded(msg.sender)  {
        msg.sender.transfer(topupAmountInEthers);
        accountsAlreadyFunded[msg.sender] = true;
        emit OnGetSeedFunds(msg.sender, topupAmountInEthers);
    }

    function sendSeedFundsTo(address payable account) public onlyOwner shouldBeHaveFunds {
        account.transfer(topupAmountInEthers);
        emit OnGetSeedFunds(account, topupAmountInEthers);
    }
    
    function sendFunds(address payable account, uint amount) public onlyOwner shouldBeHaveFunds {
        account.transfer(amount);
    }
    
    // Modifiers
    
    modifier accountHasNotAlreadyFunded(address _account) {
        require(!accountsAlreadyFunded[_account], "Account Has Already Funded");
        _;
    }
    
    modifier shouldBeHaveFunds() {
         require(address(this).balance > 0, "Insuficient Funds");
         _;
    } 
    
}