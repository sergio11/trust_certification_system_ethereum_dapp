// SPDX-License-Identifier: MIT
pragma solidity ^0.7.1;
pragma experimental ABIEncoderV2;

interface ICertificationAuthorityContract {
    
    function addCertificationAuthority(string memory _id) external;
    function addMember(string memory _id, address _member) external;
    function removeMember(string memory _id, address _member) external;
    function enableMember(string memory _id, address _member) external;
    function disableMember(string memory _id, address _member) external;
    function removeCertificationAuthority(string memory _id) external;
    function enableCertificationAuthority(string memory _id) external;
    function disableCertificationAuthority(string memory _id) external;
    function isCertificationAuthorityEnabled(string memory _id) external view returns (bool);
    function isCertificationAuthorityMemberEnabled(string memory _id, address _member) external view returns (bool);
    function isCertificationAuthorityExists(string memory _id) external view returns (bool);
    function isCertificationAuthorityMemberExists(string memory _id, address _member) external view returns (bool);
    function getCertificationAuthorityByMember(address _member) external view returns (string memory);
    function getCertificateAuthorityDetail(string memory _id) external view returns (CertificationAuthorityRecord memory);
    function getCertificateAuthorityAdminMember(string memory _id) external view returns (address);
    function getAllCertificationAuthorities() external view returns (CertificationAuthorityRecord[] memory);

    // Data Structure
    struct CertificationAuthorityRecord {
        string id;
        address admin;
        bool isEnabled;
        bool isExist;
    }

    struct CaMemberRecord {
        address _address;
        string caId;
        bool isAdmin;
        bool isEnabled;
        bool isExist;
    }
    
    // Events Definitions
    event OnNewCertificationAuthorityCreated(string _id, address _address);
    event OnNewCertificationAuthorityMemberAdded(string _id, address _address);
    event OnCertificationAuthorityMemberRemoved(string _id, address _address);
    event OnCertificationAuthorityMemberEnabled(string _id, address _address);
    event OnCertificationAuthorityMemberDisabled(string _id, address _address);
    event OnCertificationAuthorityRemoved(string _id);
    event OnCertificationAuthorityEnabled(string _id);
    event OnCertificationAuthorityDisabled(string _id);
    
}