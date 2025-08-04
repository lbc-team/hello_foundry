# 部署 L1 对应的 L2 对应 代币

#./deployL2Token.sh $SEPOLIA_BASE_RPC_URL $VALUE_PRIVATE_KEY

cast send 0x4200000000000000000000000000000000000012 \
  "createOptimismMintableERC20(address,string,string)" \
  "0x1dbd0cE9300310eeD2D967Fd4ACb3E61A1c07427" \
  "TinyBase" \
  "TinyBase" \
  --rpc-url $1 \
  --private-key $2


# example: 0xed1bac26422a646c83bb15ccaa9731a948801c85