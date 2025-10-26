// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";

import "./DappLinkVRFDeploy.s.sol";
import "./ECDSAVerifierDeploy.s.sol";

contract AggregatedDeploy is Script {
    uint256 public deployerPrivKey;
    address public deployer;

    ECDSAVerifierDeploy public ecdsaDeployment;
    DappLinkVRFDeploy public vrfDeployment;

    struct DeployedContracts {
        ECDSAVerifier verifier;
        ECDSAVerifierProxy verifierProxy;
        DappLinkVRFCore vrfCore;
        DappLinkVRFFactory vrfFactory;
    }

    function deployEcdsaComponent()
        public
        returns (ECDSAVerifier, ECDSAVerifierProxy)
    {
        _setUpDeployer();
        ecdsaDeployment = new ECDSAVerifierDeploy();
        ecdsaDeployment.setUp(deployer);
        ecdsaDeployment.run();
        return (ecdsaDeployment.implementation(), ecdsaDeployment.proxy());
    }

    function deployVrfComponent()
        public
        returns (DappLinkVRFCore, DappLinkVRFFactory)
    {
        vrfDeployment = new DappLinkVRFDeploy();
        vrfDeployment.run();
        return (vrfDeployment.core(), vrfDeployment.factory());
    }

    function setUp() public {}

    function run()
        public
        returns (
            ECDSAVerifier,
            ECDSAVerifierProxy,
            DappLinkVRFCore,
            DappLinkVRFFactory
        )
    {
        ECDSAVerifier verifier;
        ECDSAVerifierProxy verifierProxy;

        DappLinkVRFCore vrfCore;
        DappLinkVRFFactory vrfFactory;
        (verifier, verifierProxy) = deployEcdsaComponent();
        (vrfCore, vrfFactory) = deployVrfComponent();

        return (verifier, verifierProxy, vrfCore, vrfFactory);
    }

    function _setUpDeployer() private {
        deployerPrivKey = vm.envUint("SEPOLIA_PRIV_KEY");
        deployer = vm.addr(deployerPrivKey);
    }
}
