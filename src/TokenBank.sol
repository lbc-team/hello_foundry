// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// code generate by AI for demo
contract TokenBank is Ownable {
    IERC20 public token;
    
    // 记录每个地址的存款数量
    mapping(address => uint256) public deposits;
    
    // 记录总存款数量
    uint256 public totalDeposits;
    
    // 事件
    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    
    constructor(address _token) Ownable(msg.sender) {
        token = IERC20(_token);
    }
    
    /**
     * @notice 存入代币
     * @param amount 存入数量
     */
    function deposit(uint256 amount) external {
        require(amount > 0, "Amount must be greater than 0");
        
        // 将代币从用户转移到合约
        require(token.transferFrom(msg.sender, address(this), amount), "Transfer failed");
        
        // 更新存款记录
        deposits[msg.sender] += amount;
        totalDeposits += amount;
        
        emit Deposit(msg.sender, amount);
    }
    
    /**
     * @notice 提取代币
     * @param amount 提取数量
     */
    function withdraw(uint256 amount) external {
        require(amount > 0, "Amount must be greater than 0");
        require(deposits[msg.sender] >= amount, "Insufficient balance");
        
        // 更新存款记录
        deposits[msg.sender] -= amount;
        totalDeposits -= amount;
        
        // 将代币转回给用户
        require(token.transfer(msg.sender, amount), "Transfer failed");
        
        emit Withdraw(msg.sender, amount);
    }
    
    /**
     * @notice 查询用户的存款余额
     * @param user 用户地址
     * @return 存款余额
     */
    function balanceOf(address user) external view returns (uint256) {
        return deposits[user];
    }
} 