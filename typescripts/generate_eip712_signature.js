/**
 * EIP-712 签名生成工具
 * 用于为白名单用户生成签名
 * 
 * 使用方法:
 * npm install ethers
 * node scripts/generate_eip712_signature.js
 */

const { ethers } = require('ethers');

// ============================================
// 配置区
// ============================================

// 签名者私钥（这是测试私钥，不要在生产环境使用！）
// 在生产环境中，应该使用 HSM 或者安全的密钥管理服务
const SIGNER_PRIVATE_KEY = "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80"; // Hardhat 测试账户 #0

// 合约地址（部署后填入）
const CONTRACT_ADDRESS = "0x5FbDB2315678afecb367f032d93F642f64180aa3"; // 替换为你的合约地址

// 链 ID
const CHAIN_ID = 31337; // 本地测试网，生产环境需要改为 1 (主网) 或 11155111 (Sepolia)

// 要签名的用户地址列表
const USERS_TO_SIGN = [
    "0x70997970C51812dc3A010C7d01b50e0d17dc79C8",
    "0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC",
    "0x90F79bf6EB2c4f870365E785982E1f101E93b906",
];

// ============================================
// EIP-712 Domain 和 Types
// ============================================

const domain = {
    name: 'Whitelist',
    version: '1.0.0',
    chainId: CHAIN_ID,
    verifyingContract: CONTRACT_ADDRESS
};

const types = {
    WhitelistRequest: [
        { name: 'user', type: 'address' },
        { name: 'nonce', type: 'uint256' },
        { name: 'expiry', type: 'uint256' }
    ]
};

// ============================================
// 签名生成函数
// ============================================

async function generateSignature(userAddress, nonce = 0, expiryHours = 24) {
    // 创建签名者
    const signer = new ethers.Wallet(SIGNER_PRIVATE_KEY);
    
    // 计算过期时间
    const currentTimestamp = Math.floor(Date.now() / 1000);
    const expiry = currentTimestamp + (expiryHours * 3600);
    
    // 准备数据
    const value = {
        user: userAddress,
        nonce: nonce,
        expiry: expiry
    };
    
    // 签名
    const signature = await signer.signTypedData(domain, types, value);
    
    return {
        user: userAddress,
        nonce: nonce,
        expiry: expiry,
        expiryDate: new Date(expiry * 1000).toISOString(),
        signature: signature,
        signerAddress: signer.address
    };
}

// ============================================
// 验证签名函数
// ============================================

function verifySignature(signatureData) {
    const { user, nonce, expiry, signature } = signatureData;
    
    // 重新构建消息
    const value = {
        user: user,
        nonce: nonce,
        expiry: expiry
    };
    
    // 恢复签名者地址
    const recovered = ethers.verifyTypedData(domain, types, value, signature);
    
    return recovered.toLowerCase();
}

// ============================================
// 主函数
// ============================================

async function main() {
    console.log("\n🔐 EIP-712 签名生成器");
    console.log("================================\n");
    
    console.log("⚙️  配置信息:");
    console.log(`合约地址: ${CONTRACT_ADDRESS}`);
    console.log(`链 ID: ${CHAIN_ID}`);
    
    const signer = new ethers.Wallet(SIGNER_PRIVATE_KEY);
    console.log(`签名者地址: ${signer.address}\n`);
    
    // 为每个用户生成签名
    const signatures = [];
    
    console.log("📝 生成签名:\n");
    
    for (let i = 0; i < USERS_TO_SIGN.length; i++) {
        const userAddress = USERS_TO_SIGN[i];
        const signatureData = await generateSignature(userAddress, 0, 24);
        signatures.push(signatureData);
        
        console.log(`用户 ${i + 1}: ${userAddress}`);
        console.log(`  Nonce: ${signatureData.nonce}`);
        console.log(`  过期时间: ${signatureData.expiryDate}`);
        console.log(`  签名: ${signatureData.signature}`);
        
        // 验证签名
        const recoveredSigner = verifySignature(signatureData);
        const isValid = recoveredSigner.toLowerCase() === signer.address.toLowerCase();
        console.log(`  验证: ${isValid ? '✅ 通过' : '❌ 失败'} (恢复的地址: ${recoveredSigner})\n`);
    }
    
    // 保存到 JSON 文件
    const output = {
        domain: domain,
        types: types,
        signatures: signatures,
        generatedAt: new Date().toISOString()
    };
    
    const fs = require('fs');
    fs.writeFileSync(
        './eip712_signatures.json',
        JSON.stringify(output, null, 2)
    );
    
    console.log("💾 签名数据已保存到: ./eip712_signatures.json\n");
    
    // 生成前端调用示例
    console.log("📝 前端使用示例 (JavaScript/ethers.js):");
    console.log("================================");
    console.log(`
const signature = "${signatures[0].signature}";
const nonce = ${signatures[0].nonce};
const expiry = ${signatures[0].expiry};

// 调用合约
const tx = await whitelistContract.claimWithEIP712(
    nonce,
    expiry,
    signature
);

await tx.wait();
console.log("✅ 领取成功！");
`);
    
    // 生成 Solidity 测试代码
    console.log("\n📝 Solidity 测试代码:");
    console.log("================================");
    console.log(`
address user = ${signatures[0].user};
uint256 nonce = ${signatures[0].nonce};
uint256 expiry = ${signatures[0].expiry};
bytes memory signature = hex"${signatures[0].signature.slice(2)}";

vm.prank(user);
whitelist.claimWithEIP712(nonce, expiry, signature);
`);
    
    // 生成 cast 命令示例
    console.log("\n📝 使用 cast 调用合约:");
    console.log("================================");
    console.log(`
cast send ${CONTRACT_ADDRESS} \\
  "claimWithEIP712(uint256,uint256,bytes)" \\
  ${signatures[0].nonce} \\
  ${signatures[0].expiry} \\
  "${signatures[0].signature}" \\
  --rpc-url http://localhost:8545 \\
  --private-key <USER_PRIVATE_KEY>
`);
    
    console.log("\n✅ 完成！");
}

// ============================================
// 辅助函数：为后端 API 使用
// ============================================

/**
 * 后端 API 可以调用这个函数为用户生成签名
 * @param {string} userAddress - 用户地址
 * @param {number} currentNonce - 用户当前的 nonce（从链上查询）
 * @param {number} expiryHours - 签名有效期（小时）
 * @returns {Promise<object>} 签名数据
 */
async function generateSignatureForAPI(userAddress, currentNonce, expiryHours = 1) {
    return await generateSignature(userAddress, currentNonce, expiryHours);
}

/**
 * Express.js API 端点示例
 */
function expressAPIExample() {
    console.log(`
// Express.js 后端示例

const express = require('express');
const app = express();
app.use(express.json());

// 获取签名的 API 端点
app.post('/api/whitelist/signature', async (req, res) => {
    try {
        const { userAddress } = req.body;
        
        // 验证用户是否在白名单中（从数据库查询）
        const isWhitelisted = await checkIfWhitelisted(userAddress);
        if (!isWhitelisted) {
            return res.status(403).json({ error: 'Not whitelisted' });
        }
        
        // 从链上查询用户的当前 nonce
        const currentNonce = await contract.nonces(userAddress);
        
        // 生成签名
        const signatureData = await generateSignatureForAPI(
            userAddress,
            currentNonce,
            1 // 1小时有效期
        );
        
        res.json(signatureData);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.listen(3000, () => {
    console.log('API server running on port 3000');
});
`);
}

// ============================================
// 运行
// ============================================

if (require.main === module) {
    main().catch(error => {
        console.error("❌ 错误:", error);
        process.exit(1);
    });
}

module.exports = {
    generateSignature,
    verifySignature,
    generateSignatureForAPI,
    domain,
    types
};




