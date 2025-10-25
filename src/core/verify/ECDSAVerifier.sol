// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

import {IECDSAVerifier} from "../../interfaces/IECDSAVerifier.sol";

contract ECDSAVerifier is
    IECDSAVerifier,
    Initializable,
    UUPSUpgradeable,
    OwnableUpgradeable
{
    mapping(address => bool) public registeredVerifiers;
    uint256 public minimalParticipants;

    constructor() {
        _disableInitializers();
    }

    function initialize(
        address _initialOwner,
        uint256 _minimalParticipants,
        address[] memory initialVerifiers
    ) public initializer {
        __Ownable_init(_initialOwner);
        minimalParticipants = _minimalParticipants;
        _initializeVerifiers(initialVerifiers);
    }

    function registerVerifier(
        address _verifierAddr
    ) external onlyOwner returns (uint256) {
        registeredVerifiers[_verifierAddr] = true;
        emit IECDSAVerifier.VerifierRegistered(block.number, _verifierAddr);
        return block.number;
    }

    function unregisterVerifier(
        address _signer
    ) external onlyOwner returns (uint256) {
        registeredVerifiers[_signer] = false;
        emit IECDSAVerifier.VerifierUnregistered(block.number, _signer);
        return block.number;
    }

    // Require any data to be converted to bytes format first
    function generateMsgHash(
        bytes memory _encodedData
    ) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_encodedData));
    }

    /*
     * Getting the data that actually got signed
     */
    function generateSignedMsg(bytes32 _msgHash) public pure returns (bytes32) {
        return
            keccak256(
                abi.encodePacked("\x19Ethereum Signed Message:\n32", _msgHash)
            );
    }

    function verifyResponse(
        bytes memory _msg,
        address[] memory _verifiers,
        bytes[] memory _signatures
    ) public view returns (bool) {
        require(_signatures.length >= minimalParticipants, IECDSAVerifier__InvalidSignaturePackage());
        require(
            _verifiers.length == _signatures.length,
            IECDSAVerifier__InvalidSignaturePackage()
        );
        bytes32 msgHash = generateMsgHash(_msg);
        bytes32 ethSignedHash = generateSignedMsg(msgHash);
        for (uint256 i = 0; i < _verifiers.length; i++) {
            address currentSigner = _verifiers[i];
            bytes memory currentSignature = _signatures[i];
            (bool result, ECDSA.RecoverError err) = verifySigner(
                currentSigner,
                ethSignedHash,
                currentSignature
            );
            require(result, IECDSAVerifier__InvalidSignature(i, err));
        }

        return true;
    }

    function verifySigner(
        address _provided,
        bytes32 _signedMsgHash,
        bytes memory _sig
    ) public view returns (bool, ECDSA.RecoverError) {
        if (!checkSigner(_provided)) {
            return (false, ECDSA.RecoverError(1));
        }

        (address recoveredAddr, ECDSA.RecoverError err, ) = ECDSA.tryRecover(
            _signedMsgHash,
            _sig
        );
        if (err != ECDSA.RecoverError(0)) {
            return (false, err);
        }
        if (recoveredAddr == _provided) {
            return (true, ECDSA.RecoverError(0));
        }
        return (false, ECDSA.RecoverError(1));
    }

    function checkSigner(address _signer) public view returns (bool) {
        return registeredVerifiers[_signer];
    }

    function setMinParticipantNum(uint256 _minPart) external onlyOwner {
        minimalParticipants = _minPart;
        emit IECDSAVerifier.MinimalParticipantsChanged(block.number, _minPart);
    }

    function _initializeVerifiers(address[] memory _initialVerifiers) internal {
        for (uint256 i; i < _initialVerifiers.length; i++) {
            address verifier = _initialVerifiers[i];
            registeredVerifiers[verifier] = true;
        }
        emit IECDSAVerifier.VerifiersInitialized(
            block.number,
            generateMsgHash(abi.encode(_initialVerifiers))
        );
    }

    function _authorizeUpgrade(address _newImplementation) internal override {}
}
