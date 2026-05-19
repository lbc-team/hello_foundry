## Foundry

登链社区[线上线下集训营](https://learnblockchain.cn/openspace/1)参考代码库


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

forge create Counter --account test_test --broadcast --rpc-url http://127.0.0.1:8545

forge create Counter --keystore .keys/wallet1 --rpc-url http://localhost:8545 --broadcast

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
    0x4b15611f26538d3f95755eaC90F18fbFF5E2D068 \
    src/Counter.sol:Counter \
    --chain sepolia \
    --etherscan-api-key $ETHERSCAN_API_KEY


```

## forge inspect

forge inspect StorageVars storageLayout

forge inspect MyERC20 abi --json > MyERC20.json

## cast 命令

```
$ cast <subcommand>
```

### wallet 

> cast wallet -h # 查看所有的命令选项

> cast wallet new [DIR] <ACCOUNT_NAME> # Create a new random keypair

> cast wallet new-mnemonic  #  mnemonic phrase

> cast wallet address [PRIVATE_KEY]  # private key to an address

> cast wallet import -i -k <KEYSTORE_DIR> <ACCOUNT_NAME>

> cast wallet import --mnemonic "test test test test test test test test test test test junk” -k <KEYSTORE_DIR> <ACCOUNT_NAME>

### 调用合约

cast call 0x5FbDB2315678afecb367f032d93F642f64180aa3 "number()" --rpc-url local
cast send 0x5FbDB2315678afecb367f032d93F642f64180aa3 "setNumber(uint256)" 10 --rpc-url local --account test_test

### 转账

cast to-wei 1
cast send 0xa0Ee7A142d267C1f36714E4a8F75612F20a79720 --value 1000000000000000000 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --rpc-url local

### ERC20 转账

cast send  0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9

cast send 0xc5a5C42992dECbae36851359345FE25997F5C42d "transfer(address to, uint256 value)" 0xa0Ee7A142d267C1f36714E4a8F75612F20a79720 1000000000000000000000 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --rpc-url local

cast send 0xc5a5C42992dECbae36851359345FE25997F5C42d "approve(address to, uint256 value)" 0xa0Ee7A142d267C1f36714E4a8F75612F20a79720 1000000000000000000000 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --rpc-url local


###  keccak
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



cast run 0xabc123... \
  --rpc-url https://eth-mainnet.g.alchemy.com/v2/xxxx

cast run 0x383ac9c6749d0b91d0766b0b5ec73c604582bf6b711683e1c7c2971577af2d46 --rpc-url https://rpc.eth.gateway.fm

## Test

```
forge test test/Cheatcode.t.sol --mt test_Roll -vv
forge test --mt test_Deal -vv
```

## Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```


<!-- enc(uint a, bytes memory b, address to) -->
0x0000000000000000000000000000000000000000000000000000000000000001
  0000000000000000000000000000000000000000000000000000000000000060
  00000000000000000000000028c6c06298d514db089934071355e5743bf21d60
  0000000000000000000000000000000000000000000000000000000000000002
  0123000000000000000000000000000000000000000000000000000000000000

// 
  0x0000000000000000000000000000000000000000000000000000000000000001
    0000000000000000000000000000000000000000000000000000000000000080
    00000000000000000000000028c6c06298d514db089934071355e5743bf21d60
    00000000000000000000000000000000000000000000000000000000000000c0
    0000000000000000000000000000000000000000000000000000000000000002
    0123000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000002
    7890000000000000000000000000000000000000000000000000000000000000

