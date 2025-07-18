// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Counter} from "../src/Counter.sol";
import {Owner} from "../src/Owner.sol";
import {MyERC20} from "../src/MyERC20.sol";

contract ForkTest is Test {
    Counter public counter;
    address public alice;
    address public bob;
    uint256 public sepoliaForkId;
    uint256 public polygonForkId;
    function setUp() public {
        uint forkBlock = 8219000;
        sepoliaForkId = vm.createSelectFork(vm.rpcUrl("sepolia"), forkBlock);

        uint256 polygonForkBlock = 30_000_000;
        polygonForkId = vm.createSelectFork(vm.rpcUrl("polygon"), polygonForkBlock);
    }

    function test_Something() public {

        vm.selectFork(sepoliaForkId);
        assertEq(vm.activeFork(), sepoliaForkId);

        MyERC20 token = MyERC20(0x21b4D1f6d42dc6083db848D42AA4b6895371E1e7);
        assertGe(token.balanceOf(0xe74c813e3f545122e88A72FB1dF94052F93B808f), 2e18);
    }


    function test_PolygonSomething() public {
        vm.selectFork(polygonForkId);
        assertEq(vm.activeFork(), polygonForkId);

    }

}
