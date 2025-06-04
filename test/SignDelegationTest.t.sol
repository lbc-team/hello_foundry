pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {Vm} from "forge-std/Vm.sol";
import {SimpleDelegateContract, MockERC20} from "../src/SimpleDelegateContract.sol";

contract SignDelegationTest is Test {
    // Alice's address and private key (EOA with no initial contract code).
    address payable ALICE_ADDRESS = payable(0x70997970C51812dc3A010C7d01b50e0d17dc79C8);
    uint256 constant ALICE_PK = 0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d;
 
    // Bob's address and private key (Bob will execute transactions on Alice's behalf).
    address constant BOB_ADDRESS = 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC;
    uint256 constant BOB_PK = 0x5de4111afa1a4b94908f83103eb1f1706367c2e68ca870fc3fb9a804cdab365a;
 
    // The contract that Alice will delegate execution to.
    SimpleDelegateContract public implementation;
 
    // ERC-20 token contract for minting test tokens.
    MockERC20 public token;
 
    function setUp() public {
        // Alice 将委托到这个合约
        implementation = new SimpleDelegateContract();
 
        // Deploy an ERC-20 token contract where Alice is the minter.
        token = new MockERC20(ALICE_ADDRESS);
    }
 
    function testSignDelegationAndThenAttachDelegation() public {
        // Construct a single transaction call: Mint 100 tokens to Bob.
        SimpleDelegateContract.Call[] memory calls = new SimpleDelegateContract.Call[](1);
        bytes memory data = abi.encodeCall(MockERC20.mint, (100, BOB_ADDRESS));
        calls[0] = SimpleDelegateContract.Call({to: address(token), data: data, value: 0});
 
        // Alice 签署一个委托，允许 `implementation` 执行交易。
        Vm.SignedDelegation memory signedDelegation = vm.signDelegation(address(implementation), ALICE_PK);
 
        // Bob 附加 Alice 的签名委托并广播。
        vm.broadcast(BOB_PK);
        vm.attachDelegation(signedDelegation);
 
        // 验证 Alice 的账户现在是一个智能合约。
        bytes memory code = address(ALICE_ADDRESS).code;
        require(code.length > 0, "no code written to Alice");
 
        // 作为 Bob，代表 Alice 的合约执行交易。
        SimpleDelegateContract(ALICE_ADDRESS).execute(calls);
 
        // 验证 Bob 成功收到 100 个代币。
        assertEq(token.balanceOf(BOB_ADDRESS), 100);
    }
 
    function testSignAndAttachDelegation() public {
        // Construct a single transaction call: Mint 100 tokens to Bob.
        SimpleDelegateContract.Call[] memory calls = new SimpleDelegateContract.Call[](1);
        bytes memory data = abi.encodeCall(ERC20.mint, (100, BOB_ADDRESS));
        calls[0] = SimpleDelegateContract.Call({to: address(token), data: data, value: 0});
 
        // Alice 签署并附加委托（一步完成，无需单独签署）
        vm.signAndAttachDelegation(address(implementation), ALICE_PK);
 
        // 验证 Alice 的账户现在是一个智能合约。
        bytes memory code = address(ALICE_ADDRESS).code;
        require(code.length > 0, "no code written to Alice");
 
        // 作为 Bob，代表 Alice 执行交易。
        vm.broadcast(BOB_PK);
        SimpleDelegateContract(ALICE_ADDRESS).execute(calls);
 
        // 验证 Bob 成功收到 100 个代币。
        vm.assertEq(token.balanceOf(BOB_ADDRESS), 100);
    }
}