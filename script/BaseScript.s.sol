// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";

abstract contract BaseScript is Script {
    address internal deployer;
    address internal user;
    string internal mnemonic;
    uint256 internal deployerPrivateKey;

    function setUp() public virtual {
        // mnemonic = vm.envString("MNEMONIC");
        // (deployer, ) = deriveRememberKey(mnemonic, 0);
        // console.log("deployer: %s", deployer);

        deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        // user = vm.addr(deployerPrivateKey);
        // console.log("deployer: %s", user);
    }


    function saveContract(string memory name, address addr) public {
        string memory chainId = vm.toString(block.chainid);
        
        string memory json1 = "key";
        string memory finalJson =  vm.serializeAddress(json1, "address", addr);
        string memory dirPath = string.concat(string.concat("deployments/", name), "_");
        vm.writeJson(finalJson, string.concat(dirPath, string.concat(chainId, ".json"))); 
    }

    modifier broadcaster() {
        vm.startBroadcast(deployerPrivateKey);
        _;
        vm.stopBroadcast();
    }
}
