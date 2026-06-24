// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TokenWithSellFee is ERC20, Ownable {
    mapping(address => bool) public isPairPool;

    event PairPoolSet(address indexed pool, bool status);

    constructor(uint256 initialSupply) ERC20("TokenWithSellFee", "TWSF") Ownable(msg.sender) {
        _mint(msg.sender, initialSupply);
    }

    /**
     * @notice Set whether an address is a registered pair pool.
     * @param pool The address of the pair pool.
     * @param status True to set as pool, false to remove.
     */
    function setPairPool(address pool, bool status) external onlyOwner {
        require(pool != address(0), "Pool address cannot be zero");
        isPairPool[pool] = status;
        emit PairPoolSet(pool, status);
    }

    /**
     * @dev Override _update to implement the custom transfer hooks:
     * - Sell: If `to` is a pair pool, deduct a 1% fee and send it to this contract.
     * - Buy: If `from` is a pair pool, award a 1% bonus from this contract's balance.
     */
    function _update(
        address from,
        address to,
        uint256 value
    ) internal virtual override {
        // Minting or burning is handled standardly
        if (from == address(0) || to == address(0)) {
            super._update(from, to, value);
            return;
        }

        // Sell transaction: to is a pair pool
        if (isPairPool[to]) {
            uint256 fee = value / 100;
            uint256 netAmount = value - fee;

            // Perform transfer to pair pool
            super._update(from, to, netAmount);

            // Perform transfer of fee to this contract
            if (fee > 0) {
                super._update(from, address(this), fee);
            }
        }
        // Buy transaction: from is a pair pool
        else if (isPairPool[from]) {
            uint256 reward = value / 100;
            uint256 contractBalance = balanceOf(address(this));

            if (reward > contractBalance) {
                reward = contractBalance;
            }

            // Perform base transfer from pair pool to user
            super._update(from, to, value);

            // Transfer reward from this contract to user
            if (reward > 0) {
                super._update(address(this), to, reward);
            }
        }
        // Standard transaction
        else {
            super._update(from, to, value);
        }
    }
}
