// SPDX-License-Identifier: MIT
pragma solidity ^0.7.1;
pragma experimental ABIEncoderV2;

interface ICertificationAuthorityContract {
    
    function addCertificationAuthority(string memory _id, uint _defaultCostOfIssuingCertificate) external;
    function addCertificationAuthority(string memory _id) external;
    function updateCertificationAuthority(uint _defaultCostOfIssuingCertificate) external;
    function removeCertificationAuthority(address _address) external;
    function enableCertificationAuthority(address _address) external;
    function disableCertificationAuthority(address _address) external;
    function isCertificationAuthorityEnabled(address _address) external view returns (bool);
    function isCertificationAuthorityExists(address _address) external view returns (bool);
    function getDefaultCostOfIssuingCertificate(address _address) external view returns (uint);
    function getCertificateAuthorityDetail(address _address) external view returns (CertificationAuthorityRecord memory);
    function getCertificateAuthorityDetail() external view returns (CertificationAuthorityRecord memory);
    function getAllCertificationAuthorities() external view returns (CertificationAuthorityRecord[] memory);

    // Data Structure
    struct CertificationAuthorityRecord {
        string id;
        uint defaultCostOfIssuingCertificate;
        bool isEnabled;
        bool isExist;
    }
    
    // Events Definitions
    event OnNewCertificationAuthorityCreated(address _address, string _id);
    event OnCertificationAuthorityRemoved(address _address);
    event OnCertificationAuthorityEnabled(address _address);
    event OnCertificationAuthorityDisabled(address _address);
    event OnCertificationAuthorityUpdated(address _address, string _id);
    
}