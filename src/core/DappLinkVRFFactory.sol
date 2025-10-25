// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";

import {ECDSAVerifier} from "./verify/ECDSAVerifier.sol";
import {DappLinkVRFCore} from "./vrf/DappLinkVRFCore.sol";

contract DappLinkVRFFactory {
    event CloneCreated(address indexed clone, address indexed implementation);

    function createClone(address _implementation, address _verifierAddress, address _dappLinkSubmitter, bytes32 _salt) external returns (address) {
        ECDSAVerifier verifier = ECDSAVerifier(_verifierAddress);

        address clone = Clones.cloneDeterministic(_implementation, _salt);
        DappLinkVRFCore(clone).initialize(msg.sender, verifier, _dappLinkSubmitter);

        emit CloneCreated(clone, _implementation);

        return clone;
    }
}
