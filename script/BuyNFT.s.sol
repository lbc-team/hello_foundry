// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

import {Script, console} from "forge-std/Script.sol";
import {NFTMarket} from "../src/NFTMarket.sol";
import {MyERC20} from "../src/MyERC20.sol";

contract BuyNFTScript is Script {
    address public constant PAYMENT_TOKEN_ADDRESS = 0xc9423Ee04F2afA3A4f73Fa5a21427543a7A5EdbE;
    address public constant MARKET_ADDRESS = 0x38D5bFcF446d816dc95C8B2c639a86C8Fd12EDd2;

    function run() external {
        // Read TOKEN_ID from environment variable
        uint256 tokenId = vm.envUint("TOKEN_ID");

        // Read buyer private key, default to PRIVATE_KEY if BUYER_PRIVATE_KEY is not set
        uint256 buyerPrivateKey;
        try vm.envUint("BUYER_PRIVATE_KEY") returns (uint256 pk) {
            buyerPrivateKey = pk;
        } catch {
            buyerPrivateKey = vm.envUint("PRIVATE_KEY");
        }
        vm.startBroadcast(buyerPrivateKey);

        NFTMarket market = NFTMarket(MARKET_ADDRESS);
        MyERC20 paymentToken = MyERC20(PAYMENT_TOKEN_ADDRESS);

        // Get the price of the listing
        (address seller, uint256 price, bool isActive) = market.getListing(tokenId);
        require(isActive, "NFT is not listed on market");

        console.log("Found listing for NFT %d:", tokenId);
        console.log("  Seller: %s", seller);
        console.log("  Price: %d tokens", price);

        // 1. Approve the market to transfer payment tokens
        console.log("Approving NFTMarket to transfer payment tokens...");
        paymentToken.approve(address(market), price);

        // 2. Buy the NFT
        console.log("Executing buyNFT...");
        market.buyNFT(tokenId);
        console.log("NFT purchased successfully!");

        vm.stopBroadcast();
    }
}
