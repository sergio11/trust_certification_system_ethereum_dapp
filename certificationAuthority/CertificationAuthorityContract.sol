// SPDX-License-Identifier: MIT
pragma solidity ^0.7.1;
pragma experimental ABIEncoderV2;
import "../ownable/Ownable.sol";
import "../libs/Utils.sol";
import "../tokenManagement/ITokenManagementContract.sol";
import "./ICertificationAuthorityContract.sol";

contract CertificationAuthorityContract is Ownable, ICertificationAuthorityContract {
    
    // Cost of Add CA in TCS ERC-20 tokens 
    uint8 public constant ADD_CERTIFICATION_AUTHORITY_COST_IN_TCS_TOKENS = 5;
    uint8 public constant DEFAULT_COST_OF_ISSUING_CERTIFICATE = 4;
    
    address private tokenManagementAddr;
    mapping(address => CertificationAuthorityRecord) private certificationAuthorities;
    address[] private authoritiesRegistered;
    
    function setTokenManagementAddr(address _tokenManagementAddr) public payable onlyOwner() {
       tokenManagementAddr = _tokenManagementAddr;
    }
    
    function addCertificationAuthority(string memory _name, string memory _location, string memory _executiveDirector, uint _defaultCostOfIssuingCertificate) external override CertificationAuthorityMustNotExist(msg.sender) {
        _addCertificationAuthority(_name,  _location, _executiveDirector, _defaultCostOfIssuingCertificate);
    }

    function addCertificationAuthority(string memory _name, string memory _location, string memory _executiveDirector) external override CertificationAuthorityMustNotExist(msg.sender) {
        _addCertificationAuthority(_name, _location, _executiveDirector, DEFAULT_COST_OF_ISSUING_CERTIFICATE);
    }

    function _addCertificationAuthority(string memory _name, string memory _location, string memory _executiveDirector, uint _defaultCostOfIssuingCertificate) private {
        uint _senderTokens = ITokenManagementContract(tokenManagementAddr).getTokens(msg.sender);
        require(_senderTokens >= ADD_CERTIFICATION_AUTHORITY_COST_IN_TCS_TOKENS, "You do not have enough tokens to register as Certification Authority");
        require(ITokenManagementContract(tokenManagementAddr).transfer(msg.sender, address(this), ADD_CERTIFICATION_AUTHORITY_COST_IN_TCS_TOKENS), "The transfer could not be made");
        string memory _caId = Utils.bytes32ToString(keccak256(abi.encodePacked(msg.sender)));
        certificationAuthorities[msg.sender] = CertificationAuthorityRecord(_caId, _name, _location, _executiveDirector, _defaultCostOfIssuingCertificate, true, true);
        authoritiesRegistered.push(msg.sender);
        emit OnNewCertificationAuthorityCreated(msg.sender, _name, _location, _executiveDirector);
    }

    function updateCertificationAuthority(string memory _name, string memory _location, string memory _executiveDirector, uint _defaultCostOfIssuingCertificate) external override CertificationAuthorityMustExist(msg.sender) {
        certificationAuthorities[msg.sender].name = _name;
        certificationAuthorities[msg.sender].location = _location;
        certificationAuthorities[msg.sender].executiveDirector = _executiveDirector;
        certificationAuthorities[msg.sender].defaultCostOfIssuingCertificate = _defaultCostOfIssuingCertificate;
        emit OnCertificationAuthorityUpdated(msg.sender, _name);
    }
    
    function removeCertificationAuthority(address _address) external override onlyOwner() CertificationAuthorityMustExist(_address) { 
        certificationAuthorities[_address].isExist = false;
        emit OnCertificationAuthorityRemoved(_address);
    }
    
    function enableCertificationAuthority(address _address) external override onlyOwner() CertificationAuthorityMustBeDisabled(msg.sender) CertificationAuthorityMustExist(_address) {
        certificationAuthorities[_address].isEnabled = true;
        emit OnCertificationAuthorityEnabled(_address);
    }
    
    function disableCertificationAuthority(address _address) external override onlyOwner() CertificationAuthorityMustBeEnabled(msg.sender) CertificationAuthorityMustExist(_address) {
       certificationAuthorities[_address].isEnabled = false;
       emit OnCertificationAuthorityDisabled(_address);
    }
    
    function isCertificationAuthorityEnabled(address _address) external view override CertificationAuthorityMustExist(_address) returns (bool)  {
        return certificationAuthorities[_address].isEnabled;
    }
    
    function isCertificationAuthorityExists(address _address) external view override returns (bool) {
        return certificationAuthorities[_address].isExist;
    }
    
    function getDefaultCostOfIssuingCertificate(address _address) public view override returns (uint) {
        return certificationAuthorities[_address].defaultCostOfIssuingCertificate;
    }
    
    function getCertificateAuthorityDetail(address _address) external view override CertificationAuthorityMustExist(_address) CertificationAuthorityMustBeEnabled(_address) returns (CertificationAuthorityRecord memory) {
        return certificationAuthorities[_address];
    }
    
    function getCertificateAuthorityDetail() external view override CertificationAuthorityMustExist(msg.sender) returns (CertificationAuthorityRecord memory) {
         return certificationAuthorities[msg.sender];
    }

    function getAllCertificationAuthorities() external view override onlyOwner() returns (CertificationAuthorityRecord[] memory) {
        CertificationAuthorityRecord[] memory allCertificationAuthorities = new CertificationAuthorityRecord[](authoritiesRegistered.length);
        for (uint i=0; i < authoritiesRegistered.length; i++) { 
           allCertificationAuthorities[i] = certificationAuthorities[authoritiesRegistered[i]];
        }
        return allCertificationAuthorities;
    }
     
    // Modifiers

    modifier CertificationAuthorityMustExist(address _address) {
        require(certificationAuthorities[_address].isExist, "Certification Authority with given id don't exists");
        _;
    }
    
    modifier CertificationAuthorityMustNotExist(address _address) {
        require(!certificationAuthorities[_address].isExist, "Certification Authority with given id already exists");
        _;
    }
    
    modifier CertificationAuthorityMustBeEnabled(address _address) {
        require(certificationAuthorities[_address].isEnabled, "Certification Authority must be enabled");
        _;
    }
    
    modifier CertificationAuthorityMustBeDisabled(address _address) {
        require(!certificationAuthorities[_address].isEnabled, "Certification Authority must be disabled");
        _;
    }
    
    
}
