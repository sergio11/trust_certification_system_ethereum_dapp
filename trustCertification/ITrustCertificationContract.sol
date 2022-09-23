// SPDX-License-Identifier: MIT
pragma solidity ^0.7.1;
pragma experimental ABIEncoderV2;

interface ITrustCertificationContract { 
    
    function issueCertificate(IssueCertificateRequest memory _request) external returns(string memory);
    function renewCertificate(string memory _id) external;
    function enableCertificate(string memory _id) external;
    function disableCertificate(string memory _id) external;
    function updateCertificateVisibility(string memory _id, bool isVisible) external;
    function isCertificateValid(string memory _id) external view returns (bool);
    function getCertificateDetail(string memory _id) external view returns (CertificateRecord memory);
    function getMyCertificatesAsRecipient() external view returns (string[] memory);
    function getMyCertificatesAsIssuer() external view returns (string[] memory);
    function validateCertificateIntegrity(string memory _id, string  memory _fileCertificateHash, address recipientAddress) external view returns (bool);
    
    // Data Structure
    struct CertificateRecord {
        string id;
        address issuerAddress;
        address recipientAddress;
        string course;
        uint256 expirationDate;
        uint qualification;
        uint durationInHours;
        string fileCid;
        string fileCertificateHash;
        string imageCid;
        string imageCertificateHash;
        uint256 expeditionDate;
        bool isVisible;
        bool isEnabled;
        bool isExist;
    } 

    struct IssueCertificateRequest {
        string id;
        address recipientAddress;
        string certificateCourseId; 
        uint qualification;
        string fileCid;
        string fileCertificateHash;
        string imageCid; 
        string imageCertificateHash;
    }

    // Events
    event OnNewCertificateGenerated(string _id, bool _isVisible);
    event OnCertificateRenewed(string _id, bool _isVisible);
    event OnCertificateDeleted(string _id, bool _isVisible);
    event OnCertificateEnabled(string _id, bool _isVisible);
    event OnCertificateDisabled(string _id, bool _isVisible);
    event OnCertificateVisibilityUpdated(string _id, bool _isVisible);
}