// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

abstract contract EventNFTModifier {
    address public owner;
    uint64 public eventEndDate;
    mapping(uint256 => address) public ticketHolders;

    error EventNFTModifierUnauthorizedAccount(address account);
    error EventNFTModifierNotTheTicketHolder();
    error EventNFTModifierInvalidOwner(address owner);
    error EventHasEnded(uint256 eventEndDate);

    constructor(address initialOwner, uint64 _eventEndDate) {
        if (initialOwner == address(0)) {
            revert EventNFTModifierInvalidOwner(address(0));
        }
        owner = initialOwner;
        eventEndDate = _eventEndDate;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        if (msg.sender != owner) {
            revert EventNFTModifierUnauthorizedAccount(msg.sender);
        }
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier isTicketHolder(uint256 tokenId) {
        _checkTicketHolder(tokenId);
        _;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkTicketHolder(uint256 tokenId) internal view virtual {
        if (msg.sender != ticketHolders[tokenId]) {
            revert EventNFTModifierNotTheTicketHolder();
        }
    }

    modifier activeEvent() {
        if (block.timestamp > eventEndDate) revert EventHasEnded(eventEndDate);
        _;
    }
}
