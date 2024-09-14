// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

import {Script, console} from "forge-std/Script.sol";
import {IDrisToken} from "../src/IDrisToken.sol";

contract IDrisTokenScript is Script {
    IDrisToken public iDrisToken;

    function setUp() public {}

    function run() public {
        // Start the broadcast
        vm.startBroadcast(vm.envUint("DO_NOT_LEAK"));

        // Deploy the contract
        iDrisToken = new IDrisToken();

        // Stop broadcasting
        vm.stopBroadcast();

        console.log("AreaCalculator deployed to:", address(iDrisToken));
    }
}
