// SPDX-License-Identifier: BSD
pragma solidity ^0.8.0;

import {Clone} from "./clone.sol";

contract ExampleClone is Clone {
    function param1() public pure returns (address) {
        return _getArgAddress(0);
    }

    function param2() public pure returns (uint256) {
        return _getArgUint256(20);
    }

    function param3() public pure returns (uint64) {
        return _getArgUint64(52);
    }

    function param4() public pure returns (uint8) {
        return _getArgUint8(60);
    }
}

// 0x02d9151800000000000000000000000000000000000000000000000000000000