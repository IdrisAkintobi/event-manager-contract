// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "lib/EventNFTModifier.sol";

//@Author IdrisAkintobi
contract EventNFT is ERC721URIStorage, EventNFTModifier {
    string public eventTicket;
    uint256 public eventCreatedDate;
    uint256 public tokenCounter;
    uint32 public maxAttendance;
    bool public eventIsOpen;

    // Custom error
    error EventsIsNotOpen();
    error EventCanNotBeInThePast();
    error AddressZeroDetected();
    error MaxAttendanceReached(uint32 maxAttendance);

    // Events
    event toggledEventIsOpen(bool eventIsOpen);
    event grantEventAccess(address to);
    event ticketTransfered(address from, address to, uint256 tokenId);

    /**
     *
     * @param _eventName The name of the event
     * @param _eventSymbol The event symbol
     * @param _eventTicket The ipfs hash of the event metadata, following the opensea token uri metadata standard.
     * ==> https://docs.opensea.io/docs/metadata-standards <==
     * @param _eventEndDate The end date of the event in unix epoch timestamp
     * @param _maxAttendance The number of maximum attandees of the event
     */
    constructor(
        address _eventOwner,
        string memory _eventName,
        string memory _eventSymbol,
        string memory _eventTicket,
        uint64 _eventEndDate,
        uint32 _maxAttendance
    ) ERC721(_eventName, _eventSymbol) EventNFTModifier(_eventOwner, _eventEndDate) {
        if (_eventOwner == address(0)) revert AddressZeroDetected();
        if (_eventEndDate < block.timestamp) revert EventCanNotBeInThePast();
        eventTicket = _eventTicket;
        eventCreatedDate = block.timestamp;
        maxAttendance = _maxAttendance;
    }

    function mintTicket(address _to) public onlyOwner returns (uint256) {
        if (tokenCounter >= maxAttendance) {
            revert MaxAttendanceReached(maxAttendance);
        }
        uint256 newTokenId = ++tokenCounter;

        _safeMint(_to, newTokenId);
        _setTokenURI(newTokenId, eventTicket);
        ticketHolders[newTokenId] = _to;

        return newTokenId;
    }

    function toggleOpenEvent() public onlyOwner activeEvent {
        eventIsOpen = !eventIsOpen;
        emit toggledEventIsOpen(eventIsOpen);
    }

    function updateEventEndDate(uint64 _newEventEndDate) external onlyOwner activeEvent {
        if (block.timestamp > _newEventEndDate) revert EventCanNotBeInThePast();
        eventEndDate = _newEventEndDate;
    }

    function useTicket(uint256 _tokenId) public activeEvent isTicketHolder(_tokenId) {
        if (!eventIsOpen) revert EventsIsNotOpen();
        _burn(_tokenId);

        ticketHolders[_tokenId] = address(0);
        tokenCounter--;
        emit grantEventAccess(msg.sender);
    }

    function transferTicket(uint256 _tokenId, address _to) external activeEvent {
        safeTransferFrom(msg.sender, _to, _tokenId);
        ticketHolders[_tokenId] = _to;

        emit ticketTransfered(msg.sender, _to, _tokenId);
    }
}
