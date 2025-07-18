// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Counter} from "../src/Counter.sol";

contract CounterTest is Test {
    Counter public counter;

    function setUp() public {
        counter = new Counter();
        counter.setNumber(0);
    }

    function test_Increment() public {
        counter.increment();
        assertEq(counter.number(), 1);

        // counter.increment();
        // assertEq(counter.number(), 2);

        console.log("Block number", block.number);
    }

    function testFuzz_SetNumber(uint256 x) public {
        assertEq(counter.number(), 0);  // 上一次的测试不会影响下一次的测试
        counter.setNumber(x);
        assertEq(counter.number(), x);
    }
}
