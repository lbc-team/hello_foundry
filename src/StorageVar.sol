// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract StorageVars {
    uint x;
    uint y;
    uint z;

    function foo() public {
        y = 2;   // (SSTORE 0x01, 0x02)
        z = 3;   // (SSTORE 0x02, 0x03)
    }

    function bar() external view returns (uint) {
        return y ; // SLOAD 0x01 , MSTORE ..., RETURN
    }

}


contract StorageCompact {
    uint8 x;  // slot 0
    uint8 y;  // slot 0

    function foo() public returns (uint8) {
        uint8 sum = x + y;
        return sum;
    }


}
