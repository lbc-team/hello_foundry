// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {MyERC20} from "../src/MyERC20.sol";

contract MyERC20Script is Script {
    MyERC20 public myERC20;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        myERC20 = new MyERC20("OpenSpace S6", "OS6");
        vm.stopBroadcast();
    }
}
