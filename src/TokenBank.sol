// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@permit2-light-sdk/sdk/IPermit2.sol";
import "@permit2-light-sdk/sdk/ISignatureTransfer.sol";

// code generate by AI for demo
contract TokenBank {
    IERC20 public token;
    IPermit2 public immutable permit2;
    
    // 记录每个地址的存款数量
    mapping(address => uint256) public deposits;
    
    // 记录总存款数量
    uint256 public totalDeposits;
    
    // 事件
    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    
    constructor(address _token, address _permit2)  {
        token = IERC20(_token);
        permit2 = IPermit2(_permit2);
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
    
    function depositWithPermit2(
        uint256 amount,
        uint256 nonce,
        uint256 deadline,
        bytes calldata signature
    ) external {
        require(amount > 0, "Amount must be greater than 0");


        // 构造 PermitTransferFrom 结构体
        ISignatureTransfer.PermitTransferFrom memory permit = ISignatureTransfer.PermitTransferFrom({
            permitted: ISignatureTransfer.TokenPermissions({
                token: address(token), // 要授权的代币地址
                amount: amount  // 要授权的金额
                }),
            nonce: nonce, // 防止重放攻击的随机数
            deadline: deadline // 授权的截止时间
        });
        
        // 构造 SignatureTransferDetails 结构体
        ISignatureTransfer.SignatureTransferDetails memory transferDetails = ISignatureTransfer.SignatureTransferDetails({
            to: address(this), // 接收代币的地址（当前合约）
            requestedAmount: permit.permitted.amount // // 请求转账的金额
        });

        // 使用 Permit2 的 permitTransferFrom 进行授权和转账
        permit2.permitTransferFrom(
            permit,
            transferDetails,
            msg.sender,     
            signature
        );
        
        // 更新存款记录
        deposits[msg.sender] += permit.permitted.amount;
        totalDeposits += permit.permitted.amount;
        
        emit Deposit(msg.sender, permit.permitted.amount);
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