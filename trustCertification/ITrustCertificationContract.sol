// SPDX-License-Identifier: MIT
pragma solidity ^0.7.1;
pragma experimental ABIEncoderV2;

interface ITrustCertificationContract { 
    
    function issueCertificate(address _recipientAddress, string memory _certificateCourseId, uint _qualification) external returns(string memory);
    function renewCertificate(string memory _id) external;
    function enableCertificate(string memory _id) external;
    function disableCertificate(string memory _id) external;
    function updateCertificateVisibility(string memory _id, bool isVisible) external;
    function isCertificateValid(string memory _id) external view returns (bool);
    function getCertificateDetail(string memory _id) external view returns (CertificateRecord memory);
    function getMyCertificatesAsRecipient() external view returns (string[] memory);
    function getMyCertificatesAsIssuer() external view returns (string[] memory);
    
    // Data Structure
    struct CertificateRecord {
        address issuerAddress;
        address recipientAddress;
        string course;
        uint256 expirationDate;
        uint qualification;
        uint durationInHours;
        uint256 expeditionDate;
        bool isVisible;
        bool isEnabled;
        bool isExist;
    } 

    // Events
    event OnNewCertificateGenerated(string _id);
    event OnCertificateRenewed(string _id);
    event OnCertificateDeleted(string _id);
    event OnCertificateEnabled(string _id);
    event OnCertificateDisabled(string _id);
    event OnCertificateVisibilityUpdated(string _id, bool _isVisible);
}