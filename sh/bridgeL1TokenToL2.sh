# 部署 L1 对应的 L2 对应 代币

#./bridgeL1TokenToL2.sh $SEPOLIA_RPC_URL $PRIVATE_KEY
source .env

# approve first 
# 批准 L1 桥合约转移你的代币
# https://sepolia.etherscan.io/tx/0x84641e351375c275c1eaab01de3a0ccbf25272ba1392d8d3412e6f6e357d024d
cast send 0x9B4810B4b24EF08528A62f15d772e7a18Fe44D1b \
  "approve(address,uint256)" \
  "0xfd0bf71f60660e2f608ed56e1659c450eb113120" \
  "1000000000000000000000" \
  --rpc-url $SEPOLIA_RPC_URL \
  --private-key $PRIVATE_KEY


cast send 0xfd0bf71f60660e2f608ed56e1659c450eb113120 \
  "bridgeERC20(address,address,uint256,uint32,bytes)" \
  "0x9B4810B4b24EF08528A62f15d772e7a18Fe44D1b" \
  "0xc63fb64ce57c02097ce5317c1441e078804a57a2" \
  "100000000000000" \
  "1000000" \
  "0x" \
  --rpc-url $SEPOLIA_RPC_URL \
  --private-key $PRIVATE_KEY

