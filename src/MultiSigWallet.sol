// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// code generate by AI for demo
contract MultiSigWallet {
    // 提案结构
    struct Proposal {
        address target;        // 目标合约地址
        uint256 value;         // 发送的 ETH 数量
        bytes data;            // 调用数据
        bool executed;         // 是否已执行
        uint256 confirmations; // 确认数量
    }

    // 多签持有者列表
    address[] public owners;
    // 记录地址是否为多签持有者
    mapping(address => bool) public isOwner;
    // 提案列表
    Proposal[] public proposals;
    // 记录每个多签持有者对每个提案的确认状态
    mapping(uint256 => mapping(address => bool)) public confirmations;
    // 多签门槛（2/3）
    uint256 public threshold;

    // 事件
    event ProposalSubmitted(uint256 indexed proposalId, address indexed proposer, address target, uint256 value, bytes data);
    event ProposalConfirmed(uint256 indexed proposalId, address indexed owner);
    event ProposalExecuted(uint256 indexed proposalId, address indexed executor);

    // 修饰器：只有多签持有者可以调用
    modifier onlyOwner() {
        require(isOwner[msg.sender], "Not an owner");
        _;
    }

    // 修饰器：提案必须存在且未执行
    modifier proposalExists(uint256 proposalId) {
        require(proposalId < proposals.length, "Proposal does not exist");
        require(!proposals[proposalId].executed, "Proposal already executed");
        _;
    }

    // 修饰器：提案必须未被该多签持有者确认
    modifier notConfirmed(uint256 proposalId) {
        require(!confirmations[proposalId][msg.sender], "Proposal already confirmed");
        _;
    }

    constructor(address[] memory _owners) {
        require(_owners.length >= 3, "At least 3 owners required");
        
        for (uint256 i = 0; i < _owners.length; i++) {
            address owner = _owners[i];
            require(owner != address(0), "Invalid owner");
            require(!isOwner[owner], "Owner not unique");
            
            isOwner[owner] = true;
            owners.push(owner);
        }
        
        // 设置多签门槛为 2/3
        threshold = (owners.length * 2) / 3;
    }

    /**
     * @notice 提交提案
     * @param _target 目标合约地址
     * @param _value 发送的 ETH 数量
     * @param _data 调用数据
     * @return proposalId 提案ID
     */
    function propose(
        address _target,
        uint256 _value,
        bytes calldata _data
    ) external onlyOwner returns (uint256 proposalId) {
        proposalId = proposals.length;
        proposals.push(
            Proposal({
                target: _target,
                value: _value,
                data: _data,
                executed: false,
                confirmations: 0
            })
        );
        
        emit ProposalSubmitted(proposalId, msg.sender, _target, _value, _data);
    
    }

    /**
     * @notice 确认提案
     * @param proposalId 提案ID
     */
    function confirm(uint256 proposalId)
        external
        onlyOwner
        proposalExists(proposalId)
        notConfirmed(proposalId)
    {
        Proposal storage proposal = proposals[proposalId];
        proposal.confirmations += 1;
        confirmations[proposalId][msg.sender] = true;
        
        emit ProposalConfirmed(proposalId, msg.sender);
    }

    /**
     * @notice 执行提案
     * @param proposalId 提案ID
     */
    function execute(uint256 proposalId) external proposalExists(proposalId) {
        Proposal storage proposal = proposals[proposalId];
        require(proposal.confirmations >= threshold, "Not enough confirmations");
        
        proposal.executed = true;
        
        // 执行提案
        (bool success, ) = proposal.target.call{value: proposal.value}(proposal.data);
        require(success, "Transaction execution failed");
        
        emit ProposalExecuted(proposalId, msg.sender);
    }

    /**
     * @notice 获取提案数量
     * @return 提案数量
     */
    function getProposalCount() external view returns (uint256) {
        return proposals.length;
    }

    /**
     * @notice 获取多签持有者数量
     * @return 多签持有者数量
     */
    function getOwnerCount() external view returns (uint256) {
        return owners.length;
    }

    /**
     * @notice 获取提案执行状态
     * @param proposalId 提案ID
     * @return 是否已执行
     */
    function isProposalExecuted(uint256 proposalId) external view returns (bool) {
        require(proposalId < proposals.length, "Proposal does not exist");
        return proposals[proposalId].executed;
    }

    // 允许合约接收 ETH
    receive() external payable {}
} 