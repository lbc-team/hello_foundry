// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Owner {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    event OwnerTransfer(address indexed caller, address indexed newOwner);

    function transferOwnership(address newOwner) public {
        require(msg.sender == owner, "Only the owner can transfer ownership");
        owner = newOwner;
        emit OwnerTransfer(msg.sender, newOwner);
    }

    error NotOwner(address caller);
    function transferOwnership2(address newOwner) public {
        if (msg.sender != owner) revert NotOwner(msg.sender);
        owner = newOwner;
    }
}
