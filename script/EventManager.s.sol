// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

import {Script, console} from "forge-std/Script.sol";
import {EventManager} from "../src/EventManager.sol";

contract EventManagerScript is Script {
    address eventManagerToken = vm.envAddress("EVENT_MANAGER_TOKEN");
    uint256 public constant EVENT_CREATION_CHARGE = 1 gwei;

    EventManager eventManager;

    function setUp() public {}

    function run() public {
        // Start the broadcast
        vm.startBroadcast(vm.envUint("DO_NOT_LEAK"));

        // Deploy the contract
        eventManager = new EventManager(
            eventManagerToken,
            EVENT_CREATION_CHARGE
        );

        // Stop broadcasting
        vm.stopBroadcast();

        console.log("EventManager deployed to:", address(eventManager));
    }
}
