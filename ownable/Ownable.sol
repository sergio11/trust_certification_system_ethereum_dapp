// SPDX-License-Identifier: MIT
pragma solidity ^0.7.1;
pragma experimental ABIEncoderV2;

contract Ownable {
    
    address payable private owner;
    
    // Events
    event OnOwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    
    constructor() {
        owner = msg.sender;
    }
    
    function transferOwnership(address payable newOwner) onlyOwner public {
        require(newOwner != address(0));
        emit OnOwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
    
    function owningAuthority() external view returns (address) {
        return owner;
    }
    
    // Allow only owners the check the balance of the contract
    function getBalance() public view onlyOwner returns (uint) {
        return address(this).balance;
    }
    
    function collect() external onlyOwner{
        owner.transfer(address(this).balance);
    }
    
    // Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "You don't have enought permissions to execute this operation");
        _;
    }
  
}