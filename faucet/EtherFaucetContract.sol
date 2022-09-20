// SPDX-License-Identifier: MIT
pragma solidity ^0.7.1;
pragma experimental ABIEncoderV2;
import "../ownable/Ownable.sol";
import "./IEtherFaucetContract.sol";

contract EtherFaucetContract is Ownable, IEtherFaucetContract {
    
    uint private initialAmountInEthers = 3 ether;
    mapping(address => bool) private accountsAlreadyFunded;
    
    // Public API
    function deposit() public override onlyOwner payable returns(bool success) {
        emit OnDeposit(msg.sender, msg.value);
        return true;
    }

    function getInitialAmount() public override view onlyOwner returns(uint amount) {
        return initialAmountInEthers;
    }

    function setInitialAmount(uint amount) public override onlyOwner {
        initialAmountInEthers = amount;
    }

    function sendSeedFundsTo(address payable account) public override onlyOwner shouldBeHaveFunds accountHasNotAlreadyFunded(account) {
        account.transfer(initialAmountInEthers);
        accountsAlreadyFunded[account] = true;
        emit OnSendSeedFunds(msg.sender, account, initialAmountInEthers);
    }
    
    function sendFunds(address payable account, uint amount) public override onlyOwner shouldBeHaveFunds {
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