// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IDappLinkVRFConsumer {
    function fulfilRandomWords(
        uint256 _requestId,
        uint256[] memory _randomWords,
        bytes memory _data
    ) external;
}
