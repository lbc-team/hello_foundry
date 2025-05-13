// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console2} from "forge-std/Test.sol";
import {MultiSigWallet} from "../src/MultiSigWallet.sol";

// 创建一个测试用的目标合约
contract TargetContract {
    uint256 public value;
    address public sender;
    
    function setValue(uint256 _value) external payable {
        value = _value;
        sender = msg.sender;
    }
}

contract MultiSigWalletTest is Test {
    MultiSigWallet public wallet;
    TargetContract public target;
    
    // 测试账户
    address public alice = makeAddr("alice");
    address public bob = makeAddr("bob");
    address public charlie = makeAddr("charlie");
    address public dave = makeAddr("dave");
    
    // 测试数据
    uint256 public constant TEST_VALUE = 42;
    uint256 public constant TEST_ETH = 1 ether;
    
    function setUp() public {
        // 部署目标合约
        target = new TargetContract();
        
        // 创建多签持有者数组
        address[] memory owners = new address[](3);
        owners[0] = alice;
        owners[1] = bob;
        owners[2] = charlie;
        
        // 部署多签钱包
        wallet = new MultiSigWallet(owners);
        
        // 给钱包转入一些 ETH
        vm.deal(address(wallet), 10 ether);
    }
    
    function test_Constructor() public {
        // 验证多签持有者
        assertTrue(wallet.isOwner(alice));
        assertTrue(wallet.isOwner(bob));
        assertTrue(wallet.isOwner(charlie));
        assertFalse(wallet.isOwner(dave));
        
        // 验证多签门槛
        assertEq(wallet.threshold(), 2); // 3 * 2/3 = 2
    }
    
    function test_Propose() public {
        bytes memory data = abi.encodeWithSignature("setValue(uint256)", TEST_VALUE);
        
        vm.startPrank(alice);
        uint256 proposalId = wallet.propose(address(target), TEST_ETH, data);
        
        // 验证提案
        (address targetAddr, uint256 value, bytes memory proposalData, bool executed, uint256 confirmations) = wallet.proposals(proposalId);
        assertEq(targetAddr, address(target));
        assertEq(value, TEST_ETH);
        assertEq(proposalData, data);
        assertFalse(executed);
        assertEq(confirmations, 0);
        
        vm.stopPrank();
    }
    
    function test_Confirm() public {
        bytes memory data = abi.encodeWithSignature("setValue(uint256)", TEST_VALUE);
        
        // Alice 提交提案
        vm.startPrank(alice);
        uint256 proposalId = wallet.propose(address(target), TEST_ETH, data);
        vm.stopPrank();
        
        // Bob 确认提案
        vm.startPrank(bob);
        wallet.confirm(proposalId);
        
        // 验证确认状态
        assertTrue(wallet.confirmations(proposalId, bob));
        (,,,,uint256 confirmations) = wallet.proposals(proposalId);
        assertEq(confirmations, 1);
        
        vm.stopPrank();
    }
    
    function test_Execute() public {
        bytes memory data = abi.encodeWithSignature("setValue(uint256)", TEST_VALUE);
        
        // Alice 提交提案
        vm.startPrank(alice);
        uint256 proposalId = wallet.propose(address(target), TEST_ETH, data);
        wallet.confirm(proposalId);
        vm.stopPrank();
        
        // Bob 确认提案
        vm.startPrank(bob);
        wallet.confirm(proposalId);
        vm.stopPrank();
        
        // Dave 执行提案
        vm.startPrank(dave);
        wallet.execute(proposalId);
        
        // 验证执行结果
        assertEq(target.value(), TEST_VALUE);
        assertEq(target.sender(), address(wallet));
        assertEq(address(target).balance, TEST_ETH);
        
        // 验证提案状态
        assertTrue(wallet.isProposalExecuted(proposalId));
        
        vm.stopPrank();
    }
    
} 