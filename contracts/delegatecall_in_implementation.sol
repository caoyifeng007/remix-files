// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/proxy/Proxy.sol";

import "hardhat/console.sol";

contract TestContract {
    uint public num = 0;
    event callMeMaybeEvent(address sender, address _from);

    function callMeMaybe() payable public {
        num = num + 1;
        emit callMeMaybeEvent(msg.sender, address(this));
    }
}

contract CallsTestContract is Proxy {
    uint public num;
    address public impl;
    
    function set(address _addr) public {
        impl = _addr;
    }
    
    function _implementation() internal view override returns (address){
        return impl;
    }

    // impl num+1,  msg.sender = proxy address,  address(this) = impl address
    function t1() external {
        impl.call(abi.encodeWithSignature("callMeMaybe()"));
    }

    // prxoy num+1,  msg.sender = EOA,  address(this) = prxoy address
    function t2() external {
        impl.delegatecall(abi.encodeWithSignature("callMeMaybe()"));
    }

    // prxoy num+1,  msg.sender = proxy address,  address(this) = proxy address
    function t3() external {
        address(this).call(abi.encodeWithSignature("callMeMaybe()"));
    }

    // proxy num+1,  msg.sender = EOA,  address(this) = proxy address
    function t4() external {
        address(this).delegatecall(abi.encodeWithSignature("callMeMaybe()"));
    }
}