// SPDX-License-Identifier: MIT
pragma solidity ^0.7.1;
pragma experimental ABIEncoderV2;

interface IEtherFaucetContract {

    function deposit() external payable returns(bool success);
    function getInitialAmount() external view returns(uint amount);
    function setInitialAmount(uint amount) external;
    function sendSeedFundsTo(address payable account) external;
    function sendFunds(address payable account, uint amount) external;
    
    // events
    event OnDeposit(address sender, uint amount);
    event OnSendSeedFunds(address sender, address account, uint amount);
    event OnSendFunds(address account, uint amount);
}