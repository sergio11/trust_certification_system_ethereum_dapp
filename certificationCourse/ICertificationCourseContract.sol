// SPDX-License-Identifier: MIT
pragma solidity ^0.7.1;
pragma experimental ABIEncoderV2;


interface ICertificationCourseContract { 
    
    function addCertificationCourse(string memory _id, uint _costOfIssuingCertificate, uint _durationInHours) external;
    function addCertificationCourse(string memory _id, uint _costOfIssuingCertificate, uint _durationInHours, uint _expirationInDays, bool _canBeRenewed, uint _costOfRenewingCertificate) external;
    function updateCertificationCourse(string memory _id, uint _costOfIssuingCertificate, uint _durationInHours, uint _expirationInDays, bool _canBeRenewed, uint _costOfRenewingCertificate) external;
    function removeCertificationCourse(string memory _id) external;
    function enableCertificationCourse(string memory _id) external;
    function disableCertificationCourse(string memory _id) external;
    function canBeIssued(string memory _id) external view returns (bool);
    function canBeRenewed(string memory _id) external view returns (bool);
    function isCertificationCourseExists(string memory _id) external view returns (bool);
    function getCostOfIssuingCertificate(string memory _id) external view returns (uint);
    function getCostOfRenewingCertificate(string memory _id) external view returns (uint);
    function getCertificateAuthorityAdminForCourse(string memory _id) external view returns (address);
    function getDurationInHours(string memory _id) external view returns (uint);
    function getExpirationDate(string memory _id) external view returns (uint);
    function getCertificateCourseDetail(string memory _id) external view returns (CertificationCourseRecord memory);
    function isYourOwner(string memory _id, address _certificationAuthority) external view returns (bool);
    function getMyCertificationCourses() external view returns (CertificationCourseRecord[] memory);
    function getAllCertificationCourses() external view returns (CertificationCourseRecord[] memory);
    
    // Data Structure
    struct CertificationCourseRecord {
        string id;
        uint costOfIssuingCertificate;
        uint costOfRenewingCertificate;
        string certificationAuthority;
        uint durationInHours;
        uint expirationInDays;
        bool canBeRenewed;
        bool isEnabled;
        bool isExist;
    }
    
    // Events Definitions
    event OnNewCertificationCourseCreated(string _id);
    event OnCertificationCourseRemoved(string _id);
    event OnCertificationCourseEnabled(string _id);
    event OnCertificationCourseDisabled(string  _id);
    event OnCertificationCourseUpdated(string  _id);
}


