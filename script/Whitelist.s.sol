// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./BaseScript.s.sol";
import "../src/Whitelist.sol";

contract WhitelistScript is BaseScript {
    function run() external {
        setUp();
        
        vm.startBroadcast(deployerPrivateKey);
        
        // 部署白名单合约
        Whitelist whitelist = new Whitelist();
        
        console.log("Whitelist deployed at:", address(whitelist));
        console.log("Owner:", whitelist.owner());
        console.log("Signer:", whitelist.signer());
        
        vm.stopBroadcast();
        
        // 保存合约地址
        saveContract("Whitelist", address(whitelist));
    }
}

