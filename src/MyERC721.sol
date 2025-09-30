//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title MyERC721
 * @dev 继承 ERC721URIStorage 的 NFT 合约
 */
contract MyERC721 is ERC721URIStorage, Ownable {
    // 当前 token ID 计数器
    uint256 private _tokenIdCounter;

    /**
     * @dev 构造函数
     * @param name NFT 名称
     * @param symbol NFT 符号
     */
    constructor(string memory name, string memory symbol) ERC721(name, symbol) Ownable(msg.sender) {
        _tokenIdCounter = 0;
    }

    /**
     * @dev 铸造 NFT
     * @param to 接收地址
     * @param uri token URI (元数据链接)
     * @return tokenId 铸造的 token ID
     */
    function mint(address to, string memory uri) public onlyOwner returns (uint256) {
        uint256 tokenId = _tokenIdCounter;
        _tokenIdCounter++;

        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);

        return tokenId;
    }

    /**
     * @dev 批量铸造 NFT
     * @param to 接收地址
     * @param uris token URI 数组
     * @return tokenIds 铸造的 token ID 数组
     */
    function batchMint(address to, string[] memory uris) public onlyOwner returns (uint256[] memory) {
        uint256[] memory tokenIds = new uint256[](uris.length);

        for (uint256 i = 0; i < uris.length; i++) {
            tokenIds[i] = mint(to, uris[i]);
        }

        return tokenIds;
    }

    /**
     * @dev 获取当前 token ID 计数
     * @return 当前的 token ID 计数
     */
    function getCurrentTokenId() public view returns (uint256) {
        return _tokenIdCounter;
    }

    /**
     * @dev 销毁 NFT
     * @param tokenId 要销毁的 token ID
     */
    function burn(uint256 tokenId) public {
        require(ownerOf(tokenId) == msg.sender, "MyERC721: caller is not token owner");
        _burn(tokenId);
    }
}
