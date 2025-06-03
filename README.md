## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

-   **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
-   **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
-   **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
-   **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell



forge create Counter --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --rpc-url http://localhost:8545 --broadcast


forge script script/Counter.s.sol --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --rpc-url http://localhost:8545 --broadcast


$ forge script script/Counter_2.s.sol --rpc-url <your_rpc_url> --private-key <your_private_key>

forge script script/Counter.s.sol --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --rpc-url http://localhost:8545 --broadcast

$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>

$ forge script script/xxx.sol --rpc-url local --broadcast

$ forge script script/TokenBank.s.sol  --broadcast --rpc-url http://127.0.0.1:8545

# 在script 代码中加载账号
$ forge script script/MyERC20_2.s.sol --rpc-url http://localhost:8545 --broadcast
$ forge script script/MyERC20_2.s.sol --rpc-url sepolia --broadcast



forge verify-contract \
    0x3DFcc1C8bd62EC42513E1424945546D447Ef3A2E \
    src/MyERC20.sol:MyERC20 \
    --constructor-args $(cast abi-encode "constructor(string,string)" "OpenSpace Token" "OPS") \
    --verifier etherscan \
    --verifier-url https://api-sepolia.etherscan.io/api \
    --etherscan-api-key $ETHERSCAN_API_KEY \
    --chain-id 11155111


forge verify-contract \
    0xD3c6a2c8687cBCF63ac131E05c65Ee1BEa2e3241 \
    src/Counter.sol:Counter \
    --verifier etherscan \
    --verifier-url $POLYSCAN_URL \
    --etherscan-api-key $POLYSCAN_API_KEY \
    --chain-id 137

forge inspect MyERC20 abi --json > MyERC20.json

# 转账
cast to-wei 1
cast send 0xa0Ee7A142d267C1f36714E4a8F75612F20a79720 --value 1000000000000000000 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --rpc-url local

# ERC20 转账

cast send  0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9

cast send 0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9 "transfer(address to, uint256 value)" 0xa0Ee7A142d267C1f36714E4a8F75612F20a79720 1000000000000000000000 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --rpc-url local

cast send 0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9 "approve(address to, uint256 value)" 0xa0Ee7A142d267C1f36714E4a8F75612F20a79720 1000000000000000000000 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --rpc-url local

forge inspect StorageVars storageLayout
```

### Cast

```shell
$ cast <subcommand>

#  keccak
cast keccak 'transfer(address to, uint256 value)'
0xa9059c
cast keccak 'transfer(address,uint256)'  # 0xa9059cbb2ab09eb219583f4a59a5d0623ade346d962bcd4e46b11da047c9049b

cast sig 'transfer(address to, uint256 value)'
cast sig 'transfer(address,uint256)'

//cast to-wei 1700
cast abi-encode "transfer(address to, uint256 value)" 0x28c6c06298d514db089934071355e5743bf21d60 1700000000
# 0x00000000000000000000000028c6c06298d514db089934071355e5743bf21d60000000000000000000000000000000000000000000000000000000006553f100

cast decode-calldata 'transfer(address to, uint256 value)' 0xa9059cbb00000000000000000000000028c6c06298d514db089934071355e5743bf21d60000000000000000000000000000000000000000000000000000000006553f100

cast pretty-calldata 0xa9059cbb00000000000000000000000028c6c06298d514db089934071355e5743bf21d60000000000000000000000000000000000000000000000000000000006553f100

cast abi-encode 'enc(uint a, bytes memory b)' 1 0x0123
#0x0000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000020123000000000000000000000000000000000000000000000000000000000000 

> cast sig-event 'Transfer(address indexed from, address indexed to, uint256 value)'
> 0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef

> cast tx 0x5f7fd2457348472ec5c25500cae145b91843ccf3921e4cbe78fd91c39a8b6855 --rpc-url https://uk.rpc.blxrbdn.com
> cast receipt 0x5f7fd2457348472ec5c25500cae145b91843ccf3921e4cbe78fd91c39a8b6855 --rpc-url https://uk.rpc.blxrbdn.com

logs                 [{"address":"0xdac17f958d2ee523a2206206994597c13d831ec7","topics":["0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef","0x000000000000000000000000214095cca66b93f7dd819e51a19d6560f8450936","0x00000000000000000000000028c6c06298d514db089934071355e5743bf21d60"],"data":"0x000000000000000000000000000000000000000000000000000000006553f100","blockHash":"0x3bdf2afb4eddcb848093c6f2466804a45aea4c5b12532136e1f48a0e474a0719","blockNumber":"0x1570445","transactionHash":"0x5f7fd2457348472ec5c25500cae145b91843ccf3921e4cbe78fd91c39a8b6855","transactionIndex":"0x163","logIndex":"0x255","removed":false}]



```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
