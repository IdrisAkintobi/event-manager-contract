// SPDX-License-Identifier: UNLICENCED
pragma solidity ^0.8.26;

interface IERC20 {
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}
