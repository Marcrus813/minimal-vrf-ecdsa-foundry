// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import {IDappLinkVRFCore} from "../../interfaces/IDappLinkVRFCore.sol";
import {ECDSAVerifier} from "../verify/ECDSAVerifier.sol";

contract DappLinkVRFCore is
    IDappLinkVRFCore,
    Initializable,
    OwnableUpgradeable
{
    struct RequestStatus {
        bool fulfilled;
        uint256 numWords;
        address consumer;
        uint256[] randomWords;
    }

    mapping(uint256 => RequestStatus) public requests;
    uint256 public lastRequestId;
    uint256[] public requestIds;

    ECDSAVerifier public verifier;
    address public dappLinkSubmitter;

    uint256[100] private _preservedSlots;

    modifier onlyValidSubmitter() {
        require(msg.sender == dappLinkSubmitter, IDappLinkVRFCore__InvalidSubmitter(msg.sender));
        _;
    }

    constructor() {
        _disableInitializers();
    }

    function initialize(
        address _initialOwner,
        ECDSAVerifier _verifier,
        address _initialValidSubmitter
    ) public initializer {
        __Ownable_init(_initialOwner);
        verifier = _verifier;
        dappLinkSubmitter = _initialValidSubmitter;
    }

    function requestRandomWords(uint256 _numWords) external returns (uint256) {
        address consumer = msg.sender;
        uint256[] memory empty;

        RequestStatus memory requestStatus = RequestStatus({
            fulfilled: false,
            numWords: _numWords,
            consumer: consumer,
            randomWords: empty
        });

        uint256 newRequestId = lastRequestId + 1;
        requestIds.push(newRequestId); // Will start from 1
        requests[newRequestId] = requestStatus;

        lastRequestId = newRequestId;
        emit RandomWordsRequested(newRequestId, consumer);
        return newRequestId;
    }

    function fulfilRandomWords(
        uint256 _requestId,
        uint256[] memory _randomWords,
        address[] memory _signers,
        bytes[] memory _sigs
    ) external onlyValidSubmitter {
        RequestStatus memory requestStatus = requests[_requestId];
        require(
            requestStatus.numWords == _randomWords.length,
            IDappLinkVRFCore__InvalidData(_requestId)
        );

        bytes memory data = abi.encodePacked(_randomWords);
        verifier.verifyResponse(data, _signers, _sigs); // Check done within verifier
    
        _callbackConsumer(requestStatus.consumer, _requestId, _randomWords, "");
        requestStatus.fulfilled = true;
        requestStatus.randomWords = _randomWords;
        requests[_requestId] = requestStatus;
        emit RandomWordsFulfilled(_requestId, _randomWords);
    }

    function getRequestStatus(
        uint256 _requestId
    ) external view returns (bool, uint256[] memory) {}

    function updateDappLinkSubmitter(address _newSubmitter) external onlyOwner {
        dappLinkSubmitter = _newSubmitter;
        emit SubmitterUpdated(_newSubmitter);
    }

    function _callbackConsumer(
        address _consumer,
        uint256 _requestId,
        uint256[] memory _randomWords,
        bytes memory _data
    ) internal {
        bytes memory payload = abi.encodeWithSignature(
            "fulfilRandomWords(uint256,uint256[],bytes)",
            _requestId,
            _randomWords,
            _data
        );

        (bool success, ) = _consumer.call(payload);
        require(success, IDappLinkVRFCore__CallbackFailed(_requestId, _consumer));
        emit CallbackSucceeded(_requestId, _consumer);
    }
}
