// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

interface MyYulERC1155 {

    function noname() external view returns(bytes32);

    function noname2() external view returns(uint256);

    function supportsInterface(bytes4 interfaceId) external view returns(bytes4);
}

contract CallMyYulERC1155 {

    // MyYulERC1155 public target;

    // constructor(address _addr) {
    //     target = MyYulERC1155(_addr);
    // }

    function callTarget(address _addr) external view returns(bytes32) {
        return MyYulERC1155(_addr).noname();
    }

    function callTargetStr(address _addr) external view returns(uint256) {
        return MyYulERC1155(_addr).noname2();
    }

    function callSupportInterface(address _addr, bytes4 interfaceId) external view returns(bytes4) {
        return MyYulERC1155(_addr).supportsInterface(interfaceId);
    }
}
// 0x92c72839
// 000000000000000000000000f8e81d47203a594245e36c48e151709f0c19fbe8
// 1234123400000000000000000000000000000000000000000000000000000000

// 0000000000000000000000000000000000000000000000000000000012341234