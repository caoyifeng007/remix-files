// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

interface MyYulERC1155 {

    function noname() external view returns(bytes32);
}

contract CallMyYulERC1155 {

    // MyYulERC1155 public target;

    // constructor(address _addr) {
    //     target = MyYulERC1155(_addr);
    // }

    function callTarget(address _addr) external view returns(bytes32) {
        return MyYulERC1155(_addr).noname();
    }
}