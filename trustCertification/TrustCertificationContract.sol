// SPDX-License-Identifier: MIT
pragma solidity ^0.7.1;
pragma experimental ABIEncoderV2;
import "../ownable/Ownable.sol";
import "../libs/Utils.sol";
import "./ITrustCertificationContract.sol";
import "../tokenManagement/ITokenManagementContract.sol";
import "../certificationCourse/ICertificationCourseContract.sol";

contract TrustCertificationContract is Ownable, ITrustCertificationContract {
    
    address private tokenManagementAddr;
    address private certificationCourseAddr;
    
    // Contract storage data
    mapping(string => CertificateRecord) private certificates;
    mapping(address => string[]) private certificatesByIssuer;
    mapping(address => string[]) private certificatesByRecipient;
    
    function setTokenManagementAddr(address _tokenManagementAddr) public payable onlyOwner() {
       tokenManagementAddr = _tokenManagementAddr;
    }
    
    function setCertificationCourseAddr(address _certificationCourseAddr) public payable onlyOwner() {
       certificationCourseAddr = _certificationCourseAddr;
    }
    
    function issueCertificate(IssueCertificateRequest memory _request) external override IssuerMustBeOwnerOfTheCourse(_request.certificateCourseId, msg.sender) returns(string memory) {
        require(ICertificationCourseContract(certificationCourseAddr).isCertificationCourseExists(_request.certificateCourseId), "Certification Course with given id don't exists");
        require(ICertificationCourseContract(certificationCourseAddr).canBeIssued(_request.certificateCourseId), "Certification Course with given id can not be issued");
        uint _costOfIssuingCertificate = ICertificationCourseContract(certificationCourseAddr).getCostOfIssuingCertificate(_request.certificateCourseId);
        uint _durationInHours =  ICertificationCourseContract(certificationCourseAddr).getDurationInHours(_request.certificateCourseId);
        uint _recipientAddressTokens = ITokenManagementContract(tokenManagementAddr).getTokens(_request.recipientAddress);
        require(_costOfIssuingCertificate <= _recipientAddressTokens, "You do not have enough tokens to issue the certificate");
        require(ITokenManagementContract(tokenManagementAddr).transfer(_request.recipientAddress, msg.sender, _costOfIssuingCertificate), "The transfer could not be made");
        certificates[_request.id] = CertificateRecord(_request.id, msg.sender, _request.recipientAddress, _request.certificateCourseId, ICertificationCourseContract(certificationCourseAddr).getExpirationDate(_request.certificateCourseId) 
        , _request.qualification, _durationInHours , _request.fileCid,  _request.fileCertificateHash, _request.imageCid, _request.imageCertificateHash, block.timestamp, true, true, true);
        certificatesByIssuer[msg.sender].push(_request.id);
        certificatesByRecipient[_request.recipientAddress].push(_request.id);
        emit OnNewCertificateGenerated(_request.id, certificates[_request.id].isVisible);
        return _request.id;
    }
    
    function renewCertificate(string memory _id) external override CertificateMustExist(_id)  MustBeOwnerOfTheCertificate(msg.sender, _id) CertificateMustBeExpired(_id) {
        CertificateRecord memory certificate = certificates[_id];
        require(ICertificationCourseContract(certificationCourseAddr).isCertificationCourseExists(certificate.course), "Certification Course for given certificate id don't exists");
        require(ICertificationCourseContract(certificationCourseAddr).canBeRenewed(certificate.course), "Certification Course for given certificate id can not be renewed");
        uint _costOfRenewingCertificate = ICertificationCourseContract(certificationCourseAddr).getCostOfRenewingCertificate(certificate.course);
        uint _recipientAddressTokens = ITokenManagementContract(tokenManagementAddr).getTokens(msg.sender);
        require(_costOfRenewingCertificate <= _recipientAddressTokens, "You do not have enough tokens to renew the certificate");
        require(ITokenManagementContract(tokenManagementAddr).transfer(msg.sender, ICertificationCourseContract(certificationCourseAddr).getCertificateAuthorityForCourse(certificate.course), _costOfRenewingCertificate), "The transfer could not be made");
        certificate.expirationDate = ICertificationCourseContract(certificationCourseAddr).getExpirationDate(certificate.course);
        emit OnCertificateRenewed(_id, certificate.isVisible);
    }
    
    function enableCertificate(string memory _id) external override CertificateMustExist(_id) MustBeOwnerOfTheCertificate(msg.sender, _id) { 
        certificates[_id].isEnabled = true;
        emit OnCertificateEnabled(_id, certificates[_id].isVisible);
    }
    
    function disableCertificate(string memory _id) external override CertificateMustExist(_id) MustBeOwnerOfTheCertificate(msg.sender, _id) { 
        certificates[_id].isEnabled = false;
        emit OnCertificateDisabled(_id, certificates[_id].isVisible);
    }
    
    function updateCertificateVisibility(string memory _id, bool _isVisible) external override CertificateMustExist(_id) MustBeOwnerOfTheCertificate(msg.sender, _id) { 
        certificates[_id].isVisible = _isVisible;
        emit OnCertificateVisibilityUpdated(_id, _isVisible);
    }
    
    function isCertificateValid(string memory _id) external view override CertificateMustExist(_id) CertificateMustVisible(_id) returns (bool) {
        return certificates[_id].isExist && certificates[_id].isEnabled && (certificates[_id].expirationDate == 0 ||
         certificates[_id].expirationDate > 0 &&  block.timestamp < certificates[_id].expirationDate);
    }
    
    function getCertificateDetail(string memory _id) external view override CertificateMustExist(_id)  CertificateMustVisible(_id) returns (CertificateRecord memory) {
        return certificates[_id];
    }
    
    function getMyCertificatesAsRecipient() external view override returns (string[] memory) {
        string[] memory  myCertificates = new string[](certificatesByRecipient[msg.sender].length);
        for (uint i=0; i < certificatesByRecipient[msg.sender].length; i++) { 
           myCertificates[i] = certificatesByRecipient[msg.sender][i];
        }
        return myCertificates;
    }
    
    function getMyCertificatesAsIssuer() external view override returns (string[] memory) {
        string[] memory  myCertificates = new string[](certificatesByIssuer[msg.sender].length);
        for (uint i=0; i < certificatesByIssuer[msg.sender].length; i++) { 
           myCertificates[i] = certificatesByIssuer[msg.sender][i];
        }
        return myCertificates;
    }

    function validateCertificateIntegrity(string memory _id, string  memory _fileCertificateHash, address recipientAddress) external view override CertificateMustExist(_id)  CertificateMustVisible(_id) returns (bool) {
        return keccak256(abi.encodePacked(certificates[_id].id, certificates[_id].fileCertificateHash, certificates[_id].recipientAddress)) == keccak256(abi.encodePacked(_id, _fileCertificateHash, recipientAddress));
    }
   
    // Modifiers

    modifier CertificateMustExist(string memory _id) {
        require(certificates[_id].isExist, "Certification with given id don't exists");
        _;
    }
    
    modifier CertificateMustBeExpired(string memory _id) {
        require(certificates[_id].isExist, "Certification with given id has not expired");
        _;
    }
    
    modifier CertificateMustNotExist(string memory _id) {
        require(!certificates[_id].isExist, "Certification with given id already exists");
        _;
    }
    
    modifier CertificateMustVisible(string memory _id) {
        require(certificates[_id].isVisible, "Certification with given id is not visible");
        _;
    }
    
    modifier MustBeOwnerOfTheCertificate(address _ownerAddress, string memory _id) {
        require(certificates[_id].recipientAddress == _ownerAddress, "Must be the owner of this certificate");
        _;
    }
    
    modifier IssuerMustBeOwnerOfTheCourse(string memory _courseId, address _certificationAuthorityAddress) {
        require(ICertificationCourseContract(certificationCourseAddr).isYourOwner(_courseId, _certificationAuthorityAddress), "Certification Authority must be the owner of this course");
        _;
    }
    
}