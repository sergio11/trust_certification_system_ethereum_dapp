// SPDX-License-Identifier: MIT
pragma solidity ^0.7.1;
pragma experimental ABIEncoderV2;

interface ITrustCertificationContract { 
    
    function issueCertificate(address _recipientAddress, string memory _certificateCourseId, uint _qualification, string memory _cid, string memory _certificateHash) external returns(string memory);
    function renewCertificate(string memory _id) external;
    function enableCertificate(string memory _id) external;
    function disableCertificate(string memory _id) external;
    function updateCertificateVisibility(string memory _id, bool isVisible) external;
    function isCertificateValid(string memory _id) external view returns (bool);
    function getCertificateDetail(string memory _id) external view returns (CertificateRecord memory);
    function getMyCertificatesAsRecipient() external view returns (string[] memory);
    function getMyCertificatesAsIssuer() external view returns (string[] memory);
    function validateCertificateIntegrity(string  memory _certificateHash) external view returns (bool);
    
    // Data Structure
    struct CertificateRecord {
        address issuerAddress;
        address recipientAddress;
        string course;
        uint256 expirationDate;
        uint qualification;
        uint durationInHours;
        string cid;
        string certificateHash;
        uint256 expeditionDate;
        bool isVisible;
        bool isEnabled;
        bool isExist;
    } 

    // Events
    event OnNewCertificateGenerated(string _id, bool _isVisible);
    event OnCertificateRenewed(string _id, bool _isVisible);
    event OnCertificateDeleted(string _id, bool _isVisible);
    event OnCertificateEnabled(string _id, bool _isVisible);
    event OnCertificateDisabled(string _id, bool _isVisible);
    event OnCertificateVisibilityUpdated(string _id, bool _isVisible);
}