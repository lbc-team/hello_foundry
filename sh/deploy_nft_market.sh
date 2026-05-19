#!/usr/bin/env bash

source .env
set -euo pipefail

if [[ -z "${PRIVATE_KEY:-}" ]]; then
  echo "PRIVATE_KEY is required"
  exit 1
fi

if [[ -z "${SEPOLIA_RPC_URL:-}" ]]; then
  echo "SEPOLIA_RPC_URL is required"
  exit 1
fi

VERIFY_ARGS=()

if [[ "${1:-}" == "--verify" || "${1:-}" == "verify" ]]; then
  if [[ -z "${ETHERSCAN_API_KEY:-}" ]]; then
    echo "ETHERSCAN_API_KEY is required when using --verify"
    exit 1
  fi

  VERIFY_ARGS=(--verify)
fi

forge script script/NFTMarket.s.sol:NFTMarketScript \
  --rpc-url sepolia \
  --broadcast \
  --slow \
  "${VERIFY_ARGS[@]}"
