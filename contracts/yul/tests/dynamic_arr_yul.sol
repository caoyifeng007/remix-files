// SPDX-License-Identifier: BSD
pragma solidity ^0.8.0;


contract DynamicArrAssign {

    event Debug(bytes32, bytes32, bytes32, bytes32, bytes32);

    function args(uint256[] memory arr1, uint256[] memory arr) external {
        bytes32 location;
        bytes32 len;
        bytes32 valueAtIndex0;
        bytes32 valueAtIndex1;
        bytes32 valueAtIndex2;
        // uint256 x = arr;   // line1
        assembly {
            location := arr   // line2
            len := mload(arr)
            valueAtIndex0 := mload(add(location, 0x20))
            valueAtIndex1 := mload(add(location, 0x40))
            valueAtIndex2 := mload(add(location, 0x60))
            // ...
        }
        emit Debug(location, len, valueAtIndex0, valueAtIndex1, valueAtIndex2);
    }

}







