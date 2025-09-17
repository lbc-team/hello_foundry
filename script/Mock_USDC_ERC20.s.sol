// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "./BaseScript.s.sol";
import "../src/MyERC20.sol";

contract ERC20Script is BaseScript {
    function run() public broadcaster {
        MyERC20 token = new MyERC20("Mock USDC", "MUSDC");
        console.log("Mock USDC deployed on %s", address(token));
        saveContract("MUSDC", address(token));
    }
}
