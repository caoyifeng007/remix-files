// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract Test {
    string public str = "https://game.example/api/item/{id}.json";

    function getStr() external view returns(string memory) {
        return str;
    }

    function getStrSlot() external pure returns(uint256) {
        uint256 slot;

        assembly {
            slot := str.slot
        }

        return slot;
    }

    function getSlotValue() external view returns(uint256) {
        // 79 -> 0x4f
        uint256 value;

        assembly {
            value := sload(str.slot)
        }

        return value;
    }

    function getStrYul() external view returns(bytes32 ret) {
        bytes32 location = keccak256(abi.encode(0));

        assembly {
            ret := sload(location)
        }
    }
}