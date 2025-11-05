/**
 * Merkle Tree 生成工具
 * 用于生成白名单的 Merkle Root 和 Proof
 * 
 * 使用方法:
 * npm install merkletreejs ethers
 * node scripts/generate_merkle_tree.js
 */

const { MerkleTree } = require('merkletreejs');
const { ethers } = require('ethers');

// ============================================
// 配置区：在这里添加你的白名单地址
// ============================================

const whitelistAddresses = [
    "0x5B38Da6a701c568545dCfcB03FcB875f56beddC4",
    "0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2",
    "0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db",
    "0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB",
    "0x617F2E2fD72FD9D5503197092aC168c91465E7f2",
    "0x17F6AD8Ef982297579C203069C1DbfFE4348c372",
    "0x5c6B0f7Bf3E7ce046039Bd8FABdfD3f9F5021678",
    "0x03C6FcED478cBbC9a4FAB34eF9f40767739D1Ff7",
    // ... 添加更多地址
];

// ============================================
// Merkle Tree 生成逻辑
// ============================================

function generateMerkleTree(addresses) {
    console.log(`\n📋 正在为 ${addresses.length} 个地址生成 Merkle Tree...\n`);

    // 1. 生成叶子节点
    const leaves = addresses.map(addr => {
        // 确保地址格式正确
        const checksummedAddr = ethers.getAddress(addr);
        return ethers.keccak256(ethers.solidityPacked(['address'], [checksummedAddr]));
    });

    console.log("✅ 叶子节点生成完成\n");

    // 2. 构建 Merkle Tree (sortPairs 很重要，要和合约保持一致)
    const tree = new MerkleTree(leaves, ethers.keccak256, { sortPairs: true });

    // 3. 获取 Merkle Root
    const root = tree.getHexRoot();

    console.log("🌳 Merkle Tree 信息:");
    console.log("================================");
    console.log(`Root: ${root}`);
    console.log(`叶子节点数量: ${leaves.length}`);
    console.log(`树的深度: ${Math.ceil(Math.log2(leaves.length))}`);
    console.log("================================\n");

    // 4. 生成每个地址的 proof
    console.log("📜 为每个地址生成 Merkle Proof:\n");
    
    const proofs = {};
    addresses.forEach((addr, index) => {
        const checksummedAddr = ethers.getAddress(addr);
        const leaf = leaves[index];
        const proof = tree.getHexProof(leaf);
        
        proofs[checksummedAddr] = proof;
        
        console.log(`地址 ${index + 1}: ${checksummedAddr}`);
        console.log(`Proof (${proof.length} 个哈希):`);
        proof.forEach((p, i) => {
            console.log(`  [${i}]: ${p}`);
        });
        console.log("");
    });

    return {
        root,
        tree,
        leaves,
        proofs
    };
}

// ============================================
// 验证功能
// ============================================

function verifyProof(address, proof, root) {
    const { ethers } = require('ethers');
    const { MerkleTree } = require('merkletreejs');
    
    const leaf = ethers.keccak256(ethers.solidityPacked(['address'], [address]));
    const isValid = MerkleTree.verify(proof, leaf, root, ethers.keccak256, { sortPairs: true });
    
    return isValid;
}

// ============================================
// 主函数
// ============================================

function main() {
    console.log("\n🎯 Merkle Tree 白名单生成器");
    console.log("================================\n");

    // 生成 Merkle Tree
    const { root, proofs } = generateMerkleTree(whitelistAddresses);

    // 验证示例
    console.log("✅ 验证示例:");
    console.log("================================");
    const testAddr = whitelistAddresses[0];
    const testProof = proofs[testAddr];
    const isValid = verifyProof(testAddr, testProof, root);
    console.log(`地址: ${testAddr}`);
    console.log(`验证结果: ${isValid ? '✅ 通过' : '❌ 失败'}\n`);

    // 生成 JSON 文件供前端使用
    const output = {
        root: root,
        total: whitelistAddresses.length,
        proofs: proofs,
        addresses: whitelistAddresses.map(addr => ethers.getAddress(addr))
    };

    const fs = require('fs');
    fs.writeFileSync(
        './merkle_tree_data.json',
        JSON.stringify(output, null, 2)
    );

    console.log("💾 数据已保存到: ./merkle_tree_data.json");
    
    // 生成 Solidity 测试代码
    console.log("\n📝 Solidity 设置代码:");
    console.log("================================");
    console.log(`// 在合约中设置 Merkle Root`);
    console.log(`whitelist.setMerkleRoot(${root});\n`);

    console.log("📝 用户验证示例 (Solidity):");
    console.log("================================");
    const exampleAddr = whitelistAddresses[0];
    const exampleProof = proofs[exampleAddr];
    console.log(`// 用户 ${exampleAddr} 的验证代码`);
    console.log(`bytes32[] memory proof = new bytes32[](${exampleProof.length});`);
    exampleProof.forEach((p, i) => {
        console.log(`proof[${i}] = ${p};`);
    });
    console.log(`whitelist.claimWithMerkle(proof);`);
    console.log("");

    console.log("\n✅ 完成！");
}

// ============================================
// 运行
// ============================================

if (require.main === module) {
    try {
        main();
    } catch (error) {
        console.error("❌ 错误:", error.message);
        process.exit(1);
    }
}

module.exports = {
    generateMerkleTree,
    verifyProof
};

