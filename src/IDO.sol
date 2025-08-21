// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract IDO {
    IERC20 public opsToken;
    address public owner;
    
    uint256 public constant TOKEN_PRICE = 0.0001 ether; // 1 OPS = 0.0001 ETH
    uint256 public constant TOTAL_TOKENS = 1_000_000 * 1e18; // 100万 OPS
    uint256 public constant SOFT_CAP = 100 ether; // 预售目标
    uint256 public constant HARD_CAP = 200 ether; // 最大募集
    uint256 public constant MIN_CONTRIBUTION = 0.001 ether; // 最小参与
    
    uint256 public totalRaised;
    uint256 public totalClaimed;
    uint256 public deadline;
    bool public finalized;
    bool public success;

    mapping(address => uint256) public contributions;
    mapping(address => uint256) public claimed;

    event Presaled(address indexed user, uint256 amount);
    event Claimed(address indexed user, uint256 tokenAmount);
    event Refunded(address indexed user, uint256 amount);
    event Finalized(bool success);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    modifier beforeDeadline() {
        require(block.timestamp < deadline, "IDO ended");
        _;
    }

    modifier afterDeadline() {
        require(block.timestamp >= deadline, "IDO not ended");
        _;
    }

    constructor(address _opsToken, uint256 _duration) {
        require(_opsToken != address(0), "Invalid token");
        opsToken = IERC20(_opsToken);
        owner = msg.sender;
        deadline = block.timestamp + _duration;
    }

    function finalize() external afterDeadline {
        require(!finalized, "Already finalized");
        finalized = true;
        if (totalRaised >= SOFT_CAP) {
            success = true;
        } else {
            success = false;
        }
        emit Finalized(success);
    }

    function claim() external {
        require(finalized, "Not finalized");
        require(success, "IDO failed");
        uint256 userContribution = contributions[msg.sender];
        require(userContribution > 0, "No contribution");
        require(claimed[msg.sender] == 0, "Already claimed");
        uint256 tokenAmount = userContribution * 1e18 / TOKEN_PRICE;
        require(tokenAmount > 0, "No tokens to claim");
        claimed[msg.sender] = tokenAmount;
        totalClaimed += tokenAmount;
        require(opsToken.transfer(msg.sender, tokenAmount), "Token transfer failed");
        emit Claimed(msg.sender, tokenAmount);
    }

    function refund() external {
        require(finalized, "Not finalized");
        require(!success, "IDO succeeded");
        uint256 userContribution = contributions[msg.sender];
        require(userContribution > 0, "No contribution");
        contributions[msg.sender] = 0;
        (bool sent, ) = msg.sender.call{value: userContribution}("");
        require(sent, "Refund failed");
        emit Refunded(msg.sender, userContribution);
    }

    function withdrawETH() external onlyOwner {
        require(finalized && success, "Not allowed");
        (bool sent, ) = owner.call{value: address(this).balance}("");
        require(sent, "Withdraw failed");
    }

    // 允许 owner 回收未售出的 token
    function withdrawUnsoldTokens() external onlyOwner {
        require(finalized, "Not finalized");
        uint256 sold = totalRaised * 1e18 / TOKEN_PRICE;
        uint256 unsold = TOTAL_TOKENS - sold;
        if (unsold > 0) {
            require(opsToken.transfer(owner, unsold), "Token transfer failed");
        }
    }

    function presale() external payable beforeDeadline {
        require(msg.value >= MIN_CONTRIBUTION, "Below min contribution");
        require(totalRaised + msg.value <= HARD_CAP, "Exceeds hard cap");
        contributions[msg.sender] += msg.value;
        totalRaised += msg.value;
        emit Presaled(msg.sender, msg.value);
    }

    receive() external payable {
        require(msg.value >= MIN_CONTRIBUTION, "Below min contribution");
        require(block.timestamp < deadline, "IDO ended");
        require(totalRaised + msg.value <= HARD_CAP, "Exceeds hard cap");
        contributions[msg.sender] += msg.value;
        totalRaised += msg.value;
        emit Presaled(msg.sender, msg.value);
    }
} 