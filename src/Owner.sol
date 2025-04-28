// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Owner {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    function transferOwnership(address newOwner) public {
        require(msg.sender == owner, "Only the owner can transfer ownership");
        owner = newOwner;
    }
}
