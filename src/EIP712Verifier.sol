// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/EIP712.sol";

contract EIP712Verifier is EIP712 {
    using ECDSA for bytes32;

    struct Send {
        address to;
        uint256 value;
    }

    bytes32 public constant SEND_TYPEHASH = keccak256("Send(address to,uint256 value)");

    constructor() EIP712("EIP712Verifier", "1.0.0") {}

    function hashSend(Send memory send) public view returns (bytes32) {
        return _hashTypedDataV4(
            keccak256(
                abi.encode(
                    SEND_TYPEHASH,
                    send.to,
                    send.value
                )
            )
        );
    }

    function verify(
        address signer,
        Send memory send,
        bytes memory signature
    ) public view returns (bool) {
        bytes32 digest = hashSend(send);
        return digest.recover(signature) == signer;
    }

    function sendByEIP712Signature(address signer, address to, uint256 value, bytes memory signature ) public {
        require(verify(signer, Send({to: to, value: value}), signature), "Invalid signature");
        (bool success, ) = to.call{value: value}("");
        require(success, "Transfer failed");
    }
} 