// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// a library for performing overflow-safe math, courtesy of DappHub (https://github.com/dapphub/ds-math)
library SafeMath {
    function add(uint x, uint y) internal pure returns (uint z) {
        z = x + y;
    }

    function sub(uint x, uint y) internal pure returns (uint z) {
        z = x - y;
    }

    function mul(uint x, uint y) internal pure returns (uint z) {
        z = x * y;
    }
}
