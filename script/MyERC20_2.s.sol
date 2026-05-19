// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "./BaseScript.s.sol";
import "../src/MyERC20.sol";

contract ERC20Script is BaseScript {
    function run() public broadcaster {
        MyERC20 token = new MyERC20("UPT2026", "UPT2026");
        console.log("UPT2026 deployed on %s", address(token));
        saveContract("UPT2026", address(token));
    }
}
