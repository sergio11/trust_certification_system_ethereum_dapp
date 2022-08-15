// SPDX-License-Identifier: MIT
pragma solidity ^0.7.1;
pragma experimental ABIEncoderV2;
import "../ownable/Ownable.sol";

contract EtherFaucetContract is Ownable {
    
    uint private topupAmountInEthers = 3 ether;
    mapping(address => bool) private accountsAlreadyFunded;
    
    // events
    event OnDeposit(address sender, uint amount);
    event OnSendSeedFunds(address sender, address account, uint amount);
    event OnSendFunds(address account, uint amount);
    

    // Public API
    function deposit() public onlyOwner payable returns(bool success) {
        emit OnDeposit(msg.sender, msg.value);
        return true;
    }

    function sendSeedFundsTo(address payable account) public onlyOwner shouldBeHaveFunds accountHasNotAlreadyFunded(account) {
        account.transfer(topupAmountInEthers);
        accountsAlreadyFunded[account] = true;
        emit OnSendSeedFunds(msg.sender, account, topupAmountInEthers);
    }
    
    function sendFunds(address payable account, uint amount) public onlyOwner shouldBeHaveFunds {
        account.transfer(amount);
        emit OnSendFunds(account, amount);
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