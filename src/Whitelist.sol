// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

/**
 * @title Whitelist
 * @notice 实现三种白名单验证方法的合约
 * @dev 方法1: mapping 存储  方法2: EIP-712 签名验证  方法3: Merkle Tree 验证
 */
contract Whitelist is Ownable, EIP712 {
    using ECDSA for bytes32;

    // =================================
    // 方法1: Mapping 白名单
    // =================================
    
    mapping(address => bool) public mappingWhitelist;
    
    event MappingWhitelistAdded(address indexed account);
    event MappingWhitelistRemoved(address indexed account);

    /**
     * @notice 添加地址到 mapping 白名单
     * @param account 要添加的地址
     */
    function addToMappingWhitelist(address account) external onlyOwner {
        require(account != address(0), "Invalid address");
        require(!mappingWhitelist[account], "Already whitelisted");
        mappingWhitelist[account] = true;
        emit MappingWhitelistAdded(account);
    }

    /**
     * @notice 批量添加地址到 mapping 白名单
     * @param accounts 要添加的地址数组
     */
    function addBatchToMappingWhitelist(address[] calldata accounts) external onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            if (accounts[i] != address(0) && !mappingWhitelist[accounts[i]]) {
                mappingWhitelist[accounts[i]] = true;
                emit MappingWhitelistAdded(accounts[i]);
            }
        }
    }

    /**
     * @notice 从 mapping 白名单移除地址
     * @param account 要移除的地址
     */
    function removeFromMappingWhitelist(address account) external onlyOwner {
        require(mappingWhitelist[account], "Not in whitelist");
        mappingWhitelist[account] = false;
        emit MappingWhitelistRemoved(account);
    }

    /**
     * @notice 检查地址是否在 mapping 白名单中
     * @param account 要检查的地址
     * @return 是否在白名单中
     */
    function isInMappingWhitelist(address account) public view returns (bool) {
        return mappingWhitelist[account];
    }

    // =================================
    // 方法2: EIP-712 签名验证白名单
    // =================================

    // 签名者地址（通常是项目方的钱包地址）
    address public signer;

    // 用户请求结构体
    struct WhitelistRequest {
        address user;
        uint256 nonce;
        uint256 expiry;
    }

    bytes32 public constant WHITELIST_TYPEHASH = 
        keccak256("WhitelistRequest(address user,uint256 nonce,uint256 expiry)");

    // 用于防止重放攻击的 nonce
    mapping(address => uint256) public nonces;

    event SignerUpdated(address indexed newSigner);

    constructor() EIP712("Whitelist", "1.0.0") Ownable(msg.sender) {
        signer = msg.sender;
    }

    /**
     * @notice 设置签名者地址
     * @param newSigner 新的签名者地址
     */
    function setSigner(address newSigner) external onlyOwner {
        require(newSigner != address(0), "Invalid signer");
        signer = newSigner;
        emit SignerUpdated(newSigner);
    }

    /**
     * @notice 生成 EIP-712 哈希
     * @param request 白名单请求结构
     * @return EIP-712 哈希值
     */
    function hashWhitelistRequest(WhitelistRequest memory request) public view returns (bytes32) {
        return _hashTypedDataV4(
            keccak256(
                abi.encode(
                    WHITELIST_TYPEHASH,
                    request.user,
                    request.nonce,
                    request.expiry
                )
            )
        );
    }

    /**
     * @notice 验证 EIP-712 签名白名单
     * @param user 用户地址
     * @param nonce 防重放 nonce
     * @param expiry 签名过期时间
     * @param signature 签名数据
     * @return 是否通过验证
     */
    function verifyEIP712Whitelist(
        address user,
        uint256 nonce,
        uint256 expiry,
        bytes memory signature
    ) public view returns (bool) {
        // 检查签名是否过期
        if (block.timestamp > expiry) {
            return false;
        }

        // 检查 nonce 是否正确
        if (nonce != nonces[user]) {
            return false;
        }

        // 验证签名
        WhitelistRequest memory request = WhitelistRequest({
            user: user,
            nonce: nonce,
            expiry: expiry
        });

        bytes32 digest = hashWhitelistRequest(request);
        address recovered = digest.recover(signature);
        
        return recovered == signer;
    }

    /**
     * @notice 使用 EIP-712 签名进行白名单验证的示例函数
     * @param nonce 防重放 nonce
     * @param expiry 签名过期时间
     * @param signature 签名数据
     */
    function claimWithEIP712(
        uint256 nonce,
        uint256 expiry,
        bytes memory signature
    ) external {
        require(
            verifyEIP712Whitelist(msg.sender, nonce, expiry, signature),
            "Invalid signature or not whitelisted"
        );
        
        // 使用 nonce 后递增，防止重放攻击
        nonces[msg.sender]++;
        
        // 这里执行白名单用户的操作
        // 例如：铸造 NFT、领取奖励等
    }

    // =================================
    // 方法3: Merkle Tree 白名单
    // =================================

    bytes32 public merkleRoot;
    
    // 记录已经使用过的地址，防止重复领取
    mapping(address => bool) public hasClaimed;

    event MerkleRootUpdated(bytes32 indexed newRoot);
    event Claimed(address indexed account);

    /**
     * @notice 设置 Merkle Root
     * @param newRoot 新的 Merkle Root
     */
    function setMerkleRoot(bytes32 newRoot) external onlyOwner {
        merkleRoot = newRoot;
        emit MerkleRootUpdated(newRoot);
    }

    /**
     * @notice 验证 Merkle Proof
     * @param account 要验证的地址
     * @param proof Merkle 证明数组
     * @return 是否通过验证
     */
    function verifyMerkleProof(
        address account,
        bytes32[] calldata proof
    ) public view returns (bool) {
        bytes32 leaf = keccak256(abi.encodePacked(account));
        return MerkleProof.verify(proof, merkleRoot, leaf);
    }

    /**
     * @notice 使用 Merkle Proof 进行白名单验证的示例函数
     * @param proof Merkle 证明数组
     */
    function claimWithMerkle(bytes32[] calldata proof) external {
        require(!hasClaimed[msg.sender], "Already claimed");
        require(
            verifyMerkleProof(msg.sender, proof),
            "Invalid proof or not whitelisted"
        );
        
        hasClaimed[msg.sender] = true;
        emit Claimed(msg.sender);
        
        // 这里执行白名单用户的操作
        // 例如：铸造 NFT、领取奖励等
    }

    /**
     * @notice 重置某个地址的领取状态（仅供管理员使用）
     * @param account 要重置的地址
     */
    function resetClaimed(address account) external onlyOwner {
        hasClaimed[account] = false;
    }

    // =================================
    // 通用查询函数
    // =================================

    /**
     * @notice 获取用户的当前 nonce
     * @param user 用户地址
     * @return 当前 nonce 值
     */
    function getNonce(address user) external view returns (uint256) {
        return nonces[user];
    }
}

