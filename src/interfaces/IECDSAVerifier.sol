// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

interface IECDSAVerifier {
    error IECDSAVerifier__InvalidSignaturePackage();
    error IECDSAVerifier__InvalidSignature(uint256 sigIndex, ECDSA.RecoverError errType);

    event VerifiersInitialized(uint256 indexed blockNum, bytes32 arrayHash);
    event VerifierRegistered(uint256 indexed blockNum, address indexed signer);
    event VerifierUnregistered(
        uint256 indexed blockNum,
        address indexed signer
    );
    event MinimalParticipantsChanged(
        uint256 indexed blockNum,
        uint256 requirement
    );

    function registerVerifier(address _verifier) external returns (uint256);

    function unregisterVerifier(address _signer) external returns (uint256);

    function generateMsgHash(
        bytes memory _encodedData
    ) external pure returns (bytes32);

    function generateSignedMsg(
        bytes32 _msgHash
    ) external pure returns (bytes32);

    function verifyResponse(
        bytes memory _msg,
        address[] memory _verifiers,
        bytes[] memory _signatures
    ) external view returns (bool);

    function verifySigner(
        address _expected,
        bytes32 _signedMsgHash,
        bytes memory _sig
    ) external view returns (bool, ECDSA.RecoverError);

    function checkSigner(address _signer) external view returns (bool);

    function setMinParticipantNum(uint256 _minPart) external;
}
