// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/uniswapv2/UniswapV2Router02.sol";
import "../src/uniswapv2/UniswapV2Factory.sol";
import "../src/uniswapv2/UniswapV2Pair.sol";
import "../src/uniswapv2/libraries/UniswapV2Library.sol";

contract MockERC20 {
    string public name;
    string public symbol;
    uint8 public decimals = 18;
    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
    }

    function mint(address to, uint256 value) public {
        totalSupply += value;
        balanceOf[to] += value;
        emit Transfer(address(0), to, value);
    }

    function approve(address spender, uint256 value) public returns (bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transfer(address to, uint256 value) public returns (bool) {
        require(balanceOf[msg.sender] >= value, "ERC20: balance low");
        balanceOf[msg.sender] -= value;
        balanceOf[to] += value;
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) public returns (bool) {
        require(balanceOf[from] >= value, "ERC20: balance low");
        if (
            from != msg.sender &&
            allowance[from][msg.sender] != type(uint256).max
        ) {
            require(
                allowance[from][msg.sender] >= value,
                "ERC20: allowance low"
            );
            allowance[from][msg.sender] -= value;
        }
        balanceOf[from] -= value;
        balanceOf[to] += value;
        emit Transfer(from, to, value);
        return true;
    }

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract MockWETH {
    string public name = "Wrapped Ether";
    string public symbol = "WETH";
    uint8 public decimals = 18;

    event Approval(address indexed src, address indexed guy, uint wad);
    event Transfer(address indexed src, address indexed dst, uint wad);
    event Deposit(address indexed dst, uint wad);
    event Withdrawal(address indexed src, uint wad);

    mapping(address => uint) public balanceOf;
    mapping(address => mapping(address => uint)) public allowance;

    receive() external payable {
        deposit();
    }

    function deposit() public payable {
        balanceOf[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint wad) public {
        require(balanceOf[msg.sender] >= wad);
        balanceOf[msg.sender] -= wad;
        payable(msg.sender).transfer(wad);
        emit Withdrawal(msg.sender, wad);
    }

    function totalSupply() public view returns (uint) {
        return address(this).balance;
    }

    function approve(address guy, uint wad) public returns (bool) {
        allowance[msg.sender][guy] = wad;
        emit Approval(msg.sender, guy, wad);
        return true;
    }

    function transfer(address dst, uint wad) public returns (bool) {
        return transferFrom(msg.sender, dst, wad);
    }

    function transferFrom(
        address src,
        address dst,
        uint wad
    ) public returns (bool) {
        require(balanceOf[src] >= wad);
        if (
            src != msg.sender && allowance[src][msg.sender] != type(uint256).max
        ) {
            require(allowance[src][msg.sender] >= wad);
            allowance[src][msg.sender] -= wad;
        }
        balanceOf[src] -= wad;
        balanceOf[dst] += wad;
        emit Transfer(src, dst, wad);
        return true;
    }
}

contract UniswapV2Router02Test is Test {
    receive() external payable {}

    UniswapV2Factory public factory;
    MockWETH public weth;
    UniswapV2Router02 public router;

    MockERC20 public tokenA;
    MockERC20 public tokenB;

    function setUp() public {
        // Deploy Factory
        factory = new UniswapV2Factory(address(this));

        // Deploy WETH
        weth = new MockWETH();

        // Deploy Router
        router = new UniswapV2Router02(address(factory), address(weth));

        // Deploy Mock Tokens
        tokenA = new MockERC20("Token A", "TKA");
        tokenB = new MockERC20("Token B", "TKB");

        // Mint mock tokens to this test contract
        tokenA.mint(address(this), 10000 ether);
        tokenB.mint(address(this), 10000 ether);

        // Approve router
        tokenA.approve(address(router), type(uint256).max);
        tokenB.approve(address(router), type(uint256).max);
    }

    // Helper test to output the updated UniswapV2Pair creation code hash
    function testPrintInitCodeHash() public view {
        bytes32 hash = keccak256(type(UniswapV2Pair).creationCode);
        console.log("----------------------------------------");
        console.log("PAIRS INIT_CODE_HASH:");
        console.logBytes32(hash);
        console.log("----------------------------------------");
    }

    function testAddLiquidity() public {
        // Add liquidity: 100 TKA and 100 TKB
        uint amountADesired = 100 ether;
        uint amountBDesired = 100 ether;

        (uint amountA, uint amountB, uint liquidity) = router.addLiquidity(
            address(tokenA),
            address(tokenB),
            amountADesired,
            amountBDesired,
            1 ether,
            1 ether,
            address(this),
            block.timestamp + 1000
        );

        assertEq(amountA, amountADesired);
        assertEq(amountB, amountBDesired);
        assertTrue(liquidity > 0);

        address pairAddress = factory.getPair(address(tokenA), address(tokenB));
        assertTrue(pairAddress != address(0));

        UniswapV2Pair pair = UniswapV2Pair(pairAddress);
        assertEq(pair.balanceOf(address(this)), liquidity);
    }

    function testRemoveLiquidity() public {
        // First add liquidity
        uint amountADesired = 100 ether;
        uint amountBDesired = 100 ether;

        (, , uint liquidity) = router.addLiquidity(
            address(tokenA),
            address(tokenB),
            amountADesired,
            amountBDesired,
            1 ether,
            1 ether,
            address(this),
            block.timestamp + 1000
        );

        address pairAddress = factory.getPair(address(tokenA), address(tokenB));
        UniswapV2Pair pair = UniswapV2Pair(pairAddress);

        // Approve LP tokens to router for withdrawal
        pair.approve(address(router), type(uint256).max);

        // Remove liquidity
        (uint amountA, uint amountB) = router.removeLiquidity(
            address(tokenA),
            address(tokenB),
            liquidity,
            1 ether,
            1 ether,
            address(this),
            block.timestamp + 1000
        );

        assertTrue(amountA > 0);
        assertTrue(amountB > 0);
    }

    function testSwapExactTokensForTokens() public {
        // Add initial liquidity
        router.addLiquidity(
            address(tokenA),
            address(tokenB),
            100 ether,
            100 ether,
            1 ether,
            1 ether,
            address(this),
            block.timestamp + 1000
        );

        // Swap 10 TKA for TKB
        uint amountIn = 10 ether;
        address[] memory path = new address[](2);
        path[0] = address(tokenA);
        path[1] = address(tokenB);

        uint balanceBefore = tokenB.balanceOf(address(this));

        router.swapExactTokensForTokens(
            amountIn,
            1 ether,
            path,
            address(this),
            block.timestamp + 1000
        );

        uint balanceAfter = tokenB.balanceOf(address(this));
        assertTrue(balanceAfter > balanceBefore);
    }

    function testAddLiquidityETH() public {
        uint amountTokenDesired = 100 ether;

        (uint amountToken, uint amountETH, uint liquidity) = router
            .addLiquidityETH{value: 10 ether}(
            address(tokenA),
            amountTokenDesired,
            1 ether,
            1 ether,
            address(this),
            block.timestamp + 1000
        );

        assertTrue(amountToken > 0);
        assertTrue(amountETH > 0);
        assertTrue(liquidity > 0);
    }

    function testSwapExactETHForTokens() public {
        // Add initial liquidity tokenA-WETH
        router.addLiquidityETH{value: 10 ether}(
            address(tokenA),
            100 ether,
            1 ether,
            1 ether,
            address(this),
            block.timestamp + 1000
        );

        // Swap 1 ETH for TKA
        address[] memory path = new address[](2);
        path[0] = address(weth);
        path[1] = address(tokenA);

        uint balanceBefore = tokenA.balanceOf(address(this));

        router.swapExactETHForTokens{value: 1 ether}(
            1 ether,
            path,
            address(this),
            block.timestamp + 1000
        );

        uint balanceAfter = tokenA.balanceOf(address(this));
        assertTrue(balanceAfter > balanceBefore);
    }

    function testSwapExactTokensForETH() public {
        // Add initial liquidity tokenA-WETH
        router.addLiquidityETH{value: 10 ether}(
            address(tokenA),
            100 ether,
            1 ether,
            1 ether,
            address(this),
            block.timestamp + 1000
        );

        // Swap 10 TKA for ETH
        address[] memory path = new address[](2);
        path[0] = address(tokenA);
        path[1] = address(weth);

        uint balanceBefore = address(this).balance;

        router.swapExactTokensForETH(
            10 ether,
            0.1 ether,
            path,
            address(this),
            block.timestamp + 1000
        );

        uint balanceAfter = address(this).balance;
        assertTrue(balanceAfter > balanceBefore);
    }
}
