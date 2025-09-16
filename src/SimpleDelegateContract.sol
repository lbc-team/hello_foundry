// SPDX-License-Identifier: MIT
// code from : https://book.getfoundry.sh/reference/cheatcodes/sign-delegation#signature

pragma solidity ^0.8.17;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { TokenBank } from "../src/TokenBank.sol";

contract SimpleDelegateContract {
    event Executed(address indexed to, uint256 value, bytes data);
 
    struct Call {
        bytes data;
        address to;
        uint256 value;
    }

    // ERC20 Approve 
    // TokenBank Deposit
    function execute(Call[] memory calls) external payable {
        for (uint256 i = 0; i < calls.length; i++) {
            Call memory op = calls[i];
            (bool success, bytes memory result) = op.to.call{value: op.value}(op.data);
            require(success, string(result));
            emit Executed(op.to, op.value, op.data);
        }
    }

    receive() external payable {}


    event Log(string message);

    function initialize() external payable {
        emit Log('Hello, world!');
    }
    
    function ping() external {
        emit Log('Pong!');
    }

    function approveAndDeposit(address token, address tokenbank, uint256 amount) external {
        IERC20(token).approve(tokenbank, amount);
        TokenBank(tokenbank).deposit(amount);
    }
}
 
contract MockERC20 {
    address public minter;
    mapping(address => uint256) private _balances;
 
    constructor(address _minter) {
        minter = _minter;
    }
 
    function mint(uint256 amount, address to) public {
        _mint(to, amount);
    }
 
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }
 
    function _mint(address account, uint256 amount) internal {
        require(msg.sender == minter, "ERC20: msg.sender is not minter");
        require(account != address(0), "ERC20: mint to the zero address");
        unchecked {
            _balances[account] += amount;
        }
    }
}