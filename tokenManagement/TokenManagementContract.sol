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
    function sendInitialTokenFundsTo(address payable account, ClientType clientType) public override onlyOwner accountHasNotAlreadyProvidedWithInitialFunds(account) {
        // Get Tokens
        uint _tokensToBeProvided;
        if(clientType == ClientType.ADMIN) { 
            _tokensToBeProvided = DEFAULT_ADMIN_TOKENS;
        } else if (clientType == ClientType.CA) {
            _tokensToBeProvided = DEFAULT_CA_TOKENS;
        } else {
            _tokensToBeProvided = DEFAULT_STUDENTS_TOKENS;
        }
        require (_tokensToBeProvided <= balanceOf(), "The transaction cannot be completed the requested amount of tokens cannot be satisfied");
        require(token.transfer(account, _tokensToBeProvided), "The transfer could not be made");
        accountsAlreadyProvidedWithInitialFunds[account] = true;
        clients[account].tokensPurchasedCount += _tokensToBeProvided;
        clients[account].tokensAvailables += _tokensToBeProvided;
        clients[account].clientType = clientType;
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
    
    function getTokens(address client) public override view returns (uint) {
        return token.balanceOf(client);
    }
    
    function generateTokens(uint _tokenCount) external override onlyOwner() {
        token.increaseTotalSupply(_tokenCount);
    }
    
    function buyTokens(uint _tokenCount) public override payable {
        require (_tokenCount <= balanceOf(), "The transaction cannot be completed the requested amount of tokens cannot be satisfied");
        uint tokenCost = getTokenPriceInWei(_tokenCount);
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

    // Modifiers

    modifier accountHasNotAlreadyProvidedWithInitialFunds(address _account) {
        require(!accountsAlreadyProvidedWithInitialFunds[_account], "Account Has Already Financed");
        _;
    }
    
}