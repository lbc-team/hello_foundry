// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console2} from "forge-std/Test.sol";
import {TokenBank} from "../src/TokenBank.sol";

import {MyERC20} from "../src/MyERC20.sol";


contract TokenBankTest is Test {
    TokenBank public tokenBank;
    MyERC20 public testToken;

    address public alice = makeAddr("alice");
    address public bob = makeAddr("bob");
    uint256 public constant INITIAL_BALANCE = 1000 * 10**18;

    function setUp() public {
        // 部署测试代币
        testToken = new MyERC20("Test Token", "TEST");
        
        // 部署 TokenBank
        tokenBank = new TokenBank(address(testToken), address(0x000000000022D473030F116dDEE9F6B43aC78BA3));
        
        // 给测试账户转账
        testToken.transfer(alice, INITIAL_BALANCE);
        testToken.transfer(bob, INITIAL_BALANCE);
    }

    function test_Deposit() public {
        uint256 depositAmount = 100 * 10**18;
        
        // 切换到 Alice 账户
        vm.startPrank(alice);
        
        // 授权 TokenBank 使用代币
        testToken.approve(address(tokenBank), depositAmount);
        
        // 执行存款
        tokenBank.deposit(depositAmount);
        
        // 验证余额
        assertEq(tokenBank.balanceOf(alice), depositAmount);
        assertEq(tokenBank.totalDeposits(), depositAmount);
        assertEq(testToken.balanceOf(address(tokenBank)), depositAmount);
        
        vm.stopPrank();
    }

    function test_Withdraw() public {
        uint256 depositAmount = 100 * 10**18;
        uint256 withdrawAmount = 50 * 10**18;
        
        // 切换到 Alice 账户
        vm.startPrank(alice);
        
        // 先存款
        testToken.approve(address(tokenBank), depositAmount);
        tokenBank.deposit(depositAmount);
        
        // 记录提款前的余额
        uint256 balanceBefore = testToken.balanceOf(alice);
        
        // 执行提款
        tokenBank.withdraw(withdrawAmount);
        
        // 验证余额
        assertEq(tokenBank.balanceOf(alice), depositAmount - withdrawAmount);
        assertEq(tokenBank.totalDeposits(), depositAmount - withdrawAmount);
        assertEq(testToken.balanceOf(alice), balanceBefore + withdrawAmount);
        
        vm.stopPrank();
    }



    function test_MultipleUsers() public {
        uint256 aliceDeposit = 100 * 10**18;
        uint256 bobDeposit = 200 * 10**18;
        
        // Alice 存款
        vm.startPrank(alice);
        testToken.approve(address(tokenBank), aliceDeposit);
        tokenBank.deposit(aliceDeposit);
        vm.stopPrank();
        
        // Bob 存款
        vm.startPrank(bob);
        testToken.approve(address(tokenBank), bobDeposit);
        tokenBank.deposit(bobDeposit);
        vm.stopPrank();
        
        // 验证总存款
        assertEq(tokenBank.totalDeposits(), aliceDeposit + bobDeposit);
        
        // 验证各个用户的余额
        assertEq(tokenBank.balanceOf(alice), aliceDeposit);
        assertEq(tokenBank.balanceOf(bob), bobDeposit);
    }
} 