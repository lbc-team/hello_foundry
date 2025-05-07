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
    0x98dFd785d9f0083797D2708791DF77f41843F594 \
    src/MyERC20.sol:MyERC20 \
    --constructor-args $(cast abi-encode "constructor(string,string)" "OpenSpace S6" "OS6") \
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

```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
