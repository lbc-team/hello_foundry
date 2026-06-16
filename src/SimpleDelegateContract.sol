// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {TokenBank} from "../src/TokenBank.sol";

contract SimpleDelegateContract {
    // Events
    event Executed(address indexed to, uint256 value, bytes data);
    event Log(string message);

    // Call structure for execution
    struct Call {
        bytes data;
        address to;
        uint256 value;
    }

    // ERC-7201 Storage structure
    struct SimpleDelegateStorage {
        address owner;
        uint256 amount;
        uint256 nonce;
    }

    // ERC-1271 magic value
    bytes4 constant ERC1271_MAGICVALUE = 0x1626ba7e;

    // Helper to get ERC-7201 namespaced storage
    function _getStorage() internal pure returns (SimpleDelegateStorage storage ds) {
        // keccak256(abi.encode(uint256(keccak256("simple.delegate.contract.storage")) - 1)) & ~0xff
        bytes32 slot = 0xb7bdf8f22fb4864f1d6b0429783f9829e0de5798993cdcd2484fcf1899173f00;
        assembly {
            ds.slot := slot
        }
    }

    // Returns the current owner of the contract.
    // If not set, defaults to address(this) (the account itself).
    function owner() public view returns (address) {
        address storedOwner = _getStorage().owner;
        return storedOwner == address(0) ? address(this) : storedOwner;
    }

    // Returns the current nonce for signature-based execution.
    function getNonce() external view returns (uint256) {
        return _getStorage().nonce;
    }

    // Returns the amount stored in namespaced storage.
    function getAmount() external view returns (uint256) {
        return _getStorage().amount;
    }

    // Explicit initializer to configure a custom owner.
    function initialize(address _owner) external payable {
        SimpleDelegateStorage storage ds = _getStorage();
        require(ds.owner == address(0), "Already initialized");
        require(_owner != address(0), "Invalid owner");
        ds.owner = _owner;
        emit Log("Initialized!");
    }

    function ping() external {
        emit Log("Pong!");
    }

    receive() external payable {}

    // 1. Direct execution by owner
    function execute(Call[] calldata calls) external payable {
        require(msg.sender == owner(), "Not authorized");
        _execute(calls);
    }

    // 2. Signature-based execution by third-party
    function executeWithSignature(
        Call[] calldata calls,
        uint256 nonce,
        bytes calldata signature
    ) external payable {
        SimpleDelegateStorage storage ds = _getStorage();
        require(nonce == ds.nonce, "Invalid nonce");
        ds.nonce++;

        bytes32 messageHash = getMessageHash(calls, nonce);
        address signer = _recoverSigner(messageHash, signature);
        require(signer == owner(), "Invalid signature");

        _execute(calls);
    }

    // Internal execution helper
    function _execute(Call[] calldata calls) internal {
        SimpleDelegateStorage storage ds = _getStorage();
        ds.amount = 1;

        for (uint256 i = 0; i < calls.length; i++) {
            Call memory op = calls[i];
            (bool success, bytes memory result) = op.to.call{value: op.value}(
                op.data
            );
            require(success, string(result));
            emit Executed(op.to, op.value, op.data);
        }
    }

    // Protected approveAndDeposit
    function approveAndDeposit(
        address token,
        address tokenbank,
        uint256 amount
    ) external {
        require(msg.sender == owner(), "Not authorized");
        IERC20(token).approve(tokenbank, amount);
        TokenBank(tokenbank).deposit(amount);
    }

    // ERC-1271 implementation
    function isValidSignature(bytes32 hash, bytes calldata signature) external view returns (bytes4) {
        address signer = _recoverSigner(hash, signature);
        if (signer == owner()) {
            return ERC1271_MAGICVALUE;
        }
        return 0xffffffff;
    }

    // EIP-712 hashing helpers
    function getMessageHash(Call[] calldata calls, uint256 nonce) public view returns (bytes32) {
        bytes32 structHash = keccak256(abi.encode(
            keccak256("Execute(Call[] calls,uint256 nonce)Call(address to,uint256 value,bytes data)"),
            _hashCalls(calls),
            nonce
        ));
        
        return keccak256(abi.encodePacked(
            "\x19\x01",
            _buildDomainSeparator(),
            structHash
        ));
    }

    function _hashCalls(Call[] calldata calls) internal pure returns (bytes32) {
        bytes32[] memory callHashes = new bytes32[](calls.length);
        for (uint256 i = 0; i < calls.length; i++) {
            callHashes[i] = keccak256(abi.encode(
                keccak256("Call(address to,uint256 value,bytes data)"),
                calls[i].to,
                calls[i].value,
                keccak256(calls[i].data)
            ));
        }
        return keccak256(abi.encodePacked(callHashes));
    }

    function _buildDomainSeparator() internal view returns (bytes32) {
        return keccak256(abi.encode(
            keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
            keccak256(bytes("SimpleDelegateContract")),
            keccak256(bytes("1")),
            block.chainid,
            address(this)
        ));
    }

    function _recoverSigner(bytes32 messageHash, bytes memory signature) internal pure returns (address) {
        if (signature.length != 65) {
            return address(0);
        }
        bytes32 r;
        bytes32 s;
        uint8 v;
        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }
        return ecrecover(messageHash, v, r, s);
    }
}

contract MockERC20 {
    address public minter;
    mapping(address => uint256) private _balances;

    constructor(address _minter) {
        minter = _minter;
    }

    function mint(uint256 amount, address to) public {
        _mint(to, amount);
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function _mint(address account, uint256 amount) internal {
        require(msg.sender == minter, "ERC20: msg.sender is not minter");
        require(account != address(0), "ERC20: mint to the zero address");
        unchecked {
            _balances[account] += amount;
        }
    }
}
