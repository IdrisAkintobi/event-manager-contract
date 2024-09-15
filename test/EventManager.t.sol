// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "forge-std/Test.sol";
import "../src/EventNFT.sol";
import "../src/EventManager.sol";
import {IDrisToken} from "../src/IDrisToken.sol";

contract EventNFTManagerTest is Test {
    IDrisToken iDrisToken;
    address eventManagerOwner;

    uint256 public constant EVENT_CREATION_CHARGE = 1 gwei;

    EventNFT public eventNFT;
    EventManager public eventManager;
    address public eventNFTOwner = vm.addr(1);
    address public ticketHolder = vm.addr(2);
    address public ticketHolder1 = vm.addr(2);
    string public eventName = "Concert";
    string public eventSymbol = "CNCT";
    string public eventTicket = "ipfs://event-ticket-hash";
    uint64 public eventEndDate = uint64(block.timestamp + 1 weeks);
    uint32 public maxAttendance = 10;

    function setUp() public {
        eventManagerOwner = address(this);

        // Deploy a mock ERC20 token
        iDrisToken = new IDrisToken();

        // Mint tokens to the eventNFTOwner to pay the event creation fee
        deal(address(iDrisToken), eventNFTOwner, EVENT_CREATION_CHARGE);

        // Deploy the EventManager contract
        eventManager = new EventManager(address(iDrisToken), EVENT_CREATION_CHARGE);

        // Start pranking as the eventNFTOwner to create the event manager and event
        vm.startPrank(eventNFTOwner);
        iDrisToken.approve(address(eventManager), EVENT_CREATION_CHARGE);

        // Create an event using EventManager
        (, address eventAddress) =
            eventManager.createEventNFT(eventNFTOwner, eventName, eventSymbol, eventTicket, eventEndDate, maxAttendance);
        vm.stopPrank();

        // Set the deployed EventNFT
        eventNFT = EventNFT(eventAddress);
    }

    function testUpdateEventCreationCharge() public {
        eventManager.updateEventCreationCharge(2 gwei);
        // Check if the event is creation charge is updated
        assertEq(eventManager.eventCreationCharge(), 2 gwei);
    }

    function testEventCreation() public view {
        // Check if the event is created
        assertEq(eventNFT.eventTicket(), eventTicket);
        assertEq(eventNFT.eventEndDate(), eventEndDate);
        assertEq(eventNFT.maxAttendance(), maxAttendance);
        assertEq(eventNFT.owner(), eventNFTOwner);
    }

    function testMintTicket() public {
        vm.prank(eventNFTOwner);
        uint256 tokenId = eventNFT.mintTicket(eventNFTOwner);
        assertEq(tokenId, 1);
        assertEq(eventNFT.ownerOf(tokenId), eventNFTOwner);
        assertEq(eventNFT.tokenCounter(), 1);
    }

    function testMaxAttendanceReached() public {
        vm.startPrank(eventNFTOwner);

        // Mint tickets until maxAttendance is reached
        for (uint32 i = 1; i <= maxAttendance; i++) {
            eventNFT.mintTicket(eventNFTOwner);
        }

        // Try to mint one more ticket and expect a revert
        vm.expectRevert(abi.encodeWithSelector(EventNFT.MaxAttendanceReached.selector, maxAttendance));
        eventNFT.mintTicket(eventNFTOwner);
        vm.stopPrank();
    }

    function testToggleEventOpen() public {
        vm.prank(eventNFTOwner);
        eventNFT.toggleOpenEvent();
        assertTrue(eventNFT.eventIsOpen());
    }

    function testUseTicket() public {
        vm.prank(eventNFTOwner);
        uint256 tokenId = eventNFT.mintTicket(eventNFTOwner);

        vm.prank(eventNFTOwner);
        eventNFT.toggleOpenEvent();

        vm.prank(eventNFTOwner);
        eventNFT.useTicket(tokenId);

        // Check if the ticket is burned
        vm.expectRevert(abi.encodeWithSignature("ERC721NonexistentToken(uint256)", 1));
        eventNFT.ownerOf(tokenId);
    }

    function testTransferTicket() public {
        vm.prank(eventNFTOwner);
        uint256 tokenId = eventNFT.mintTicket(ticketHolder);

        vm.prank(ticketHolder);
        eventNFT.transferTicket(tokenId, ticketHolder1);

        assertEq(eventNFT.ticketHolders(tokenId), ticketHolder1);
    }

    function testUpdateEventEndDate() public {
        uint64 newEventEndDate = uint64(block.timestamp + 1 days);
        vm.prank(eventNFTOwner);
        eventNFT.updateEventEndDate(newEventEndDate);

        assertEq(eventNFT.eventEndDate(), newEventEndDate);
    }

    function testCannotUseTicketWhenEventIsClosed() public {
        vm.prank(eventNFTOwner);
        uint256 tokenId = eventNFT.mintTicket(ticketHolder);

        // Expect revert since the event is not open
        vm.prank(ticketHolder);
        vm.expectRevert(EventNFT.EventsIsNotOpen.selector);
        eventNFT.useTicket(tokenId);
    }
}
