// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/MyERC20.sol";

contract MyERC20Test is Test {
    MyERC20 public token;
    address[] public users;
    
    function setUp() public {
        token = new MyERC20("MyToken", "MTK");
        // console.log("New MyERC20 instance:", address(token));
        
        // 创建一些测试用户
        for (uint i = 1; i <= 10; i++) {
            address user = address(uint160(i));
            users.push(user);
            // 为每个用户分配1000个代币
            token.transfer(user, 1000 * 10 ** 18);
        }
        users.push(address(this));
    }
    
    // 这个函数会被 Foundry 随机调用
    function transfer(uint256 fromIndex, uint256 toIndex, uint256 amount) public {
        // 确保索引在有效范围内
        fromIndex = fromIndex % users.length;
        toIndex = toIndex % users.length;
        
        // 确保不是同一个用户
        vm.assume(fromIndex != toIndex);
        
        // 获取发送者和接收者地址
        address from = users[fromIndex];
        address to = users[toIndex];
        
        // 确保发送者有足够的余额
        uint256 fromBalance = token.balanceOf(from);
        amount = amount % (fromBalance + 1);
        
        // 执行转账
        vm.prank(from);
        token.transfer(to, amount);
    }
    
    function invariant_totalSupplyEqualsSumOfBalances() public view {
        uint256 totalSupply = token.totalSupply();
        uint256 sumOfBalances = 0;
        
        // 计算所有用户余额的总和
        console.log("users.length", users.length);
        for (uint i = 0; i < users.length; i++) {
            sumOfBalances += token.balanceOf(users[i]);
        }
        
        // 验证总供应量等于所有用户余额的总和
        assertEq(totalSupply, sumOfBalances, "Total supply does not equal the sum of all user balances");
    }
    
    // 指定要测试的合约和函数
    function targetContract() public view returns (address) {
        return address(this);
    }
    
    // 指定要测试的函数， 不指定的函数会执行 targetContract 下所有 public 函数 
    function targetSelector() public pure returns (bytes4) {
        return bytes4(keccak256("transfer(uint256,uint256,uint256)"));
    }
} 