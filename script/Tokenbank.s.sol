// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "./BaseScript.s.sol";
import "../src/EIP712Verifier.sol";

import "../src/MyERC20.sol";
import "../src/TokenBank.sol";

contract TokenbankScript is BaseScript {
    function run() public broadcaster {

        MyERC20 token = new MyERC20("OpenSpace S6", "OS6");
        console.log("MyERC20 deployed on %s", address(token));
        saveContract("MyERC20", address(token));

        TokenBank tokenBank = new TokenBank(address(token), address(0x000000000022D473030F116dDEE9F6B43aC78BA3));
        console.log("TokenBank deployed on %s", address(tokenBank));
        saveContract("TokenBank", address(tokenBank));
    }
}
