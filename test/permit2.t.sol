// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import "forge-std/Test.sol";
import "forge-std/console2.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@permit2-light-sdk/sdk/IPermit2.sol";
import "@permit2-light-sdk/sdk/ISignatureTransfer.sol";
import "../src/TokenBank.sol";
import {MyERC20} from "../src/MyERC20.sol";

contract Permit2Test is Test {
    TokenBank public bank;
    MyERC20 public token;
    IPermit2 public permit2;
    address public user1;
    uint256 public user1PrivateKey;
    uint256 public sepoliaForkId;

    // Permit2 contract address
    address constant PERMIT2_ADDRESS = 0x000000000022D473030F116dDEE9F6B43aC78BA3;

    function setUp() public {

        uint forkBlock = 8219000;
        sepoliaForkId = vm.createSelectFork(vm.rpcUrl("sepolia"), forkBlock);

        // deploy permit2
        permit2 = IPermit2(PERMIT2_ADDRESS);
        console2.log("permit2");
        // Deploy token and bank
        token = new MyERC20("Test Token", "TEST");
        bank = new TokenBank(address(token), address(permit2));

        // Setup user1
        user1PrivateKey = 0x3389;
        user1 = vm.addr(user1PrivateKey);

        // Transfer tokens to user1
        token.transfer(user1, 1000 * 10 ** 18);

        // User approves Permit2
        vm.startPrank(user1);
        token.approve(address(permit2), type(uint256).max);
        vm.stopPrank();
    }

    function testDepositWithPermit2() public {
        assertEq(vm.activeFork(), sepoliaForkId);

        uint256 depositAmount = 500 * 10 ** 18;

        // get the nonce
        uint256 wordPos = 0;
        uint256 bitmap = permit2.nonceBitmap(user1, wordPos);
        uint256 nonce = _findNextNonce(bitmap, wordPos);
        console2.log("nonce:", nonce);

        uint256 deadline = block.timestamp + 1 hours;

        // Create permit message
        ISignatureTransfer.PermitTransferFrom memory permit = ISignatureTransfer.PermitTransferFrom({
            permitted: ISignatureTransfer.TokenPermissions({ token: address(token), amount: depositAmount }),
            nonce: nonce,
            deadline: deadline
        });

        console2.log("Initial user balance: %d", token.balanceOf(user1));
        console2.log("Initial bank balance: %d", token.balanceOf(address(bank)));
        console2.log("Permit2 allowance: %d", token.allowance(user1, address(permit2)));

        // get the digest
        bytes32 digest = _getPermitTransferFromDigest(permit, address(bank), address(permit2));
        console2.log("digest: %s", Strings.toHexString(uint256(digest)));

        // sign the digest
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(user1PrivateKey, digest);
        console2.log("v: %s", Strings.toHexString(uint256(v)));
        console2.log("r: %s", Strings.toHexString(uint256(r)));
        console2.log("s: %s", Strings.toHexString(uint256(s)));

        // encode the signature
        bytes memory signature = abi.encodePacked(r, s, v);
        console2.log("signature:");
        console2.logBytes(signature);

        // Execute deposit with permit2
        vm.prank(user1);
        bank.depositWithPermit2(depositAmount, nonce, deadline, signature);


        console2.log("bank token balance: %d", token.balanceOf(address(bank)));

        // Verify deposit
        assertEq(token.balanceOf(address(bank)), depositAmount, "Bank token balance should increase by deposit amount");
    }

    // find the next available nonce
    function _findNextNonce(uint256 bitmap, uint256 wordPos) internal pure returns (uint256) {
        // find the first unused bit in the current bitmap
        uint256 bit;
        for (bit = 0; bit < 256; bit++) {
            if ((bitmap & (1 << bit)) == 0) {
                break;
            }
        }

        // calculate the full nonce
        // nonce = (wordPos << 8) | bit
        return (wordPos << 8) | bit;
    }

    function _getPermitTransferFromDigest(
        ISignatureTransfer.PermitTransferFrom memory permit,
        address spender,
        address permit2Address
    )
        internal
        view
        returns (bytes32)
    {
        // get the domain separator
        bytes32 DOMAIN_SEPARATOR = IPermit2(permit2Address).DOMAIN_SEPARATOR();
        console2.log("DOMAIN_SEPARATOR: %s", vm.toString(DOMAIN_SEPARATOR));

        // get the type hash
        bytes32 typeHash = keccak256(
            "PermitTransferFrom(TokenPermissions permitted,address spender,uint256 nonce,uint256 deadline)TokenPermissions(address token,uint256 amount)"
        );

        // get the token permissions hash
        bytes32 tokenPermissionsHash = keccak256(
            abi.encode(
                keccak256("TokenPermissions(address token,uint256 amount)"),
                permit.permitted.token,
                permit.permitted.amount
            )
        );

        // get the struct hash
        bytes32 structHash =
            keccak256(abi.encode(typeHash, tokenPermissionsHash, spender, permit.nonce, permit.deadline));

        // get the final digest
        return keccak256(abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR, structHash));
    }
}