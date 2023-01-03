// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/IERC1155MetadataURI.sol";

contract Test {
    string public str;

    constructor() {
        str = "https://game.example/api/item/{id}.json";
    }

    function getInterfaceIdIERC165() external pure returns(bytes4) {
        return type(IERC165).interfaceId;
    }

    function getInterfaceIdIERC1155() external pure returns(bytes4) {
        return type(IERC1155).interfaceId;
    }

    function getInterfaceIdIERC1155MetadataURI() external pure returns(bytes4) {
        return type(IERC1155MetadataURI).interfaceId;
    }

    function getStr() external view returns(string memory) {
        return str;
    }

    function getStrBytes() external pure returns(bytes memory ret) {
        // 0x68747470733a2f2f67616d652e6578616d706c652f6170692f6974656d2f7b69647d2e6a736f6e
        // ret = abi.encodePacked("https://game.example/api/item/{id}.json");

        // abi.encode() output
        // 0x0000000000000000000000000000000000000000000000000000000000000020
        //   0000000000000000000000000000000000000000000000000000000000000027
        //   68747470733a2f2f67616d652e6578616d706c652f6170692f6974656d2f7b69
        //   647d2e6a736f6e00000000000000000000000000000000000000000000000000

        // 68747470733a2f2f67616d652e6578616d706c652f6170692f6974656d2f7b69647d2e6a736f6e
        // abi.encodePacked() output
        ret = abi.encodePacked("https://game.example/api/item/{id}.json");
    }

    function getStrBytes2() external pure returns(bytes memory ret) {

        // 0x0000000000000000000000000000000000000000000000000000000000000123
        //   0000000000000000000000000000000000000000000000000000000000000040
        //   0000000000000000000000000000000000000000000000000000000000000027
        //   68747470733a2f2f67616d652e6578616d706c652f6170692f6974656d2f7b69
        //   647d2e6a736f6e00000000000000000000000000000000000000000000000000
        ret = abi.encode(0x123, "https://game.example/api/item/{id}.json");
    }

    // head(2) = head(1) + head(2) + head(3)
    // head(3) = head(1) + head(2) + head(3) + tail(2)
    function getStrBytes3() external pure returns(bytes memory ret) {

        // 0x0000000000000000000000000000000000000000000000000000000000000123
        //   0000000000000000000000000000000000000000000000000000000000000060
        //   00000000000000000000000000000000000000000000000000000000000000a0
        //   0000000000000000000000000000000000000000000000000000000000000003
        //   6162630000000000000000000000000000000000000000000000000000000000
        //   0000000000000000000000000000000000000000000000000000000000000003
        //   6465660000000000000000000000000000000000000000000000000000000000
        ret = abi.encode(0x123, "abc", "def");
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

    function util(string memory _arg) external pure returns(bytes4) {
        return bytes4(keccak256(abi.encodePacked(_arg)));
    }

    // "01ffc9a7": "supportsInterface(bytes4)"
    function supportsInterface(bytes4 interfaceId) external pure returns (bytes4) {
        return interfaceId;
    }

    function util2(address arg1, address arg2) external pure returns(bytes32) {
        return keccak256(abi.encode(arg1, arg2));
    }

    // ApprovalForAll(address,address,bool)
    function util3(string memory _str) external pure returns(bytes32) {
        return keccak256(abi.encodePacked(_str));
    }

    event SomeLog(uint256 indexed a, uint256 indexed b);

    function emitLog() external {
        emit SomeLog(5, 6);
    }
}