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
    uint256 public x;
    
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
        // "hello B"
        return super.sayHi();
    }

    function setX() external {
        x = 1;
    }
}

contract D {
    function sayHi() public pure virtual returns(string memory) {
        return "hello D";
    }
}
contract E is D {
    function sayHi() public pure virtual override(D) returns(string memory) {
        return "hello E";
    }
}

contract F is D {
    function sayHi() public pure virtual override(D) returns(string memory) {
        // 由于c3 linearization的关系,会返回"hello E",并不是"hello D"
        return super.sayHi();
    }
}

contract G is E,F {
    function sayHi() public pure override(E,F) returns(string memory) {
        return super.sayHi();
    }
}

contract Base1 {
    constructor() {}
}

contract Base2 {
    constructor() {}
}

// Constructors are executed in the following order:
//  1 - Base1
//  2 - Base2
//  3 - Derived1
contract Derived1 is Base1, Base2 {
    constructor() Base1() Base2() {}
}

// Constructors are executed in the following order:
//  1 - Base2
//  2 - Base1
//  3 - Derived2
contract Derived2 is Base2, Base1 {
    constructor() Base2() Base1() {}
}

// Constructors are still executed in the following order:
//  1 - Base2
//  2 - Base1
//  3 - Derived3
contract Derived3 is Base2, Base1 {
    constructor() Base1() Base2() {}
}
