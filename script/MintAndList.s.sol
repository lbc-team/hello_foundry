// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

import {Script, console} from "forge-std/Script.sol";
import {MyERC721} from "../src/MyERC721.sol";
import {NFTMarket} from "../src/NFTMarket.sol";

contract MintAndListScript is Script {
    address public constant NFT_ADDRESS = 0x0aF22E4b00998a9ca993A7CBa3d1cb8B09e1aDD7;
    address public constant MARKET_ADDRESS = 0x38D5bFcF446d816dc95C8B2c639a86C8Fd12EDd2;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        vm.startBroadcast(deployerPrivateKey);

        MyERC721 nft = MyERC721(NFT_ADDRESS);
        NFTMarket market = NFTMarket(MARKET_ADDRESS);

        // 1. Mint NFT with custom/arbitrary URI
        string memory tokenUri = "ipfs://QmYwAPJzv5CZ1iaAmdw1ccm9K7vNKG85jvw3A6XX47XPGy";
        console.log("Minting NFT to %s...", deployer);
        uint256 tokenId = nft.mint(deployer, tokenUri);
        console.log("Successfully minted NFT with tokenId: %d", tokenId);

        // 2. Approve NFTMarket to transfer the NFT
        console.log("Approving NFTMarket to transfer NFT...");
        nft.approve(address(market), tokenId);

        // 3. List the NFT on the marketplace
        uint256 price = vm.envOr("PRICE", uint256(10 ether)); // Default to 10 tokens (18 decimals)
        console.log("Listing NFT %d on market for %d tokens...", tokenId, price);
        market.list(tokenId, price);
        console.log("NFT listed successfully!");

        vm.stopBroadcast();
    }
}
