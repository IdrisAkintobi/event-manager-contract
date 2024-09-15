// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "./EventNFT.sol";
import "../interface/IERC20.sol";

contract EventManager {
    address eventManagerOwner;
    IERC20 eventManagerToken;
    uint256 public eventCreationCharge;

    mapping(uint256 => address) public events;
    uint256 public noOfEvents;

    error AddressZeroDetected();
    error InvalidInput();
    error Unauthorized();

    event EventNFTCreated(uint256 _index, address _deployedTo);

    constructor(address _eventManagerToken, uint256 _eventCreationCharge) {
        eventManagerOwner = msg.sender;
        eventManagerToken = IERC20(_eventManagerToken);
        eventCreationCharge = _eventCreationCharge;
    }

    function createEventNFT(
        address _eventOwner,
        string memory _eventName,
        string memory _eventSymbol,
        string memory _eventTicket,
        uint64 _eventEndDate,
        uint32 _maxAttendance
    ) public returns (uint256 _index, address _deployedTo) {
        if (_eventOwner == address(0)) revert AddressZeroDetected();
        // Deduct charges to create an event from the event creator
        eventManagerToken.transferFrom(_eventOwner, eventManagerOwner, eventCreationCharge);

        EventNFT newEventNFT =
            new EventNFT(_eventOwner, _eventName, _eventSymbol, _eventTicket, _eventEndDate, _maxAttendance);

        _deployedTo = address(newEventNFT);
        _index = ++noOfEvents;

        events[_index] = _deployedTo;

        emit EventNFTCreated(_index, _deployedTo);
    }

    function updateEventCreationCharge(uint256 _newChargeAmount) external {
        if (msg.sender == address(0)) revert AddressZeroDetected();
        if (msg.sender != eventManagerOwner) revert Unauthorized();
        if (_newChargeAmount <= 0) revert InvalidInput();
        eventCreationCharge = _newChargeAmount;
    }
}
