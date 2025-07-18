// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Counter} from "../src/Counter.sol";
import {Owner} from "../src/Owner.sol";
import {MyERC20} from "../src/MyERC20.sol";

contract CheatcodeTest is Test {
    Counter public counter;
    address public alice;
    address public bob;

    function setUp() public {
        counter = new Counter();
        alice = makeAddr("alice");
        bob = makeAddr("bob");
        // console.log("New Counter instance:", address(counter));
    }

    function testFuzz_SetNumber(uint256 x) public {
        counter.setNumber(x);
        assertEq(counter.number(), x);
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



    function test_Warp() public {
        uint256 newTimestamp = 1753207525; 
        vm.warp(newTimestamp);
        console.log("after warp Block timestamp", block.timestamp);
        assertEq(block.timestamp, newTimestamp);

        skip(1000);
        console.log("after skip Block timestamp", block.timestamp);
        assertEq(block.timestamp, newTimestamp + 1000);
    }


    function test_Prank() public {
        console.log("current contract address", address(this));
        console.log("test_Prank  counter address", address(counter));

        Owner o = new Owner();
        console.log("owner address", address(o.owner()));
        assertEq(o.owner(), address(this));

        console.log("alice address", alice);
        vm.prank(alice);
        Owner o2 = new Owner();
        assertEq(o2.owner(), alice);
    }

    function test_StartPrank() public {
        console.log("current contract address", address(this));
        console.log("test_StartPrank  counter address", address(counter));

        Owner o = new Owner();
        console.log("owner address", address(o.owner()));
        assertEq(o.owner(), address(this));

        vm.startPrank(alice);
        Owner o2 = new Owner();
        assertEq(o2.owner(), alice);


        Owner o4 = new Owner();
        assertEq(o4.owner(), alice);

        vm.stopPrank();

        Owner o3 = new Owner();
        assertEq(o3.owner(), address(this));
    }

    function test_Deal() public {
        vm.deal(alice, 100 ether);
        assertEq(alice.balance, 100 ether);

        vm.deal(alice, 1 ether); // Vm.deal
        assertEq(alice.balance, 1 ether);
    }

    function test_Deal_ERC20() public {
        MyERC20 token = new MyERC20("OpenSpace S7", "OS6");
        console.log("token address", address(token));

        console.log("alice address", alice);

        // 1 token = 10 ^ 18 
        deal(address(token), alice, 100e18);  // StdCheats.deal

        console.log("alice token balance", token.balanceOf(alice));
        assertEq(token.balanceOf(alice), 100 ether);
    }

// forge test test/Cheatcode.t.sol --mt test_Revert_IFNOT_Owner -vv
    function test_Revert_IFNOT_Owner() public {
        
        vm.startPrank(alice);
        Owner o = new Owner();
        vm.stopPrank();

        vm.startPrank(bob);
        // vm.expectRevert();
        vm.expectRevert("Only the owner can transfer ownership"); // 预期下一条语句会revert
        o.transferOwnership(alice);
        vm.stopPrank();

    }

    function test_Revert_IFNOT_Owner2() public {
        vm.startPrank(alice);
        Owner o = new Owner();
        vm.stopPrank();

        vm.startPrank(bob);
        bytes memory data = abi.encodeWithSignature("NotOwner(address)", bob);
        vm.expectRevert(data); // 预期下一条语句会revert
        o.transferOwnership2(alice);
        vm.stopPrank();
    }

    event OwnerTransfer(address indexed caller, address indexed newOwner);
    function test_Emit() public {
        Owner o = new Owner();

        // function expectEmit(bool checkTopic1, bool checkTopic2, bool checkTopic3, bool checkData) external;
        vm.expectEmit(true, true, false, false);
        emit OwnerTransfer(address(this), bob);

        o.transferOwnership(bob);
    }

}
