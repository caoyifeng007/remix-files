// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

// import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";

contract ReceiverTest {
    bytes public receivedData;

    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4) {
        receivedData = data;
        return this.onERC1155Received.selector;
        // return bytes4(data);
    }

    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4) {}
}

interface MyYulERC1155 {

    function noname() external view returns(bytes32);

    function supportsInterface(bytes4 interfaceId) external view returns(bool);

    function uri(uint256 id) external view returns(string memory);

    function balanceOf(address account, uint256 id) external view returns(uint256);

    function balanceOfBatch(address[] memory accounts,uint256[] memory ids) external view returns(uint256[] memory);

    function setApprovalForAll(address operator, bool approved) external;

    function isApprovedForAll(address account, address operator) external view returns(bool);

    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes memory data) external;

}

contract CallMyYulERC1155 {

    // MyYulERC1155 public target;

    // constructor(address _addr) {
    //     target = MyYulERC1155(_addr);
    // }

    function callTarget(address _addr) external view returns(bytes32) {
        return MyYulERC1155(_addr).noname();
    }

    function callSupportInterface(address _addr, bytes4 interfaceId) external view returns(bool) {
        return MyYulERC1155(_addr).supportsInterface(interfaceId);
    }

    function callUri(address _addr, uint256 id) external view returns(string memory) {
        return MyYulERC1155(_addr).uri(id);
    }
    
    function callBalanceOf(address _addr, address account, uint256 id) external view returns(uint256) {
        return MyYulERC1155(_addr).balanceOf(account, id);
    }

    function callBalanceOfBatch(address _addr, address[] memory accounts,uint256[] memory ids) external view returns(uint256[] memory) {
        return MyYulERC1155(_addr).balanceOfBatch(accounts, ids);
    }

    function callSetApprovalForAll(address _addr, address operator, bool approved) external {
        return MyYulERC1155(_addr).setApprovalForAll(operator, approved);
    }

    function callIsApprovedForAll(address _addr, address account, address operator) external view returns(bool) {
        return MyYulERC1155(_addr).isApprovedForAll(account, operator);
    }

    function callSafeTransferFrom(address _addr, address from, address to, uint256 id, uint256 amount, bytes memory data) external {
        return MyYulERC1155(_addr).safeTransferFrom(from, to, id, amount, data);
    }

}