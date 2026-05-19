// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./BaseScript.s.sol";
import "../src/MyERC721.sol";
import "../src/NFTMarket.sol";

contract NFTMarketScript is BaseScript {
    address internal constant SEPOLIA_PAYMENT_TOKEN = 0xc9423Ee04F2afA3A4f73Fa5a21427543a7A5EdbE;

    function run() public broadcaster {
        MyERC721 nft = new MyERC721("HelloFoundryNFT", "HFNFT");
        NFTMarket market = new NFTMarket(SEPOLIA_PAYMENT_TOKEN, address(nft));

        console.log("MyERC721 deployed on %s", address(nft));
        console.log("NFTMarket deployed on %s", address(market));
        console.log("Payment token %s", SEPOLIA_PAYMENT_TOKEN);

        saveContract("MyERC721", address(nft));
        saveContract("NFTMarket", address(market));
    }
}
