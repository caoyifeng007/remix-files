// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

interface MyYulERC1155 {

    function noname() external view returns(bytes32);

    function noname2() external view returns(uint256);

    function supportsInterface(bytes4 interfaceId) external view returns(bool);

    function uri(uint256 id) external view returns(string memory);
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

    function callSupportInterface(address _addr, bytes4 interfaceId) external view returns(bool) {
        return MyYulERC1155(_addr).supportsInterface(interfaceId);
    }

    function callUri(address _addr, uint256 id) external view returns(string memory) {
        return MyYulERC1155(_addr).uri(id);
    }
}