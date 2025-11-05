// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Whitelist.sol";

contract WhitelistTest is Test {
    Whitelist public whitelist;
    
    address public owner;
    address public signer;
    address public user1;
    address public user2;
    address public user3;
    
    uint256 public signerPrivateKey;
    uint256 public user1PrivateKey;
    
    // Merkle Tree 相关
    bytes32[] public merkleProofUser1;
    bytes32[] public merkleProofUser2;
    bytes32 public merkleRoot;
    
    function setUp() public {
        owner = address(this);
        
        // 创建测试账户
        signerPrivateKey = 0xA11CE;
        signer = vm.addr(signerPrivateKey);
        
        user1PrivateKey = 0xB0B;
        user1 = vm.addr(user1PrivateKey);
        
        user2 = makeAddr("user2");
        user3 = makeAddr("user3");
        
        // 部署合约
        whitelist = new Whitelist();
        
        // 设置签名者
        whitelist.setSigner(signer);
        
        // 为测试准备 Merkle Tree
        // 使用简单的两层树结构: user1 和 user2 在白名单中
        // Leaf: keccak256(abi.encodePacked(address))
        bytes32 leaf1 = keccak256(abi.encodePacked(user1));
        bytes32 leaf2 = keccak256(abi.encodePacked(user2));
        
        // 对叶子节点排序（标准做法）
        bytes32 left;
        bytes32 right;
        if (leaf1 < leaf2) {
            left = leaf1;
            right = leaf2;
        } else {
            left = leaf2;
            right = leaf1;
        }
        
        merkleRoot = keccak256(abi.encodePacked(left, right));
        
        // user1 的证明
        merkleProofUser1.push(leaf2);
        
        // user2 的证明
        merkleProofUser2.push(leaf1);
        
        whitelist.setMerkleRoot(merkleRoot);
    }
    
    // =================================
    // 测试方法1: Mapping 白名单
    // =================================
    
    function testMappingWhitelist_AddSingle() public {
        assertFalse(whitelist.isInMappingWhitelist(user1));
        
        whitelist.addToMappingWhitelist(user1);
        
        assertTrue(whitelist.isInMappingWhitelist(user1));
        assertFalse(whitelist.isInMappingWhitelist(user2));
    }
    
    function testMappingWhitelist_AddBatch() public {
        address[] memory accounts = new address[](3);
        accounts[0] = user1;
        accounts[1] = user2;
        accounts[2] = user3;
        
        whitelist.addBatchToMappingWhitelist(accounts);
        
        assertTrue(whitelist.isInMappingWhitelist(user1));
        assertTrue(whitelist.isInMappingWhitelist(user2));
        assertTrue(whitelist.isInMappingWhitelist(user3));
    }
    
    function testMappingWhitelist_Remove() public {
        whitelist.addToMappingWhitelist(user1);
        assertTrue(whitelist.isInMappingWhitelist(user1));
        
        whitelist.removeFromMappingWhitelist(user1);
        assertFalse(whitelist.isInMappingWhitelist(user1));
    }
    
    function testMappingWhitelist_RevertOnZeroAddress() public {
        vm.expectRevert("Invalid address");
        whitelist.addToMappingWhitelist(address(0));
    }
    
    function testMappingWhitelist_RevertOnDuplicateAdd() public {
        whitelist.addToMappingWhitelist(user1);
        
        vm.expectRevert("Already whitelisted");
        whitelist.addToMappingWhitelist(user1);
    }
    
    // =================================
    // 测试方法2: EIP-712 签名验证
    // =================================
    
    function testEIP712Whitelist_ValidSignature() public {
        uint256 nonce = whitelist.nonces(user1);
        uint256 expiry = block.timestamp + 1 hours;
        
        // 创建签名
        Whitelist.WhitelistRequest memory request = Whitelist.WhitelistRequest({
            user: user1,
            nonce: nonce,
            expiry: expiry
        });
        
        bytes32 digest = whitelist.hashWhitelistRequest(request);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(signerPrivateKey, digest);
        bytes memory signature = abi.encodePacked(r, s, v);
        
        // 验证签名
        bool isValid = whitelist.verifyEIP712Whitelist(user1, nonce, expiry, signature);
        assertTrue(isValid);
    }
    
    function testEIP712Whitelist_Claim() public {
        uint256 nonce = whitelist.nonces(user1);
        uint256 expiry = block.timestamp + 1 hours;
        
        // 创建签名
        Whitelist.WhitelistRequest memory request = Whitelist.WhitelistRequest({
            user: user1,
            nonce: nonce,
            expiry: expiry
        });
        
        bytes32 digest = whitelist.hashWhitelistRequest(request);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(signerPrivateKey, digest);
        bytes memory signature = abi.encodePacked(r, s, v);
        
        // user1 使用签名领取
        vm.prank(user1);
        whitelist.claimWithEIP712(nonce, expiry, signature);
        
        // nonce 应该增加
        assertEq(whitelist.nonces(user1), nonce + 1);
    }
    
    function testEIP712Whitelist_RevertOnExpiredSignature() public {
        uint256 nonce = whitelist.nonces(user1);
        uint256 expiry = block.timestamp - 1; // 已过期
        
        Whitelist.WhitelistRequest memory request = Whitelist.WhitelistRequest({
            user: user1,
            nonce: nonce,
            expiry: expiry
        });
        
        bytes32 digest = whitelist.hashWhitelistRequest(request);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(signerPrivateKey, digest);
        bytes memory signature = abi.encodePacked(r, s, v);
        
        vm.prank(user1);
        vm.expectRevert("Invalid signature or not whitelisted");
        whitelist.claimWithEIP712(nonce, expiry, signature);
    }
    
    function testEIP712Whitelist_RevertOnReplay() public {
        uint256 nonce = whitelist.nonces(user1);
        uint256 expiry = block.timestamp + 1 hours;
        
        Whitelist.WhitelistRequest memory request = Whitelist.WhitelistRequest({
            user: user1,
            nonce: nonce,
            expiry: expiry
        });
        
        bytes32 digest = whitelist.hashWhitelistRequest(request);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(signerPrivateKey, digest);
        bytes memory signature = abi.encodePacked(r, s, v);
        
        // 第一次领取成功
        vm.prank(user1);
        whitelist.claimWithEIP712(nonce, expiry, signature);
        
        // 尝试重放攻击应该失败
        vm.prank(user1);
        vm.expectRevert("Invalid signature or not whitelisted");
        whitelist.claimWithEIP712(nonce, expiry, signature);
    }
    
    function testEIP712Whitelist_SetSigner() public {
        address newSigner = makeAddr("newSigner");
        
        whitelist.setSigner(newSigner);
        
        assertEq(whitelist.signer(), newSigner);
    }
    
    // =================================
    // 测试方法3: Merkle Tree 验证
    // =================================
    
    function testMerkleTree_ValidProof() public {
        bool isValid = whitelist.verifyMerkleProof(user1, merkleProofUser1);
        assertTrue(isValid);
        
        isValid = whitelist.verifyMerkleProof(user2, merkleProofUser2);
        assertTrue(isValid);
    }
    
    function testMerkleTree_InvalidProof() public {
        // user3 不在白名单中
        bytes32[] memory emptyProof = new bytes32[](0);
        bool isValid = whitelist.verifyMerkleProof(user3, emptyProof);
        assertFalse(isValid);
    }
    
    function testMerkleTree_Claim() public {
        assertFalse(whitelist.hasClaimed(user1));
        
        vm.prank(user1);
        whitelist.claimWithMerkle(merkleProofUser1);
        
        assertTrue(whitelist.hasClaimed(user1));
    }
    
    function testMerkleTree_RevertOnDoubleClaim() public {
        vm.prank(user1);
        whitelist.claimWithMerkle(merkleProofUser1);
        
        vm.prank(user1);
        vm.expectRevert("Already claimed");
        whitelist.claimWithMerkle(merkleProofUser1);
    }
    
    function testMerkleTree_RevertOnInvalidProof() public {
        bytes32[] memory wrongProof = new bytes32[](1);
        wrongProof[0] = bytes32(uint256(123));
        
        vm.prank(user1);
        vm.expectRevert("Invalid proof or not whitelisted");
        whitelist.claimWithMerkle(wrongProof);
    }
    
    function testMerkleTree_SetMerkleRoot() public {
        bytes32 newRoot = keccak256("new root");
        
        whitelist.setMerkleRoot(newRoot);
        
        assertEq(whitelist.merkleRoot(), newRoot);
    }
    
    function testMerkleTree_ResetClaimed() public {
        vm.prank(user1);
        whitelist.claimWithMerkle(merkleProofUser1);
        assertTrue(whitelist.hasClaimed(user1));
        
        whitelist.resetClaimed(user1);
        assertFalse(whitelist.hasClaimed(user1));
    }
}

