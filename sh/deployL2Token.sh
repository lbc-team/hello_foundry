# 部署 L1 对应的 L2 对应 代币

source .env

#./deployL2Token.sh $SEPOLIA_BASE_RPC_URL $PRIVATE_KEY

cast send 0x4200000000000000000000000000000000000012 \
  "createOptimismMintableERC20(address,string,string)" \
  "0x9B4810B4b24EF08528A62f15d772e7a18Fe44D1b" \
  "UPT2026" \
  "UPT2026" \
  --rpc-url $SEPOLIA_BASE_RPC_URL \
  --private-key $PRIVATE_KEY


# example: 0xed1bac26422a646c83bb15ccaa9731a948801c85