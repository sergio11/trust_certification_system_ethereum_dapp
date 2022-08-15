// SPDX-License-Identifier: MIT
pragma solidity ^0.7.1;
pragma experimental ABIEncoderV2;

interface ICertificationAuthorityContract {
    
    function addCertificationAuthority(string memory _name, uint _defaultCostOfIssuingCertificate) external;
    function updateCertificationAuthority(uint _defaultCostOfIssuingCertificate) external;
    function addCertificationAuthority(string memory _name) external;
    function removeCertificationAuthority(address _address) external;
    function enableCertificationAuthority(address _address) external;
    function disableCertificationAuthority(address _address) external;
    function isCertificationAuthorityEnabled(address _address) external view returns (bool);
    function isCertificationAuthorityExists(address _address) external view returns (bool);
    function getDefaultCostOfIssuingCertificate(address _address) external view returns (uint);
    function getCertificateAuthorityDetail(address _address) external view returns (CertificationAuthorityRecord memory);
    function getCertificateAuthorityDetail() external view returns (CertificationAuthorityRecord memory);
    
    // Data Structure
    struct CertificationAuthorityRecord {
        string name;
        uint defaultCostOfIssuingCertificate;
        bool isEnabled;
        bool isExist;
    }
    
    // Events Definitions
    event OnNewCertificationAuthorityCreated(address _address, string name);
    event OnCertificationAuthorityRemoved(address _address);
    event OnCertificationAuthorityEnabled(address _address);
    event OnCertificationAuthorityDisabled(address _address);
    event OnCertificationAuthorityUpdated(address _address, uint _defaultCostOfIssuingCertificate);
    
}