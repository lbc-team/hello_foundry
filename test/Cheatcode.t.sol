// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Counter} from "../src/Counter.sol";
import {Owner} from "../src/Owner.sol";
import {MyERC20} from "../src/MyERC20.sol";

contract CheatcodeTest is Test {
    Counter public counter;
    
    function setUp() public {
        counter = new Counter();
        counter.setNumber(0);
    }

    function test_Roll() public {
        counter.increment();
        assertEq(counter.number(), 1);

        uint256 newBlockNumber = 100;
        vm.roll(newBlockNumber);
        console.log("after roll Block number", block.number);

        assertEq(block.number, newBlockNumber);
        assertEq(counter.number(), 1);
    }

    function test_Prank() public {
        console.log("current contract address", address(this));

        Owner o = new Owner();
        console.log("owner address", address(o.owner()));
        assertEq(o.owner(), address(this));

        address alice = makeAddr("alice");
        console.log("alice address", alice);
        vm.prank(alice);

        Owner o2 = new Owner();
        assertEq(o2.owner(), alice);
    }

    function test_Warp() public {
        uint256 newTimestamp = 1693222800;
        vm.warp(newTimestamp);
        console.log("after warp Block timestamp", block.timestamp);
        assertEq(block.timestamp, newTimestamp);

        skip(1000);
        console.log("after skip Block timestamp", block.timestamp);
        assertEq(block.timestamp, newTimestamp + 1000);
    }


    function test_StartPrank() public {
        console.log("current contract address", address(this));

        Owner o = new Owner();
        console.log("owner address", address(o.owner()));
        assertEq(o.owner(), address(this));

        address alice = makeAddr("alice");
        console.log("alice address", alice);

        vm.startPrank(alice);
        Owner o2 = new Owner();
        assertEq(o2.owner(), alice);
        vm.stopPrank();

        Owner o3 = new Owner();
        assertEq(o3.owner(), address(this));
    }

    function test_Deal() public {
        address alice = makeAddr("alice");
        console.log("alice address", alice);
        vm.deal(alice, 100 ether);
        assertEq(alice.balance, 100 ether);

        vm.deal(alice, 1 ether); // Vm.deal
        assertEq(alice.balance, 1 ether);
    }

    function test_Deal_ERC20() public {
        MyERC20 token = new MyERC20("OpenSpace S6", "OS6");
        console.log("token address", address(token));

        address alice = makeAddr("alice");
        console.log("alice address", alice);

        deal(address(token), alice, 100 ether);  // StdCheats.deal

        console.log("alice token balance", token.balanceOf(alice));
        assertEq(token.balanceOf(alice), 100 ether);
    }

}
