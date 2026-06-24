// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

import "forge-std/Test.sol";
import "../src/TokenWithSellFee.sol";

contract TokenWithSellFeeTest is Test {
    TokenWithSellFee public token;
    address public owner = address(10);
    address public user1 = address(11);
    address public user2 = address(12);
    address public pool = address(20);

    function setUp() public {
        vm.prank(owner);
        token = new TokenWithSellFee(1_000_000 * 10**18);
    }

    function test_Initialization() public view {
        assertEq(token.name(), "TokenWithSellFee");
        assertEq(token.symbol(), "TWSF");
        assertEq(token.owner(), owner);
        assertEq(token.balanceOf(owner), 1_000_000 * 10**18);
    }

    function test_SetPairPool() public {
        // Only owner can set pair pool
        vm.prank(owner);
        token.setPairPool(pool, true);
        assertTrue(token.isPairPool(pool));

        vm.prank(owner);
        token.setPairPool(pool, false);
        assertFalse(token.isPairPool(pool));

        // Non-owner trying to set pair pool should revert
        vm.prank(user1);
        vm.expectRevert();
        token.setPairPool(pool, true);
    }

    function test_StandardTransfer() public {
        // Give user1 some tokens
        vm.prank(owner);
        token.transfer(user1, 1000 * 10**18);

        // Standard transfer user1 -> user2
        vm.prank(user1);
        token.transfer(user2, 100 * 10**18);

        // Standard transfers should not charge a fee or distribute rewards
        assertEq(token.balanceOf(user1), 900 * 10**18);
        assertEq(token.balanceOf(user2), 100 * 10**18);
        assertEq(token.balanceOf(address(token)), 0);
    }

    function test_SellFee() public {
        // Register pool
        vm.prank(owner);
        token.setPairPool(pool, true);

        // Give user1 some tokens
        vm.prank(owner);
        token.transfer(user1, 1000 * 10**18);

        // User1 sells 100 tokens to the pool
        vm.prank(user1);
        token.transfer(pool, 100 * 10**18);

        // 1% of 100 is 1. Pool should get 99, Contract should get 1.
        assertEq(token.balanceOf(pool), 99 * 10**18);
        assertEq(token.balanceOf(address(token)), 1 * 10**18);
        assertEq(token.balanceOf(user1), 900 * 10**18);
    }

    function test_BuyReward() public {
        // Give pool some tokens first
        vm.prank(owner);
        token.transfer(pool, 1000 * 10**18);

        // Send 10 tokens directly to contract to fund rewards
        vm.prank(owner);
        token.transfer(address(token), 10 * 10**18);

        // Register pool
        vm.prank(owner);
        token.setPairPool(pool, true);

        // User1 buys 100 tokens from the pool
        vm.prank(pool);
        token.transfer(user1, 100 * 10**18);

        // User1 receives 100 from pool, plus 1% (1 token) reward from contract
        assertEq(token.balanceOf(user1), 101 * 10**18);
        // Contract balance decreases from 10 to 9
        assertEq(token.balanceOf(address(token)), 9 * 10**18);
        // Pool balance decreases by 100
        assertEq(token.balanceOf(pool), 900 * 10**18);
    }

    function test_BuyRewardCapping() public {
        // Give pool some tokens first
        vm.prank(owner);
        token.transfer(pool, 1000 * 10**18);

        // Send exactly 0.5 tokens directly to contract to fund rewards
        vm.prank(owner);
        token.transfer(address(token), 0.5 * 10**18);

        // Register pool
        vm.prank(owner);
        token.setPairPool(pool, true);

        // User1 buys 100 tokens from the pool. 1% reward would be 1 token, but contract only has 0.5.
        vm.prank(pool);
        token.transfer(user1, 100 * 10**18);

        // User1 should receive 100 from pool, plus the capped 0.5 reward from contract
        assertEq(token.balanceOf(user1), 100.5 * 10**18);
        // Contract balance decreases to 0
        assertEq(token.balanceOf(address(token)), 0);
    }
}
