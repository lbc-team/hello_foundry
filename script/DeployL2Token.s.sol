// scripts/DeployL2Token.s.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {
    IOptimismMintableERC20Factory
} from "../src/op_stack/IOptimismMintableERC20Factory.sol";
import {BaseScript} from "./BaseScript.s.sol";

contract DeployL2Token is BaseScript {
    // L2 上的工厂合约地址（预部署）
    address constant FACTORY = 0x4200000000000000000000000000000000000012;

    function run() public broadcaster {
        // 你的 L1 代币地址
        address l1Token = 0xc9423Ee04F2afA3A4f73Fa5a21427543a7A5EdbE; // 替换为你的 L1 代币地址

        // 代币信息
        string memory name = "UPTBase";
        string memory symbol = "UPTBase";
        uint8 decimals = 18;

        // 在 L2 上创建对应的代币
        IOptimismMintableERC20Factory factory = IOptimismMintableERC20Factory(
            FACTORY
        );
        address l2Token = factory.createOptimismMintableERC20(
            l1Token, // L1 代币地址
            name, // 代币名称
            symbol // 代币符号
        );
    }
}
