// SPDX-License-Identifier: MIT
pragma solidity ^0.7.1;
pragma experimental ABIEncoderV2;

interface ITokenManagementContract {
    
    function sendInitialTokenFundsTo(address payable _account, ClientType _clientType) external;
    function getTokenPriceInWei(uint _tokenCount) external pure returns (uint);
    function buyTokens(uint _tokenCount) external payable;
    function balanceOf() external view returns (uint);
    function getMyTokens() external view returns (uint);
    function getTokens(address _client) external view returns (uint);
    function generateTokens(uint _tokenCount) external;
    function transfer(address _client, address _recipient, uint256 _amount) external returns (bool);
    function addTokens(address _recipient, uint256 _amount) external returns (bool);
    
    // Data Structure
    struct ClientRecord {
        uint tokensPurchasedCount;
        uint tokensAvailables;
        ClientType clientType;
        bool isExist;
    }

    // Client Type Structure
    enum ClientType{ CA, STUDENT, ADMIN }
    
    
}