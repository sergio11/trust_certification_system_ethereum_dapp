// SPDX-License-Identifier: MIT
pragma solidity ^0.7.1;
pragma experimental ABIEncoderV2;
import "../ownable/Ownable.sol";
import "./ITokenManagementContract.sol";
import "../ERC20/ERC20.sol";

contract TokenManagementContract is Ownable, ITokenManagementContract {

    // Token contract instance
    ERC20Basic private token;

    // Default TCS tokens
    uint public DEFAULT_ADMIN_TOKENS = 30;
    uint public DEFAULT_CA_TOKENS = 10;
    uint public DEFAULT_STUDENTS_TOKENS = 3;
    
    mapping(address => bool) private accountsAlreadyProvidedWithInitialFunds;
    mapping(address => ClientRecord) public clients;
    
    constructor() {
        // create ERC20 token with initial supply
        token = new ERC20Basic(2000000000);
    }

    // Provide Initial tokens
    function sendInitialTokenFundsTo(address payable _account, ClientType _clientType) public override onlyOwner accountHasNotAlreadyProvidedWithInitialFunds(_account) {
        // Get Tokens
        uint _tokensToBeProvided;
        if(_clientType == ClientType.ADMIN) { 
            _tokensToBeProvided = DEFAULT_ADMIN_TOKENS;
        } else if (_clientType == ClientType.CA) {
            _tokensToBeProvided = DEFAULT_CA_TOKENS;
        } else {
            _tokensToBeProvided = DEFAULT_STUDENTS_TOKENS;
        }
        require (_tokensToBeProvided <= balanceOf(), "The transaction cannot be completed the requested amount of tokens cannot be satisfied");
        require(token.transfer(_account, _tokensToBeProvided), "The transfer could not be made");
        accountsAlreadyProvidedWithInitialFunds[_account] = true;
        clients[_account].tokensPurchasedCount += _tokensToBeProvided;
        clients[_account].tokensAvailables += _tokensToBeProvided;
        clients[_account].clientType = _clientType;
        clients[_account].isExist = true;
    }

    function getTokenPriceInWei(uint _tokenCount) public override pure returns (uint) {
        return _tokenCount * (10000000000000000 wei);
    }
    
    function balanceOf() public override view returns (uint) {
        return token.balanceOf(address(this));
    }
    
    function getMyTokens() public override view returns (uint) {
        return token.balanceOf(msg.sender);
    }
    
    function getTokens(address _client) public override view returns (uint) {
        return token.balanceOf(_client);
    }
    
    function generateTokens(uint _tokenCount) external override onlyOwner() {
        token.increaseTotalSupply(_tokenCount);
    }
    
    function buyTokens(uint _tokenCount) public override ClientMustExist(msg.sender) payable {
        require (_tokenCount <= balanceOf(), "The transaction cannot be completed the requested amount of tokens cannot be satisfied");
        uint tokenCost = getTokenPriceInWei(_tokenCount);
        require(msg.value >= tokenCost, "Insufficient amount to buy tokens");
        msg.sender.transfer(msg.value - tokenCost);
        token.transfer(msg.sender, _tokenCount);
        clients[msg.sender].tokensPurchasedCount += _tokenCount;
        clients[msg.sender].tokensAvailables += _tokenCount;
    }
    
    function transfer(address _client, address _recipient, uint256 _amount) public override onlyOwner() ClientMustExist(_client) ClientMustExist(_recipient) ClientHasEnoughAvailableTokens(_client, _amount) returns (bool) {
        token.transfer(_client, _recipient, _amount);
        clients[_client].tokensAvailables -= _amount;
        clients[_recipient].tokensAvailables += _amount;
        return true;
    }

    function addTokens(address _recipient, uint256 _amount) public override onlyOwner ClientMustExist(_recipient) returns (bool) { 
        require (_amount <= balanceOf(), "The transaction cannot be completed the requested amount of tokens cannot be satisfied");
        require(token.transfer(_recipient, _amount), "The transfer could not be made");
        clients[_recipient].tokensPurchasedCount += _amount;
        clients[_recipient].tokensAvailables += _amount;
    }

    // Modifiers

    modifier accountHasNotAlreadyProvidedWithInitialFunds(address _account) {
        require(!accountsAlreadyProvidedWithInitialFunds[_account], "Account Has Already Financed");
        _;
    }

    modifier ClientMustExist(address _address) {
        require(clients[_address].isExist, "Client don't exists");
        _;
    }

    modifier ClientHasEnoughAvailableTokens(address _address, uint256 _amount) {
        require(clients[_address].tokensAvailables >= _amount, "Client don't have enought avaliable tokens");
        _;
    }
    
}