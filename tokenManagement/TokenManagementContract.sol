// SPDX-License-Identifier: MIT
pragma solidity ^0.7.1;
pragma experimental ABIEncoderV2;
import "../ownable/Ownable.sol";
import "./ITokenManagementContract.sol";
import "../ERC20/ERC20.sol";

contract TokenManagementContract is Ownable, ITokenManagementContract {
    
    // Token contract instance
    ERC20Basic private token;
    
    mapping(address => ClientRecord) public clients;
    
    constructor() {
        // create ERC20 token with initial supply
        token = new ERC20Basic(20000);
    }
    
    function getTokenPriceInWeis(uint _tokenCount) public override pure returns (uint) {
        return _tokenCount * (25 wei);
    }
    
    function balanceOf() public override view returns (uint) {
        return token.balanceOf(address(this));
    }
    
    function getMyTokens() public override view returns (uint) {
        return token.balanceOf(msg.sender);
    }
    
    function getTokens(address client) public override view returns (uint) {
        return token.balanceOf(client);
    }
    
    function generateTokens(uint _tokenCount) external override onlyOwner() {
        token.increaseTotalSupply(_tokenCount);
    }
    
    function buyTokens(uint _tokenCount)  public override payable {
        require (_tokenCount <= balanceOf(), "The transaction cannot be completed the requested amount of tokens cannot be satisfied");
        uint tokenCost = getTokenPriceInWeis(_tokenCount);
        require(msg.value >= tokenCost, "Insufficient amount to buy tokens");
        msg.sender.transfer(msg.value - tokenCost);
        token.transfer(msg.sender, _tokenCount);
        clients[msg.sender].tokensPurchasedCount += _tokenCount;
        clients[msg.sender].tokensAvailables += _tokenCount;
    }
    
    function transfer(address client, address recipient, uint256 amount) public override returns (bool) {
        token.transfer(client, recipient, amount);
        clients[client].tokensAvailables -= amount;
        return true;
    }
    
}