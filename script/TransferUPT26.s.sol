// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "./BaseScript.s.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TransferUPT26Script is BaseScript {
    function run() public broadcaster {
        IERC20 token = IERC20(0xc9423Ee04F2afA3A4f73Fa5a21427543a7A5EdbE);

        address[5] memory recipients = [
            0xd82eCEFeA2197622579922034d00735E4e4c095d,
            0x00efD658975Cd40fE6952E69256836cF5FFC1C88,
            0x36E8c3976a1dFC65ad9D343085525331D25e0C70,
            0x9ACFC0408F98F8290744F6c16a5657797b918be4,
            0x97f7C1191de61C24F26168d9541Aa036f2dA5ea3
        ];

        uint256[5] memory amounts;
        amounts[0] = 100 ether;
        amounts[1] = 50 ether;
        amounts[2] = 25 ether;
        amounts[3] = 10 ether;
        amounts[4] = 10 ether;

        for (uint256 i = 0; i < recipients.length; i++) {
            require(
                token.transfer(recipients[i], amounts[i]),
                "UPT26 transfer failed"
            );
            console.log("Transferred to %s", recipients[i]);
            console.log("Amount %s", amounts[i]);
        }
    }
}
