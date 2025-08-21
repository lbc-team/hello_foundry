// scripts/DeployL2Token.s.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { Script } from "forge-std/Script.sol";
import { IOptimismMintableERC20Factory } from "src/interfaces/universal/IOptimismMintableERC20Factory.sol";

contract DeployL2Token is Script {
    // L2 上的工厂合约地址（预部署）
    address constant FACTORY = 0x4200000000000000000000000000000000000012;

    function run() public {
        // 你的 L1 代币地址
        address l1Token = 0x...; // 替换为你的 L1 代币地址

        // 代币信息
        string memory name = "Your Token Name";
        string memory symbol = "YTN";
        uint8 decimals = 18;

        vm.startBroadcast();

        // 在 L2 上创建对应的代币
        IOptimismMintableERC20Factory factory = IOptimismMintableERC20Factory(FACTORY);
        address l2Token = factory.createOptimismMintableERC20WithDecimals(
            l1Token,    // L1 代币地址
            name,       // 代币名称
            symbol,     // 代币符号
            decimals    // 小数位数
        );

        vm.stopBroadcast();

        console.log("L2 Token deployed at:", l2Token);
        console.log("L1 Token address:", l1Token);
    }
}