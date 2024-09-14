// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {IDrisToken} from "../src/IDrisToken.sol";

contract IDrisTokenTest is Test {
    IDrisToken iDrisToken;
    address owner;

    function setUp() public {
        iDrisToken = new IDrisToken();
        owner = address(this);
    }

    function test_Owner_Is_Assigned_Created() public view {
        console.log("iDrisToken.owner()");
        console.log(iDrisToken.owner());
        assertEq(iDrisToken.owner(), owner, "Owner is not properly assigned");
    }

    function test_Owner_Is_Allocated_tokens() public view {
        assertEq(iDrisToken.balanceOf(owner), 100_000 ether, "Owner balance in not properly allocated");
    }
}
