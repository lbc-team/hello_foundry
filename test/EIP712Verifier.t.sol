// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/EIP712Verifier.sol";

contract EIP712VerifierTest is Test {
    EIP712Verifier public verifier;
    uint256 internal signerPrivateKey;
    address internal signer;
    address internal recipient;

    function setUp() public {
        verifier = new EIP712Verifier();
        signerPrivateKey = 0xA11CE;  // 示例私钥
        signer = vm.addr(signerPrivateKey);
        recipient = address(0xB0B);  // 示例接收地址
    }

    function testVerifySignature() public {
        // 创建要签名的数据
        EIP712Verifier.Send memory send = EIP712Verifier.Send({
            to: recipient,
            value: 1 ether
        });

        // 获取消息哈希
        bytes32 digest = verifier.hashSend(send);

        // 使用 vm.sign 进行签名
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(signerPrivateKey, digest);
        bytes memory signature = abi.encodePacked(r, s, v);

        // 验证签名
        bool isValid = verifier.verify(signer, send, signature);
        assertTrue(isValid, "Signature verification failed");

        // 测试错误的签名者
        uint256 wrongPrivateKey = 0xB0B;
        address wrongSigner = vm.addr(wrongPrivateKey);
        bool isInvalid = verifier.verify(wrongSigner, send, signature);
        assertFalse(isInvalid, "Signature verification should fail with wrong signer");
    }
} 