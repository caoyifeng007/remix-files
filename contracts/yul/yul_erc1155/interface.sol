// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

// import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";

contract ReceiverTest {
    bytes public receivedData;

    uint256[] public receivedIds;

    address public receivedOperator;

    address public receivedFrom;

    uint256[] public receivedValues;

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

    event Log(bytes4 indexed selector);

    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4) {
        receivedOperator = operator;
        receivedFrom = from;
        receivedIds = ids;
        receivedValues = values;
        receivedData = data;

        return this.onERC1155BatchReceived.selector;
    }
}

interface MyYulERC1155 {

    function noname() external view returns(bytes32);

    function supportsInterface(bytes4 interfaceId) external view returns(bool);

    function uri(uint256 id) external view returns(string memory);

    function setURI(string memory newuri) external;

    function balanceOf(address account, uint256 id) external view returns(uint256);

    function balanceOfBatch(address[] memory accounts,uint256[] memory ids) external view returns(uint256[] memory);

    function setApprovalForAll(address operator, bool approved) external;

    function isApprovedForAll(address account, address operator) external view returns(bool);

    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes memory data) external;

    function safeBatchTransferFrom(address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) external;

    function mint(address to, uint256 id, uint256 amount, bytes memory data) external;

    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) external;

    function burn(address from, uint256 id,uint256 amount) external;

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

    function callSetURI(address _addr, string memory newuri) external {
        return MyYulERC1155(_addr).setURI(newuri);
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

    function callSafeBatchTransferFrom(address _addr, address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) external {
        return MyYulERC1155(_addr).safeBatchTransferFrom(from, to, ids, amounts, data);
    }

    function callMint(address _addr, address to, uint256 id, uint256 amount, bytes memory data) external {
        return MyYulERC1155(_addr).mint(to, id, amount, data);
    }

    function callMintBatch(address _addr, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) external {
        return MyYulERC1155(_addr).mintBatch(to, ids, amounts, data);
    }

    function callBurn(address _addr, address from, uint256 id,uint256 amount) external {
        return MyYulERC1155(_addr).burn(from, id, amount);
    }



}

