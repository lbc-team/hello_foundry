//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./MyERC20.sol";
import "./MyERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

/**
 * @title NFTMarket
 * @dev 使用 ERC20 代币购买 ERC721 NFT 的市场合约
 */
contract NFTMarket is ITokenReceiver, IERC721Receiver {
    // ERC20 代币合约
    MyERC20 public paymentToken;
    // ERC721 NFT 合约
    MyERC721 public nftContract;

    // NFT 上架信息
    struct Listing {
        address seller;      // 卖家地址
        uint256 price;       // 价格（以 token 计价）
        bool isActive;       // 是否在售
    }

    // tokenId => Listing
    mapping(uint256 => Listing) public listings;

    // 事件
    event NFTListed(uint256 indexed tokenId, address indexed seller, uint256 price);
    event NFTSold(uint256 indexed tokenId, address indexed seller, address indexed buyer, uint256 price);
    event NFTDelisted(uint256 indexed tokenId, address indexed seller);

    /**
     * @dev 构造函数
     * @param _paymentToken ERC20 代币合约地址
     * @param _nftContract ERC721 NFT 合约地址
     */
    constructor(address _paymentToken, address _nftContract) {
        paymentToken = MyERC20(_paymentToken);
        nftContract = MyERC721(_nftContract);
    }

    /**
     * @dev 上架 NFT
     * @param tokenId NFT 的 token ID
     * @param price NFT 价格（以 token 计价）
     */
    function list(uint256 tokenId, uint256 price) external {
        require(price > 0, "NFTMarket: price must be greater than 0");
        require(nftContract.ownerOf(tokenId) == msg.sender, "NFTMarket: caller is not token owner");
        require(!listings[tokenId].isActive, "NFTMarket: NFT already listed");

        // 将 NFT 转移到合约
        nftContract.safeTransferFrom(msg.sender, address(this), tokenId);

        // 记录上架信息
        listings[tokenId] = Listing({
            seller: msg.sender,
            price: price,
            isActive: true
        });

        emit NFTListed(tokenId, msg.sender, price);
    }

    /**
     * @dev 下架 NFT
     * @param tokenId NFT 的 token ID
     */
    function delist(uint256 tokenId) external {
        Listing storage listing = listings[tokenId];
        require(listing.isActive, "NFTMarket: NFT not listed");
        require(listing.seller == msg.sender, "NFTMarket: caller is not seller");

        // 将 NFT 归还给卖家
        nftContract.safeTransferFrom(address(this), msg.sender, tokenId);

        // 删除上架信息
        listing.isActive = false;

        emit NFTDelisted(tokenId, msg.sender);
    }

    /**
     * @dev 购买 NFT
     * @param tokenId 要购买的 NFT token ID
     */
    function buyNFT(uint256 tokenId) external {
        Listing storage listing = listings[tokenId];
        require(listing.isActive, "NFTMarket: NFT not listed");

        address seller = listing.seller;
        uint256 price = listing.price;

        // 标记为已售出
        listing.isActive = false;

        // msg.sender approve paymentToken to NFTMarket
        // 转移 token 从买家到卖家
        require(
            paymentToken.transferFrom(msg.sender, seller, price),
            "NFTMarket: token transfer failed"
        );

        // 转移 NFT 从合约到买家
        nftContract.safeTransferFrom(address(this), msg.sender, tokenId);

        emit NFTSold(tokenId, seller, msg.sender, price);
    }


    // Buy NFT with transferWithCallback version

    /**
     * @dev 实现 ITokenReceiver 接口，在接收 token 时自动购买 NFT
     * @param from 代币发送者
     * @param to 代币接收者（本合约地址）
     * @param amount 代币数量
     * @param data 附加数据，应包含要购买的 NFT tokenId (bytes 编码的 uint256)
     */
    function tokensReceived(
        address from,
        address to,
        uint256 amount,
        bytes calldata data// 0x0000000000000000000000000000000000000000000000000000000000000001
    ) external override {
        require(msg.sender == address(paymentToken), "NFTMarket: caller is not payment token");
        require(to == address(this), "NFTMarket: invalid recipient");
        require(data.length >= 32, "NFTMarket: invalid data");

        // 解码 tokenId
        uint256 tokenId = abi.decode(data, (uint256));

        Listing storage listing = listings[tokenId];
        require(listing.isActive, "NFTMarket: NFT not listed");
        require(amount >= listing.price, "NFTMarket: insufficient payment");

        address seller = listing.seller;
        uint256 price = listing.price;

        // 标记为已售出
        listing.isActive = false;

        // 转移 token 到卖家
        require(
            paymentToken.transfer(seller, price),
            "NFTMarket: token transfer to seller failed"
        );

        // 如果支付的代币超过价格，退还多余部分
        if (amount > price) {
            require(
                paymentToken.transfer(from, amount - price),
                "NFTMarket: token refund failed"
            );
        }

        // 转移 NFT 到买家
        nftContract.safeTransferFrom(address(this), from, tokenId);

        emit NFTSold(tokenId, seller, from, price);
    }

    /**
     * @dev 实现 IERC721Receiver 接口，允许合约接收 NFT
     */
    function onERC721Received(
        address /* operator */,
        address /* from */,
        uint256 /* tokenId */,
        bytes calldata /* data */
    ) external pure override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    /**
     * @dev 查询 NFT 上架信息
     * @param tokenId NFT token ID
     * @return seller 卖家地址
     * @return price 价格
     * @return isActive 是否在售
     */
    function getListing(uint256 tokenId) external view returns (
        address seller,
        uint256 price,
        bool isActive
    ) {
        Listing memory listing = listings[tokenId];
        return (listing.seller, listing.price, listing.isActive);
    }
}
