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

        mstore(0x00, add(7, 0x100))
        mstore(0x20, 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4)
        let lc := keccak256(0x00, 0x40)
        sstore(lc, 0x666)

        datacopy(0, dataoffset("runtime"), datasize("runtime"))
        return(0, datasize("runtime"))
    }
// 0x3a33770a
// 000000000000000000000000bee7ddd295b11b421c849ba060941bd1e17e0435

// 0000000000000000000000000000000000000000000000000000000000000040 00
// 00000000000000000000000000000000000000000000000000000000000000a0 20
// 0000000000000000000000000000000000000000000000000000000000000002 40
// 0000000000000000000000005b38da6a701c568545dcfcb03fcb875f56beddc4 60
// 0000000000000000000000005b38da6a701c568545dcfcb03fcb875f56beddc4 80
// 0000000000000000000000000000000000000000000000000000000000000002 a0
// 0000000000000000000000000000000000000000000000000000000000000001 c0
// 0000000000000000000000000000000000000000000000000000000000000002 e0
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
            case 0x00fdd58e /* "balanceOf(address,uint256)" */  {
                returnUint(balanceOf(decodeAsAddress(0), decodeAsUint(1)))
            }
            case 0x4e1273f4 /* "balanceOfBatch(address[],uint256[])" */  {
                
                balanceOfBatch(decodeAsUint(0), decodeAsUint(1))

                // let fptr := mload(0x40)
                // let optr := fptr

                // mstore(fptr, 0x20)
                // fptr := add(fptr, 0x20)
                // mstore(fptr, 2)
                // fptr := add(fptr, 0x20)
                // mstore(fptr, 123)
                // fptr := add(fptr, 0x20)
                // mstore(fptr, 333)
                // fptr := add(fptr, 0x20)
                
                // return(optr, sub(fptr, optr))
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
                // 0x10...00 -> 1 * 10^28
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
            function balancesPos(acc, id) -> p {
                mstore(0x00, add(id, 0x100))
                mstore(0x20, acc)
                p := keccak256(0x00, 0x40)
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
            function balanceOf(acc, id) -> b {
                revertIfZeroAddress(acc)
                let balancesLocation := balancesPos(acc, id)
                b := sload(balancesLocation)
            }
            function balanceOfBatch(accArrPtr, idArrPtr)  {
                // for example, idArrPtr's value is 0x40 then the length of accArr will be the 3rd slot in calldata
                // it should be pass 2 to decodeAsUint() get that length
                let accArrOffset := div(accArrPtr, 0x20)
                let idArrOffset := div(idArrPtr, 0x20)

                let accArrLen := decodeAsUint(accArrOffset)
                let idArrLen := decodeAsUint(idArrOffset)

                require(eq(accArrLen, idArrLen))

                let fptr := mload(0x40)
                let optr := fptr

                // like return string, return dynamic array needs three steps
                // step1 store ptr of actual data
                mstore(fptr, 0x20)
                fptr := add(fptr, 0x20)
                // step2 store array length
                mstore(fptr, accArrLen)
                fptr := add(fptr, 0x20)
                // step3 store actual data
                for {let i := 0} lt(i, accArrLen) {i := add(i, 1)} {
                    let addr := decodeAsAddress(add(add(accArrOffset, 1), i))
                    let id := decodeAsUint(add(add(idArrOffset, 1), i))

                    let b := balanceOf(addr, id)
                    mstore(fptr, b)
                    fptr := add(fptr, 0x20)
                }


                // return(optr, add(mul(accArrLen, 0x20), 0x40))
                return(optr, sub(fptr, optr))
            }

            /* ---------- utility functions ---------- */
            function revertIfZeroAddress(addr) {
                require(addr)
            }
            function require(condition) {
                if iszero(condition) { revert(0, 0) }
            }


            // mstore(0x00, 0x123)
            // return(0, 0x40)

        }

    }

}