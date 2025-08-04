# 部署 L1 对应的 L2 对应 代币

#./bridgeL1TokenToL2.sh $SEPOLIA_RPC_URL $VALUE_PRIVATE_KEY


# approve first 
# 批准 L1 桥合约转移你的代币
# https://sepolia.etherscan.io/tx/0x84641e351375c275c1eaab01de3a0ccbf25272ba1392d8d3412e6f6e357d024d
cast send 0x1dbd0cE9300310eeD2D967Fd4ACb3E61A1c07427 \
  "approve(address,uint256)" \
  "0xfd0bf71f60660e2f608ed56e1659c450eb113120" \
  "1000000000000000000000" \
  --rpc-url $1 \
  --private-key $2


cast send 0xfd0bf71f60660e2f608ed56e1659c450eb113120 \
  "bridgeERC20(address,address,uint256,uint32,bytes)" \
  "0x1dbd0cE9300310eeD2D967Fd4ACb3E61A1c07427" \
  "0xed1bac26422a646c83bb15ccaa9731a948801c85" \
  "10000000000" \
  "1000000" \
  "0x" \
  --rpc-url $1 \
  --private-key $2

