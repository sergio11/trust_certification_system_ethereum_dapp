// SPDX-License-Identifier: MIT
pragma solidity ^0.7.1;
pragma experimental ABIEncoderV2;
import "../ownable/Ownable.sol";
import "../libs/Utils.sol";
import "./ICertificationCourseContract.sol";
import "../tokenManagement/ITokenManagementContract.sol";
import "../certificationAuthority/ICertificationAuthorityContract.sol";

contract CertificationCourseContract is Ownable, ICertificationCourseContract {
    
    // constants
    uint8 private constant COST_OF_ADD_CERTIFICATION_COURSE = 10;
    
    // Contracts references
    address private tokenManagementContractAddr;
    address private certificationAuthorityContractAddr;
    
    // Contract storage data
    mapping(string => CertificationCourseRecord) private certificationCourse;
    mapping(address => string[]) private certificationAuthorityCourses;
    
    function setCertificationAuthorityContractAddr(address _certificationAuthorityContractAddr) public payable onlyOwner() {
       certificationAuthorityContractAddr = _certificationAuthorityContractAddr;
    }
    
    function setTokenManagementAddr(address _tokenManagementContractAddr) public payable onlyOwner() {
       tokenManagementContractAddr = _tokenManagementContractAddr;
    }
    
    function addCertificationCourse(string memory _name, uint _costOfIssuingCertificate, uint _durationInHours, uint _expirationInDays, bool _canBeRenewed, uint _costOfRenewingCertificate) external override MustBeAValidCertificationAuthority(msg.sender) returns(string memory){
       return _addCertificationCourse(_name, _costOfIssuingCertificate, _durationInHours, _expirationInDays, _canBeRenewed, _costOfRenewingCertificate);
    }

    function addCertificationCourse(string memory _name, uint _costOfIssuingCertificate, uint _durationInHours) external override MustBeAValidCertificationAuthority(msg.sender) returns(string memory){
        return _addCertificationCourse(_name, _costOfIssuingCertificate, _durationInHours, 0, false, 0);
    }
    
    function _addCertificationCourse(string memory _name, uint _costOfIssuingCertificate, uint _durationInHours, uint _expirationInDays, bool _canBeRenewed, uint _costOfRenewingCertificate) private returns(string memory) {
        uint _senderTokens = ITokenManagementContract(tokenManagementContractAddr).getTokens(msg.sender);
        require(_senderTokens >= COST_OF_ADD_CERTIFICATION_COURSE, "You do not have enough tokens to register as Certification Course");
        require(ITokenManagementContract(tokenManagementContractAddr).transfer(msg.sender, address(this), COST_OF_ADD_CERTIFICATION_COURSE), "The transfer could not be made");
        
        if(_costOfIssuingCertificate == 0)
            _costOfIssuingCertificate = ICertificationAuthorityContract(certificationAuthorityContractAddr).getDefaultCostOfIssuingCertificate(msg.sender);
        // Generate Course Id
        string memory _courseId = Utils.bytes32ToString(keccak256(abi.encodePacked(_name)));
        // Add Certification Course
        certificationCourse[_courseId] = CertificationCourseRecord(_name, _costOfIssuingCertificate, _costOfRenewingCertificate,
            msg.sender, _durationInHours, _expirationInDays, _canBeRenewed,  true, true);
        certificationAuthorityCourses[msg.sender].push(_courseId);
        // Emit course created event
        emit OnNewCertificationCourseCreated(_courseId);
        return _courseId;
    }
    
    function removeCertificationCourse(string memory  _id) external override CertificationCourseMustExist(_id) MustBeOwnerOfTheCourse(_id, msg.sender) { 
        delete certificationCourse[_id];
        emit OnCertificationCourseRemoved(_id);
    }
    
    function enableCertificationCourse(string memory _id) external override CertificationCourseMustBeDisabled(_id) CertificationCourseMustExist(_id) MustBeOwnerOfTheCourse(_id, msg.sender) {
        certificationCourse[_id].isEnabled = true;
        emit OnCertificationCourseEnabled(_id);
    }
    
    function disableCertificationCourse(string memory _id) external override CertificationCourseMustBeEnabled(_id) CertificationCourseMustExist(_id) MustBeOwnerOfTheCourse(_id, msg.sender) {
       certificationCourse[_id].isEnabled = false;
       emit OnCertificationCourseDisabled(_id);
    }
    
    function canBeIssued(string memory _id) external view override CertificationCourseMustExist(_id) returns (bool)  {
        return certificationCourse[_id].isEnabled 
        && ICertificationAuthorityContract(certificationAuthorityContractAddr).isCertificationAuthorityExists(certificationCourse[_id].certificationAuthority)
        && ICertificationAuthorityContract(certificationAuthorityContractAddr).isCertificationAuthorityEnabled(certificationCourse[_id].certificationAuthority);
    }
    
    function canBeRenewed(string memory _id) external view override CertificationCourseMustExist(_id) returns (bool)  { 
        return certificationCourse[_id].isEnabled 
        && certificationCourse[_id].canBeRenewed 
        && ICertificationAuthorityContract(certificationAuthorityContractAddr).isCertificationAuthorityExists(certificationCourse[_id].certificationAuthority)
        && ICertificationAuthorityContract(certificationAuthorityContractAddr).isCertificationAuthorityEnabled(certificationCourse[_id].certificationAuthority);
    }
    
    function getCertificateCourseDetail(string memory _id) external view override CertificationCourseMustExist(_id) returns (CertificationCourseRecord memory) {
         return certificationCourse[_id];
    }
    
    function isCertificationCourseExists(string memory _id) external view override CertificationCourseMustExist(_id) returns (bool) {
        return certificationCourse[_id].isExist;
    }
    
    function getCostOfIssuingCertificate(string memory _id) public view override CertificationCourseMustExist(_id) returns (uint) {
        return certificationCourse[_id].costOfIssuingCertificate;
    }
    
    function getCostOfRenewingCertificate(string memory _id) external view override CertificationCourseMustExist(_id) returns (uint) {
        return certificationCourse[_id].costOfRenewingCertificate;
    }
    
    function getCertificateAuthorityForCourse(string memory _id) external view override CertificationCourseMustExist(_id) returns (address) {
        return certificationCourse[_id].certificationAuthority;
    }
    
    function getDurationInHours(string memory _id) public view override CertificationCourseMustExist(_id) returns (uint) {
        return certificationCourse[_id].durationInHours;
    }
    
    function getExpirationDate(string memory _id) external view override CertificationCourseMustExist(_id) returns (uint) {
        uint _expirationDateInSeconds;
        if(certificationCourse[_id].expirationInDays == 0)
            _expirationDateInSeconds = 0;
        else
          _expirationDateInSeconds = block.timestamp + (certificationCourse[_id].expirationInDays * 24 * 60 * 60);
        return _expirationDateInSeconds;
    }
    
    function isYourOwner(string memory _id, address _certificationAuthority) public view override CertificationCourseMustExist(_id) returns (bool) {
        return certificationCourse[_id].certificationAuthority == _certificationAuthority;
    }
    
    // modifiers    

    modifier CertificationCourseMustExist(string memory _id) {
        require(certificationCourse[_id].isExist, "Certification Course with given id don't exists");
        _;
    }
    
    
    modifier MustBeAValidCertificationAuthority(address _certificationAuthorityAddress) {
        require(ICertificationAuthorityContract(certificationAuthorityContractAddr).isCertificationAuthorityExists(_certificationAuthorityAddress)
         && ICertificationAuthorityContract(certificationAuthorityContractAddr).isCertificationAuthorityEnabled(_certificationAuthorityAddress), "Must be a valid certification Authority");
        _;
    }
    
    modifier MustBeOwnerOfTheCourse(string memory _courseId, address _certificationAuthorityAddress) {
        require(isYourOwner(_courseId, _certificationAuthorityAddress), "Certification Authority must be the owner of this course");
        _;
    }
    
    modifier CertificationCourseMustBeEnabled(string memory _id) {
        require(certificationCourse[_id].isEnabled, "Certification Course must be enabled");
        _;
    }
    
    modifier CertificationCourseMustBeDisabled(string memory _id) {
        require(!certificationCourse[_id].isEnabled, "Certification Course must be disabled");
        _;
    }
    
}