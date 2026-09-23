# 部署 L1 对应的 L2 对应 代币

source .env

#./deployL2Token.sh $SEPOLIA_BASE_RPC_URL $PRIVATE_KEY

cast send 0x4200000000000000000000000000000000000012 \
  "createOptimismMintableERC20(address,string,string)" \
  "0x37FcA00F832dA2E0D91EcC532E00f977Cd163f14" \
  "L2DAPPS2" \
  "L2DAPPS2" \
  --rpc-url https://optimism-sepolia.drpc.org \
  --private-key $PRIVATE_KEY


# example: 0xed1bac26422a646c83bb15ccaa9731a948801c85