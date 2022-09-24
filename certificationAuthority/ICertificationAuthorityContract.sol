// SPDX-License-Identifier: MIT
pragma solidity ^0.7.1;
pragma experimental ABIEncoderV2;

interface ICertificationAuthorityContract {
    
    function addCertificationAuthority(string memory _name, string memory _location, string memory _executiveDirector, uint _defaultCostOfIssuingCertificate) external;
    function updateCertificationAuthority(string memory _name, string memory _location, string memory _executiveDirector, uint _defaultCostOfIssuingCertificate) external;
    function addCertificationAuthority(string memory _name, string memory _location, string memory _executiveDirector) external;
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
        string name;
        string location;
        string executiveDirector;
        uint defaultCostOfIssuingCertificate;
        bool isEnabled;
        bool isExist;
    }
    
    // Events Definitions
    event OnNewCertificationAuthorityCreated(address _address, string _name, string _location, string _executiveDirector);
    event OnCertificationAuthorityRemoved(address _address);
    event OnCertificationAuthorityEnabled(address _address);
    event OnCertificationAuthorityDisabled(address _address);
    event OnCertificationAuthorityUpdated(address _address, string _name);
    
}