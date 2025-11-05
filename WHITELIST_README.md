# 白名单合约实现指南

本项目实现了三种常用的智能合约白名单验证方法，每种方法都有其特点和适用场景。

## 📋 目录

1. [快速开始](#快速开始)
2. [方法1: Mapping 白名单](#方法1-mapping-白名单)
3. [方法2: EIP-712 签名验证](#方法2-eip-712-签名验证)
4. [方法3: Merkle Tree 验证](#方法3-merkle-tree-验证)
5. [部署和测试](#部署和测试)
6. [实际案例对比](#实际案例对比)
7. [Gas 成本对比](#gas-成本对比)
8. [选择决策树](#选择决策树)
9. [安全建议](#安全建议)
10. [参考资源](#参考资源)

---

## 🚀 快速开始

### 1. 安装依赖

```bash
# 安装 Foundry 依赖
forge install

# 安装 JavaScript 工具依赖
npm install
```

### 2. 编译合约

```bash
forge build
```

### 3. 运行测试

```bash
forge test --match-contract WhitelistTest -vv
```

### 4. 部署合约

```bash
# 启动本地测试网
anvil

# 在新终端部署合约
forge script script/Whitelist.s.sol:WhitelistScript --rpc-url http://localhost:8545 --broadcast
```

---

## 方法1: Mapping 白名单

### 💡 原理
使用 `mapping(address => bool)` 直接在链上存储白名单地址。

### ✅ 优点
- **实现简单**: 最直观易懂的实现方式
- **查询快速**: O(1) 时间复杂度
- **灵活管理**: 可以随时添加或移除地址

### ❌ 缺点
- **Gas 成本高**: 每添加一个地址需要一次链上交易
- **不适合大规模**: 成千上万地址时成本极高
- **需要管理权限**: 需要可信的管理员

### 🔧 使用方法

**最适合**: 小规模白名单 

#### 添加地址到白名单

```bash
# 添加单个地址
cast send <WHITELIST_CONTRACT> \
  "addToMappingWhitelist(address)" \
  <USER_ADDRESS> \
  --rpc-url http://localhost:8545 \
  --private-key <OWNER_PRIVATE_KEY>

```


### 📊 适用场景
- 小规模白名单 
- 需要动态管理白名单
- VIP 用户、团队成员等固定名单
- 实时更新要求高的场景

---

## 方法2: EIP-712 签名验证


### 💡 原理
使用 EIP-712 标准的链下签名，用户在链上提交签名进行验证。签名由项目方的私钥签发，包含用户地址、nonce 和过期时间。

### ✅ 优点
- **零存储成本**: 不需要在链上存储白名单
- **灵活分发**: 可以通过网站、邮件等方式分发签名
- **支持过期**: 可设置签名有效期
- **防重放攻击**: 通过 nonce 机制保护

### ❌ 缺点
- **需要后端服务**: 需要服务器生成和分发签名
- **私钥管理**: 签名者私钥安全性至关重要
- **无法撤销**: 已签发的有效签名无法撤回（除非过期）

### 🔧 使用方法

#### 步骤 1: 生成签名（后端/脚本）

```bash
# 编辑 test_scripts/generate_eip712_signature.js 配置
# 1. 设置 SIGNER_PRIVATE_KEY（签名者私钥）
# 2. 设置 CONTRACT_ADDRESS（合约地址）
# 3. 添加 USERS_TO_SIGN（要签名的用户地址）

# 运行脚本生成签名
npm run eip712
```

这会生成 `eip712_signatures.json` 文件，包含所有签名数据。

#### 步骤 2: 链下生成签名（TypeScript/ethers.js）

```typescript
import { ethers } from 'ethers';

// 1. 定义 EIP-712 Domain
const domain = {
  name: 'Whitelist',
  version: '1.0.0',
  chainId: 1,
  verifyingContract: whitelistContractAddress
};

// 2. 定义类型
const types = {
  WhitelistRequest: [
    { name: 'user', type: 'address' },
    { name: 'nonce', type: 'uint256' },
    { name: 'expiry', type: 'uint256' }
  ]
};

// 3. 准备数据
const value = {
  user: userAddress,
  nonce: 0,
  expiry: Math.floor(Date.now() / 1000) + 3600 // 1小时后过期
};

// 4. 签名
const signer = new ethers.Wallet(privateKey);
const signature = await signer.signTypedData(domain, types, value);
```

#### 步骤 3: 用户使用签名（前端）

```javascript
// 前端 JavaScript 代码
const { ethers } = require('ethers');

// 从后端 API 或 JSON 文件获取签名数据
const signatureData = {
    nonce: 0,
    expiry: 1234567890,
    signature: "0x..."
};

// 连接钱包
const provider = new ethers.BrowserProvider(window.ethereum);
const signer = await provider.getSigner();

// 调用合约
const contract = new ethers.Contract(
    contractAddress,
    contractABI,
    signer
);

const tx = await contract.claimWithEIP712(
    signatureData.nonce,
    signatureData.expiry,
    signatureData.signature
);

await tx.wait();
console.log("✅ 领取成功！");
```

#### 步骤 4: 链上验证签名（Solidity）

```solidity
// 用户使用签名领取
whitelist.claimWithEIP712(nonce, expiry, signature);

// 或者只验证不执行操作
bool isValid = whitelist.verifyEIP712Whitelist(
    userAddress,
    nonce,
    expiry,
    signature
);
```

#### 后端 API 示例

```javascript
// Express.js 后端
app.post('/api/whitelist/signature', async (req, res) => {
    const { userAddress } = req.body;
    
    // 检查白名单
    if (!isUserInWhitelist(userAddress)) {
        return res.status(403).json({ error: 'Not whitelisted' });
    }
    
    // 查询链上 nonce
    const nonce = await contract.nonces(userAddress);
    
    // 生成签名
    const signature = await generateSignature(userAddress, nonce);
    
    res.json(signature);
});
```

#### 管理签名者

```bash
# 更改签名者地址（只有 owner 可以调用）
cast send <WHITELIST_CONTRACT> \
  "setSigner(address)" \
  <NEW_SIGNER_ADDRESS> \
  --rpc-url http://localhost:8545 \
  --private-key <OWNER_PRIVATE_KEY>
```

### 📊 适用场景
- 较大规模白名单 
- NFT 白名单铸造
- 空投领取
- 需要时间限制的白名单
- 有后端基础设施的项目

---

## 方法3: Merkle Tree 验证

### 💡 原理
将所有白名单地址构建成 Merkle Tree，只在链上存储根哈希（32 bytes）。用户提供 Merkle Proof 来证明自己在白名单中。

### ✅ 优点
- **极低存储成本**: 无论多少地址，只存储一个根哈希
- **Gas 高效**: 验证成本为 O(log n)
- **适合大规模**: 可支持百万级地址
- **不可篡改**: 一旦设置很难修改

### ❌ 缺点
- **不易更新**: 修改白名单需要重新计算整棵树
- **需要链下数据**: 用户需要获取自己的 Merkle Proof
- **复杂度较高**: 需要理解 Merkle Tree 原理

### 🔧 使用方法

**最适合**: 超大规模白名单（> 100,000 个地址）

#### 步骤 1: 生成 Merkle Tree

```bash
# 编辑 test_scripts/generate_merkle_tree.js
# 在 whitelistAddresses 数组中添加所有白名单地址

# 运行脚本生成 Merkle Root
npm run merkle
```

这会生成：
- `merkle_tree_data.json` - 包含 root 和所有用户的 proof
- 控制台输出 Merkle Root

#### 步骤 2: 链下生成 Merkle Tree（JavaScript）

```javascript
const { MerkleTree } = require('merkletreejs');
const { keccak256 } = require('ethers');

// 1. 准备白名单地址
const addresses = [
  '0x1234...',
  '0x5678...',
  // ... 更多地址
];

// 2. 生成叶子节点
const leaves = addresses.map(addr => 
  keccak256(ethers.solidityPacked(['address'], [addr]))
);

// 3. 构建 Merkle Tree
const tree = new MerkleTree(leaves, keccak256, { sortPairs: true });

// 4. 获取根哈希
const root = tree.getHexRoot();

// 5. 获取某个地址的证明
const leaf = keccak256(ethers.solidityPacked(['address'], [userAddress]));
const proof = tree.getHexProof(leaf);
```

#### 步骤 3: 设置 Merkle Root（管理员）

```bash
# 使用生成的 root
cast send <WHITELIST_CONTRACT> \
  "setMerkleRoot(bytes32)" \
  <MERKLE_ROOT> \
  --rpc-url http://localhost:8545 \
  --private-key <OWNER_PRIVATE_KEY>
```

#### 步骤 4: 链上设置和验证（Solidity）

```solidity
// 管理员设置 Merkle Root
whitelist.setMerkleRoot(merkleRoot);

// 用户验证（只验证）
bool isValid = whitelist.verifyMerkleProof(userAddress, proof);

// 用户领取（验证 + 执行）
whitelist.claimWithMerkle(proof);
```

#### 步骤 5: 用户验证和领取（前端）

```javascript
// 前端代码
const { ethers } = require('ethers');
const merkleData = require('./merkle_tree_data.json');

// 获取当前用户地址
const userAddress = await signer.getAddress();

// 从 JSON 文件获取该用户的 proof
const proof = merkleData.proofs[userAddress];

if (!proof) {
    console.log("❌ 用户不在白名单中");
    return;
}

// 调用合约
const contract = new ethers.Contract(
    contractAddress,
    contractABI,
    signer
);

const tx = await contract.claimWithMerkle(proof);
await tx.wait();
console.log("✅ 领取成功！");
```

#### Merkle Proof 示例

```javascript
// 用户从前端获取自己的 proof
const proof = [
  "0x1234...",
  "0x5678...",
  "0xabcd..."
];

// 提交到合约
await whitelist.claimWithMerkle(proof);
```

#### 提供 API 让用户查询 Proof

```javascript
// 后端 API
app.get('/api/merkle/proof/:address', (req, res) => {
    const address = req.params.address;
    const merkleData = require('./merkle_tree_data.json');
    
    const proof = merkleData.proofs[address];
    
    if (!proof) {
        return res.status(404).json({ error: 'Not in whitelist' });
    }
    
    res.json({ proof });
});
```

### 📊 适用场景
- 超大规模白名单（> 100,000 个地址）
- 不常变化的白名单
- 注重 Gas 优化的项目
- 空投快照
- 公平发行

---

## 部署和测试

### 📦 安装依赖

```bash
forge install
```

### 🚀 部署合约

```bash
# 部署到本地测试网
forge script script/Whitelist.s.sol:WhitelistScript --rpc-url localhost --broadcast

# 部署到测试网（需要配置 .env）
forge script script/Whitelist.s.sol:WhitelistScript --rpc-url sepolia --broadcast --verify
```

### 🧪 运行测试

```bash
# 运行所有测试
forge test --match-contract WhitelistTest -vv

# 测试特定方法
forge test --match-test testMappingWhitelist -vv
forge test --match-test testEIP712Whitelist -vv
forge test --match-test testMerkleTree -vv

# 查看 Gas 报告
forge test --gas-report
```


## Gas 成本对比

| 方法 | 设置成本 | 单次验证成本 | 适用规模 | 灵活性 |
|------|---------|------------|---------|-------|
| **Mapping** | ~50,000 gas/地址 | ~2,100 gas | 小型 (<1K) | ⭐⭐⭐⭐⭐ |
| **EIP-712** | ~0 gas | ~3,000 gas | 大型 (>10K) | ⭐⭐⭐⭐ |
| **Merkle Tree** | ~45,000 gas (一次性) | ~5,000-8,000 gas | 超大型 (>100K) | ⭐⭐ |


## 🎯 选择决策树

```
开始
  │
  ├─ 地址数量 < 1000?
  │   ├─ 是 → 需要频繁更新?
  │   │   ├─ 是 → 使用 Mapping ⭐⭐⭐⭐⭐
  │   │   └─ 否 → 使用 EIP-712 ⭐⭐⭐⭐
  │   └─ 否 ↓
  │
  ├─ 地址数量 < 10,000?
  │   ├─ 是 → 有后端服务?
  │   │   ├─ 是 → 使用 EIP-712 ⭐⭐⭐⭐⭐
  │   │   └─ 否 → 使用 Merkle Tree ⭐⭐⭐⭐
  │   └─ 否 ↓
  │
  └─ 地址数量 > 10,000
      └─ 使用 Merkle Tree ⭐⭐⭐⭐⭐
```

---

## 🔐 安全建议

### Mapping 白名单
- ✅ **权限控制**: 使用 `Ownable` 或多签控制管理权限
- ✅ **事件日志**: 记录所有添加/移除事件
- ✅ **时间锁**: 考虑使用时间锁延迟重要更改
- ✅ **批量操作**: 注意 Gas 限制，大批量操作考虑分批执行

### EIP-712 签名
- ✅ **私钥管理**: 
  - 生产环境使用 HSM（硬件安全模块）
  - 或使用多签钱包作为签名者
- ✅ **签名过期时间**:
  - 建议设置较短的过期时间（1-24 小时）
  - 防止签名泄露后被滥用
- ✅ **Nonce 机制**:
  - 确保每个签名只能使用一次
  - 防止重放攻击
- ✅ **后端 API 安全**:
  - 实现速率限制
  - 记录所有签名生成日志
  - 监控异常请求
- ✅ **签名验证**: 始终检查签名过期时间
- ✅ **黑名单机制**: 考虑实现签名黑名单机制

### Merkle Tree
- ✅ **备份数据**: 
  - 务必保存完整的 Merkle Tree 数据（用于用户查询）
  - 推荐上传到 IPFS 或 Arweave
- ✅ **Root 更新**: 
  - 更新 Root 前要充分测试
  - 考虑使用时间锁延迟更新
- ✅ **防重复领取**:
  - 使用 `hasClaimed` mapping 记录
  - 确保每个地址只能领取一次
- ✅ **API 服务**: 提供公开的 API 让用户获取 proof
- ✅ **数据存储**: 考虑使用 IPFS 存储白名单数据

---
 
## 📚 参考资源

- [EIP-712 标准](https://eips.ethereum.org/EIPS/eip-712)
- [OpenZeppelin MerkleProof](https://docs.openzeppelin.com/contracts/4.x/api/utils#MerkleProof)
- [Merkle Tree 可视化工具](https://lab.miguelmota.com/merkletreejs/example/)
- [测试用例](./test/Whitelist.t.sol)
- [合约源码](./src/Whitelist.sol)

---

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

## 📄 许可证

MIT
