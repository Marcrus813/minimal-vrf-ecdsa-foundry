// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IDappLinkVRFCore {
    error IDappLinkVRFCore__InvalidSubmitter(address invalid);
    error IDappLinkVRFCore__InvalidData(uint256 requestId);
    error IDappLinkVRFCore__VerificationFailed(uint256 requestId);
    error IDappLinkVRFCore__CallbackFailed(uint256 requestId, address consumer);

    event SubmitterUpdated(address indexed newSubmitter);

    event RandomWordsRequested(
        uint256 indexed requestId,
        address indexed consumer
    );
    event RandomWordsFulfilled(
        uint256 indexed requestId,
        uint256[] randomWords
    );
    event CallbackSucceeded(uint256 indexed requestId, address consumer);

    function requestRandomWords(uint256 _numWords) external returns (uint256);

    function fulfilRandomWords(
        uint256 _requestId,
        uint256[] memory _randomWords,
        address[] memory _signers,
        bytes[] memory _sigs
    ) external;

    function getRequestStatus(
        uint256 _requestId
    ) external view returns (bool, uint256[] memory);

    function updateDappLinkSubmitter(address _newSubmitter) external;
}
