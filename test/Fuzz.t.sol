// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Counter} from "../src/Counter.sol";
import {Owner} from "../src/Owner.sol";
import {MyERC20} from "../src/MyERC20.sol";

contract FuzzTest is Test {
    Counter public counter;
    address public alice;
    address public bob;
    MyERC20 public token;
    function setUp() public {
        counter = new Counter();
        token = new MyERC20("Test", "TEST");
    }

    function testFuzz_SetNumber(uint256 x) public {
        counter.setNumber(x);
        assertEq(counter.number(), x);
    }

    function testFuzz_ERC20Transfer(address to, uint256 amount) public {
        // console.log("token:", address(token)); // 无法打印日志
        vm.assume(to != address(0));
        vm.assume(to != address(this));
        amount = bound(amount, 0, 10000 * 10 ** 18);
        // vm.assume(amount <= token.balanceOf(address(this)));
        
        token.transfer(to, amount);
        assertEq(token.balanceOf(to), amount);
    }



}
