# 部署 L1 对应的 L2 对应 代币

#./bridgeL1TokenToL2.sh $SEPOLIA_RPC_URL $PRIVATE_KEY
source .env

# approve first 
# 批准 L1 桥合约转移你的代币
# https://sepolia.etherscan.io/tx/0x84641e351375c275c1eaab01de3a0ccbf25272ba1392d8d3412e6f6e357d024d
cast send 0x37FcA00F832dA2E0D91EcC532E00f977Cd163f14 \
  "approve(address,uint256)" \
  "0xfd0bf71f60660e2f608ed56e1659c450eb113120" \
  "1000000000000000000000" \
  --rpc-url $SEPOLIA_RPC_URL \
  --private-key $PRIVATE_KEY

# OP : 	0xFBb0621E0B23b5478B630BD55a5f21f67730B0F1
# https://docs.optimism.io/op-mainnet/network-information/op-addresses
# Base: 0xfd0bf71f60660e2f608ed56e1659c450eb113120 
# https://docs.base.org/base-chain/network-information/base-contracts

cast send 0xfd0bf71f60660e2f608ed56e1659c450eb113120 \
  "bridgeERC20(address,address,uint256,uint32,bytes)" \
  "0x37FcA00F832dA2E0D91EcC532E00f977Cd163f14" \
  "0x11421792198B8AC0b8BdF9Bc13dC93b91d78F4Fe" \
  "10000000000000000" \
  "1000000" \
  "0x" \
  --rpc-url $SEPOLIA_RPC_URL \
  --private-key $PRIVATE_KEY

