// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";

import {DappLinkVRFCore} from "../../src/core/vrf/DappLinkVRFCore.sol";
import {DappLinkVRFFactory} from "../../src/core/DappLinkVRFFactory.sol";
import {ECDSAVerifierProxy} from "../../src/core/verify/ECDSAVerifierProxy.sol";

contract DappLinkVRFDeploy is Script {
    DappLinkVRFCore public core;

    DappLinkVRFFactory public factory;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        core = new DappLinkVRFCore();
        factory = new DappLinkVRFFactory();

        vm.stopBroadcast();
    }
}
