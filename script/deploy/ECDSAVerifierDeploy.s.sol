// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";

import {ECDSAVerifier} from "../../src/core/verify/ECDSAVerifier.sol";
import {ECDSAVerifierProxy} from "../../src/core/verify/ECDSAVerifierProxy.sol";

contract ECDSAVerifierDeploy is Script {
    ECDSAVerifier public implementation;
    ECDSAVerifierProxy public proxy;
    bytes public initializationData;

    function setUp(address _initialOwner) public {
        address[] memory initialVerifiers = new address[](1);
        initialVerifiers[0] = _initialOwner;
        uint256 minimalParticipants = 1;
        initializationData = abi.encodeWithSignature(
            "initialize(address,uint256,address[])",
            _initialOwner,
            minimalParticipants,
            initialVerifiers
        );
    }

    function run() public {
        vm.startBroadcast();

        implementation = new ECDSAVerifier();
        proxy = new ECDSAVerifierProxy(
            address(implementation),
            initializationData
        );

        vm.stopBroadcast();
    }
}
