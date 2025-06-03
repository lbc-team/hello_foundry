// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "./BaseScript.s.sol";
import "../src/SimpleDelegateContract.sol";

contract CounterScript is BaseScript {
    function run() public broadcaster {
        SimpleDelegateContract sdc = new SimpleDelegateContract();
        console.log("SimpleDelegateContract deployed on %s", address(sdc));
        saveContract("SimpleDelegateContract", address(sdc));
    }
}
