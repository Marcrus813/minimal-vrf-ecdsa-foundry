// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";

import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

import {ECDSAVerifier} from "../../src/core/verify/ECDSAVerifier.sol";
import {IECDSAVerifier} from "../../src/interfaces/IECDSAVerifier.sol";
import {ECDSAVerifierProxy} from "../../src/core/verify/ECDSAVerifierProxy.sol";
import {DappLinkVRFCore} from "../../src/core/vrf/DappLinkVRFCore.sol";
import {IDappLinkVRFCore} from "../../src/interfaces/IDappLinkVRFCore.sol";

import "../../script/deploy/AggregatedDeploy.s.sol";

contract ECDSAVerifierTest is Test {
    error ECDSAVerifierTest__CallFailed(bytes payload, string errorMsg);

    using ECDSA for bytes32;
    using MessageHashUtils for bytes32;

    ECDSAVerifier public verifierCore;
    ECDSAVerifierProxy public verifierProxy;
    ECDSAVerifier public verifier;

    uint256 public baseSnapshot;
    uint256 public signersReadySnapshot;

    address public constant ADMIN = 0xd2D5989e81dE2f0B32c2E3B03d5D295b52c31fe5;

    address[] public newSigners;
    mapping(address => uint256) public signerPrivKeys;

    function setUp() public {
        // string memory rpcEndPoint = vm.prompt("RPC endpoint");
        vm.createSelectFork("mainnet", 23603148);
        vm.deal(ADMIN, 10000e18);

        (verifierCore, verifierProxy) = new AggregatedDeploy()
            .deployEcdsaComponent();

        verifier = ECDSAVerifier(address(verifierProxy));

        _createNewSigners();

        baseSnapshot = vm.snapshotState();
        signersReadySnapshot = getSignersReadySnapshot();
    }

    function getSignersReadySnapshot() public returns (uint256) {
        vm.prank(ADMIN);
        verifier.batchRegisterVerifier(newSigners);

        return vm.snapshotState();
    }

    function test_initialize(address _randomSigner) public {
        vm.revertToState(baseSnapshot);

        vm.assume(_randomSigner != address(0) && _randomSigner != ADMIN);

        // Owner
        address returnedOwner = verifier.owner();
        assertEq(returnedOwner, ADMIN);

        // Min participant
        uint256 returnedMinPart = verifier.minimalParticipants();
        assertEq(returnedMinPart, 1);

        // Initial verifiers
        bool randomRegistry = verifier.checkSigner(_randomSigner);
        assertFalse(randomRegistry);
        bool adminRegistry = verifier.checkSigner(ADMIN);
        assertTrue(adminRegistry);
    }

    function test_setMinParticipantNum() public {
        vm.revertToState(baseSnapshot);

        // State change
        uint256 oldMinPart = verifier.minimalParticipants();
        uint256 newMinPart = 10;

        vm.expectEmit();
        emit IECDSAVerifier.MinimalParticipantsChanged(
            block.number,
            newMinPart
        );

        vm.prank(ADMIN);
        verifier.setMinParticipantNum(newMinPart);

        uint256 finalMinPart = verifier.minimalParticipants();

        assertEq(finalMinPart, newMinPart);
        assertNotEq(finalMinPart, oldMinPart);
    }

    function test_verifySigner(address _randomSignerSeed) public {
        vm.revertToState(signersReadySnapshot);

        vm.assume(
            _randomSignerSeed != address(0) && _randomSignerSeed != ADMIN
        );

        uint256[] memory mockResponse = new uint256[](3);
        mockResponse[0] = 100;
        mockResponse[1] = 200;
        mockResponse[2] = 300;
        bytes memory mockResponseBytes = abi.encodePacked(mockResponse);
        bytes32 msgHash = verifier.generateMsgHash(mockResponseBytes);
        bytes32 prefixedMsgHash = verifier.generateSignedMsg(msgHash);

        // Return false on unregistered signer
        string memory randSignerSeed = Strings.toHexString(_randomSignerSeed);
        (address randSigner, uint256 randPrivKey) = makeAddrAndKey(
            randSignerSeed
        );
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(randPrivKey, msgHash);
        bytes memory signature = abi.encodePacked(r, s, v);

        (bool verification, ECDSA.RecoverError err) = verifier.verifySigner(
            randSigner,
            prefixedMsgHash,
            signature
        );
        assertFalse(verification);
        assertEq(uint8(err), 1);

        // Return true when signer passes
        address pickedSigner = newSigners[0];
        signature = _signArrayResponse(pickedSigner, mockResponse);
        (verification, err) = verifier.verifySigner(
            pickedSigner,
            prefixedMsgHash,
            signature
        );
        assertTrue(verification);
        assertEq(uint8(err), 0);
    }

    function _signArrayResponse(
        address _signer,
        uint256[] memory _response
    ) internal view returns (bytes memory signature) {
        bytes memory responseInBytes = abi.encodePacked(_response);
        bytes32 msgHash = verifier.generateMsgHash(responseInBytes);
        bytes32 prefixedHash = msgHash.toEthSignedMessageHash();

        uint256 signerPrivKey = signerPrivKeys[_signer];
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(signerPrivKey, prefixedHash);
        signature = abi.encodePacked(r, s, v);
    }

    function _createNewSigners() private {
        for (uint256 i = 0; i < 10; i++) {
            (address signer, uint256 key) = makeAddrAndKey(
                string(abi.encodePacked(i))
            );
            newSigners.push(signer);
            signerPrivKeys[signer] = key;
        }
    }
}
