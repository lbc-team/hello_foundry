//SPDX-License-Identifier: MIT

pragma solidity 0.8.29;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// 定义接收代币的接口
interface ITokenReceiver {
    function tokensReceived(address from, address to, uint256 amount, bytes calldata data) external;
}

contract MyERC20 is ERC20 {
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
        _mint(msg.sender, 1000000 * 10 ** 18);
    }

    /**
     * @dev 带回调的转账函数
     * @param to 接收地址
     * @param amount 转账数量
     * @param data 附加数据
     */

    // transferWithCallback(NFTMarket address, price, tokenId)
    // tokenId encoded in data
    function transferWithCallback(address to, uint256 amount, bytes calldata data) external returns (bool) {
        // 执行转账
        transfer(to, amount);

        // 检查目标地址是否是合约
        if (to.code.length > 0) {
            // 调用目标合约的 tokensReceived 方法
            ITokenReceiver(to).tokensReceived(msg.sender, to, amount, data);
        }

        return true;
    }

}