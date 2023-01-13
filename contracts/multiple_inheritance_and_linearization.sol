// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

// contract X {
//     function sayHi() public pure virtual returns(string memory) {
//         return "hello X";
//     }
// }
// contract A is X {
//     function sayHi() public pure virtual override returns(string memory) {
//         return "hello A";
//     }
// }
// // This will not compile
// // contract C is A, X {}

// contract C is X, A {
//     function sayHi() public pure override(A, X) returns(string memory) {
//         return super.sayHi();
//     }
// }

contract A {
    function sayHi() public pure virtual returns(string memory) {
        return "hello A";
    }
}
contract B {
    function sayHi() public pure virtual returns(string memory) {
        return "hello B";
    }
}

contract C is A, B {
    function sayHi() public pure override(A, B) returns(string memory) {
        return super.sayHi();
    }
}