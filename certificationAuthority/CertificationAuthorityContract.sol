// SPDX-License-Identifier: MIT
pragma solidity ^0.7.1;
pragma experimental ABIEncoderV2;
import "../ownable/Ownable.sol";
import "../tokenManagement/ITokenManagementContract.sol";
import "./ICertificationAuthorityContract.sol";

contract CertificationAuthorityContract is Ownable, ICertificationAuthorityContract {
    
    // Cost of Add CA in TCS ERC-20 tokens 
    uint8 public constant ADD_CERTIFICATION_AUTHORITY_COST_IN_TCS_TOKENS = 5;
    uint8 public constant ADD_CERTIFICATION_AUTHORITY_MEMBER_COST_IN_TCS_TOKENS = 2;
    
    address private tokenManagementAddr;
    string[] private certificationAuthoritiesRegistered;
    address[] private caMembersRegistered;
    mapping(string => CertificationAuthorityRecord) private certificationAuthorities;
    mapping(string => mapping(address => CaMemberRecord)) private certificationAuthoritiesMembers;
    mapping(address => string) private caMembersOf;
    
    function setTokenManagementAddr(address _tokenManagementAddr) public payable onlyOwner() {
       tokenManagementAddr = _tokenManagementAddr;
    }

    function addCertificationAuthority(string memory _id) external override CertificationAuthorityMustNotExist(_id) MustNotBeCaMembersRegistered(msg.sender) {
        uint _senderTokens = ITokenManagementContract(tokenManagementAddr).getTokens(msg.sender);
        require(_senderTokens >= ADD_CERTIFICATION_AUTHORITY_COST_IN_TCS_TOKENS, "You do not have enough tokens to register as Certification Authority");
        require(ITokenManagementContract(tokenManagementAddr).transfer(msg.sender, address(this), ADD_CERTIFICATION_AUTHORITY_COST_IN_TCS_TOKENS), "The transfer could not be made");
        certificationAuthoritiesRegistered.push(_id);
        certificationAuthorities[_id] = CertificationAuthorityRecord(_id, msg.sender, true, true);
        certificationAuthoritiesMembers[_id][msg.sender] = CaMemberRecord(msg.sender, _id, true, true, true);
        caMembersRegistered.push(msg.sender);
        caMembersOf[msg.sender] = _id;
        emit OnNewCertificationAuthorityCreated(_id, msg.sender);
    }

    function removeCertificationAuthority(string memory _id) external override onlyOwner() CertificationAuthorityMustExist(_id) { 
        certificationAuthorities[_id].isExist = false;
        emit OnCertificationAuthorityRemoved(_id);
    }

    function addMember(string memory _id, address _member) external override CertificationAuthorityMustExist(_id) CertificationAuthorityMustBeEnabled(_id) MustNotBeCaMembersRegistered(_member) MustBeCaAdmin(msg.sender, _id) {
        uint _senderTokens = ITokenManagementContract(tokenManagementAddr).getTokens(msg.sender);
        require(_senderTokens >= ADD_CERTIFICATION_AUTHORITY_MEMBER_COST_IN_TCS_TOKENS, "You do not have enough tokens to register Certification Authority Member");
        require(ITokenManagementContract(tokenManagementAddr).transfer(msg.sender, address(this), ADD_CERTIFICATION_AUTHORITY_MEMBER_COST_IN_TCS_TOKENS), "The transfer could not be made");
        certificationAuthoritiesMembers[_id][_member] = CaMemberRecord(_member, _id, false, true, true);
        caMembersRegistered.push(_member);
        caMembersOf[_member] = _id;
        emit OnNewCertificationAuthorityMemberAdded(_id, _member);
    }

    function removeMember(string memory _id, address _member) external override CertificationAuthorityMustExist(_id) CertificationAuthorityMustBeEnabled(_id) MustBeCaMembersRegistered(_member) MustBeCaAdmin(msg.sender, _id) MustNotBeCaAdmin(_member, _id) {
        certificationAuthoritiesMembers[_id][_member].isExist = false;
        emit OnCertificationAuthorityMemberRemoved(_id, _member);
    }

    function enableMember(string memory _id, address _member) external override CertificationAuthorityMustExist(_id) CertificationAuthorityMustBeEnabled(_id)  MustBeCaMembersRegistered(_member) MustBeCaAdmin(msg.sender, _id) {
        certificationAuthoritiesMembers[_id][_member].isEnabled = true;
        emit OnCertificationAuthorityMemberEnabled(_id, _member);
    }

    function disableMember(string memory _id, address _member) external override CertificationAuthorityMustExist(_id) CertificationAuthorityMustBeEnabled(_id)  MustBeCaMembersRegistered(_member) MustBeCaAdmin(msg.sender, _id) {
        certificationAuthoritiesMembers[_id][_member].isEnabled = false;
        emit OnCertificationAuthorityMemberDisabled(_id, _member);
    }
    
    function enableCertificationAuthority(string memory _id) external override onlyOwner() CertificationAuthorityMustBeDisabled(_id) CertificationAuthorityMustExist(_id) {
        certificationAuthorities[_id].isEnabled = true;
        emit OnCertificationAuthorityEnabled(_id);
    }
    
    function disableCertificationAuthority(string memory _id) external override onlyOwner() CertificationAuthorityMustBeEnabled(_id) CertificationAuthorityMustExist(_id) {
       certificationAuthorities[_id].isEnabled = false;
       emit OnCertificationAuthorityDisabled(_id);
    }
    
    function isCertificationAuthorityEnabled(string memory _id) external view override CertificationAuthorityMustExist(_id) returns (bool)  {
        return certificationAuthorities[_id].isEnabled;
    }

    function isCertificationAuthorityMemberEnabled(string memory _id, address _member) external view override CertificationAuthorityMustExist(_id) returns (bool) {
        return certificationAuthoritiesMembers[_id][_member].isEnabled;
    }
    
    function isCertificationAuthorityExists(string memory _id) external view override returns (bool) {
        return certificationAuthorities[_id].isExist;
    }

    function isCertificationAuthorityMemberExists(string memory _id, address _member) external view override CertificationAuthorityMustExist(_id) returns (bool) {
        return certificationAuthoritiesMembers[_id][_member].isExist;
    }

    function getCertificateAuthorityDetail(string memory _id) external view override CertificationAuthorityMustExist(_id) CertificationAuthorityMustBeEnabled(_id) returns (CertificationAuthorityRecord memory) {
        return certificationAuthorities[_id];
    }

    function getCertificationAuthorityByMember(address _member) external view override returns (string memory) {
        return caMembersOf[_member];
    }

    function getCertificateAuthorityAdminMember(string memory _id) external view override  CertificationAuthorityMustExist(_id) returns (address) {
        return certificationAuthorities[_id].admin;
    }

    function getAllCertificationAuthorities() external view override onlyOwner() returns (CertificationAuthorityRecord[] memory) {
        CertificationAuthorityRecord[] memory allCertificationAuthorities = new CertificationAuthorityRecord[](certificationAuthoritiesRegistered.length);
        for (uint i=0; i < certificationAuthoritiesRegistered.length; i++) { 
           allCertificationAuthorities[i] = certificationAuthorities[certificationAuthoritiesRegistered[i]];
        }
        return allCertificationAuthorities;
    }
     
    function _isCaMemberAlreadyRegistered(address _address) private view returns (bool) {
        bool caMemberExists = false;
        bytes32 encodedElement = keccak256(abi.encode(_address));
        for (uint i = 0 ; i < caMembersRegistered.length; i++) {
            if (encodedElement == keccak256(abi.encode(caMembersRegistered[i]))) {
                caMemberExists = true;
                break;
            }
        }
        return caMemberExists;
    }

    // Modifiers

    modifier CertificationAuthorityMustExist(string memory _id) {
        require(certificationAuthorities[_id].isExist, "Certification Authority with given id don't exists");
        _;
    }
    
    modifier CertificationAuthorityMustNotExist(string memory _id) {
        require(!certificationAuthorities[_id].isExist, "Certification Authority with given id already exists");
        _;
    }
    
    modifier CertificationAuthorityMustBeEnabled(string memory _id) {
        require(certificationAuthorities[_id].isEnabled, "Certification Authority must be enabled");
        _;
    }
    
    modifier CertificationAuthorityMustBeDisabled(string memory _id) {
        require(!certificationAuthorities[_id].isEnabled, "Certification Authority must be disabled");
        _;
    }

    modifier MustBeCaMembersRegistered(address _address) {
        require(_isCaMemberAlreadyRegistered(_address), "Address Must be a already ca member registered");
        _;
    }
    
    modifier MustNotBeCaMembersRegistered(address _address) {
        require(!_isCaMemberAlreadyRegistered(_address), "Address Must not be a already ca member registered");
        _;
    }

    modifier MustBeCaAdmin(address _address, string memory _id) {
        require(certificationAuthoritiesMembers[_id][_address].isAdmin, "Address Must not be a already ca member registered");
        _;
    }

    modifier MustNotBeCaAdmin(address _address, string memory _id) {
        require(!certificationAuthoritiesMembers[_id][_address].isAdmin, "Address Must not be a already ca member registered");
        _;
    }
}
