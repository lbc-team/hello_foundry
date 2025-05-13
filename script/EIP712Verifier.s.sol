// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "./BaseScript.s.sol";
import "../src/EIP712Verifier.sol";

contract CounterScript is BaseScript {
    function run() public broadcaster {
        EIP712Verifier verifier = new EIP712Verifier();
        console.log("EIP712Verifier deployed on %s", address(verifier));
        saveContract("EIP712Verifier", address(verifier));
    }
}
