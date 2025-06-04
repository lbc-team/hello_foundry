// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "./BaseScript.s.sol";
import "../src/EIP712Verifier.sol";

import "../src/MyERC20.sol";
import "../src/TokenBank.sol";

contract TokenbankScript is BaseScript {
    function run() public broadcaster {

        address erc20token = 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512;


        TokenBank tokenBank = new TokenBank(address(erc20token), address(0x000000000022D473030F116dDEE9F6B43aC78BA3));
        console.log("TokenBank deployed on %s", address(tokenBank));
        saveContract("TokenBank", address(tokenBank));
    }
}
