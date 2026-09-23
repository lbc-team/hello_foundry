// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";

import "./BaseScript.s.sol";
import {Counter} from "../src/Counter.sol";

contract CounterScript is BaseScript {
    Counter public counter;

    function run() public broadcaster {
        counter = new Counter();
        console.log("Counter deployed on %s", address(counter));

        saveContract("Counter", address(counter));

        counter.setNumber(10);
        counter.increment();
    }
}
