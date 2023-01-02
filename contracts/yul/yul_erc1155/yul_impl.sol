// SPDX-License-Identifier: GPL-3.0

object "MyYulERC1155" {

    // constructor
    code {
        /* -------- storage layout ---------- */
        function ownerPos() -> p { p := 0 }
        function uriLengthPos() -> p { p := 1 }
        function uriPos() -> p {
            mstore(0x00, uriLengthPos())
            p := keccak256(0x00, 0x20)
        }

        // Store the owner in slot 0.
        sstore(ownerPos(), caller())

        // Store the (length * 2 + 1) in slot 1.
        sstore(uriLengthPos(), 0x4f)

        // Store the actual string bytes in slot keccak256(1)
        // abi.encodePacked("https://game.example/api/item/{id}.json")
        sstore(uriPos(), 0x68747470733a2f2f67616d652e6578616d706c652f6170692f6974656d2f7b69)
        sstore(add(uriPos(), 1), 0x647d2e6a736f6e00000000000000000000000000000000000000000000000000)

        datacopy(0, dataoffset("runtime"), datasize("runtime"))
        return(0, datasize("runtime"))
    }

    object "runtime" {

        code {
            // Protection against sending Ether
            require(iszero(callvalue()))

            // Dispatcher
            switch selector()
            case 0x01ffc9a7 /* "supportsInterface(bytes4)" */ {
                returnUint(supportsInterface(decodeAsBytes4(0)))
            }
            case 0x0e89341c /* "uri(uint256)" */  {
                uri(decodeAsUint(0))
            }
            default {
                revert(0, 0)
            }

            function supportsInterface(interfaceId) -> b {
                let IERC165id := 0x01ffc9a7
                let IERC1155id := 0xd9b67a26
                let IERC1155MetadataURIid := 0x0e89341c
                b := or(eq(interfaceId, IERC165id), or(eq(interfaceId, IERC1155id), eq(interfaceId, IERC1155MetadataURIid)))
            }

            /* ---------- calldata decoding functions ----------- */
            function selector() -> s {
                // 0x10...00 -> 1 x 10^28
                // calldataload will load 32 bytes, so the first 4 bytes will be left
                s := div(calldataload(0), 0x100000000000000000000000000000000000000000000000000000000)
            }
            function decodeAsBytes4(offset) -> v { 
                v := decodeAsUint(offset)
                if and(v, 0x00000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffff) {
                    revert(0, 0)
                }
                v := div(v, 0x100000000000000000000000000000000000000000000000000000000)
            }
            function decodeAsAddress(offset) -> v {
                v := decodeAsUint(offset)
                if iszero(iszero(and(v, not(0xffffffffffffffffffffffffffffffffffffffff)))) {
                    revert(0, 0)
                }
            }
            function decodeAsUint(offset) -> v {
                let pos := add(4, mul(offset, 0x20))
                if lt(calldatasize(), add(pos, 0x20)) {
                    revert(0, 0)
                }
                v := calldataload(pos)
            }

            /* ---------- calldata encoding functions ---------- */
            function returnUint(v) {
                mstore(0, v)
                return(0, 0x20)
            }
            function returnTrue() {
                returnUint(1)
            }

            /* -------- storage layout ---------- */
            function ownerPos() -> p { p := 0 }
            function uriLengthPos() -> p { p := 1 }
            function uriPos() -> p {
                mstore(0x00, uriLengthPos())
                p := keccak256(0x00, 0x20)
            }

            /* -------- storage access ---------- */
            function owner() -> o {
                o := sload(ownerPos())
            }
            function uri(id) {
                let fptr := mload(0x40)
                let optr := fptr
                let uriLen := sload(uriLengthPos())
                uriLen := div(sub(uriLen, 1), 2)

                let loops := div(uriLen, 0x20)
                if mod(uriLen, 0x20) {
                    loops := add(loops, 1)
                }
                
                let uriLocation := uriPos()

                // construct return string
                // step1 point to where the string starts in the return string not in memory
                mstore(fptr, 0x20)
                fptr := add(fptr, 0x20)
                // step2 store string length
                mstore(fptr, uriLen)
                fptr := add(fptr, 0x20)
                // step3 store the actual string
                for {let i := 0} lt(i, loops) {i := add(i, 1)} {
                    let v := sload(add(uriLocation, i))
                    mstore(fptr, v)
                    fptr := add(fptr, 0x20)
                }
                
                return(optr, add(mul(loops, 0x20), 0x40))
            }

            /* ---------- utility functions ---------- */
            function require(condition) {
                if iszero(condition) { revert(0, 0) }
            }


            mstore(0x00, 0x123)
            return(0, 0x40)

        }

    }

}