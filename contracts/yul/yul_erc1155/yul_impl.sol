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

        /* ---------- hardcoded for tests ----------- */
        // balances[7][address of CallMyYulERC1155] = 0x6661
        mstore(0x00, add(7, 0x100))
        mstore(0x20, 0xd8b934580fcE35a11B58C6D73aDeE468a2833fa8)
        let lc := keccak256(0x00, 0x40)
        sstore(lc, 100)

        mstore(0x00, add(8, 0x100))
        mstore(0x20, 0xd8b934580fcE35a11B58C6D73aDeE468a2833fa8)
        lc := keccak256(0x00, 0x40)
        sstore(lc, 200)
        /* ---------- hard coded for tests ----------- */

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
            case 0x0e89341c /* "uri(uint256)" */ {
                uri(decodeAsUint(0))
            }
            case 0x00fdd58e /* "balanceOf(address,uint256)" */ {
                returnUint(balanceOf(decodeAsAddress(0), decodeAsUint(1)))
            }
            case 0x4e1273f4 /* "balanceOfBatch(address[],uint256[])" */ {
                balanceOfBatch(add(decodeAsUint(0), 4), add(decodeAsUint(1), 4))
            }
            case 0xa22cb465 /* "setApprovalForAll(address,bool)" */ {
                setApprovalForAll(decodeAsAddress(0), decodeAsUint(1))
            }
            case 0xe985e9c5 /* "isApprovedForAll(address,address)" */ {
                returnUint(isApprovedForAll(decodeAsAddress(0), decodeAsAddress(1)))
            }
            case 0xf242432a /* "safeTransferFrom(address,address,uint256,uint256,bytes)" */ {
                safeTransferFrom(decodeAsAddress(0), decodeAsAddress(1), decodeAsUint(2), decodeAsUint(3), add(decodeAsUint(4), 4))
            }
            case 0x2eb2c2d6 /* "safeBatchTransferFrom(address,address,uint256[],uint256[],bytes)" */ {
                safeBatchTransferFrom(decodeAsAddress(0), decodeAsAddress(1), add(decodeAsUint(2), 4), add(decodeAsUint(3), 4), add(decodeAsUint(4), 4))
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

            /* -------- events ---------- */
            function emitApprovalForAll(account, operator, approved) {
                // keccak256("ApprovalForAll(address,address,bool)")
                let signature := 0x17307eab39ab6107e8899845ad3d59bd9653f200f220920489ca2b5937696c31
                mstore(0x00, approved)
                log3(0x00, 0x20, signature, account, operator)
            }
            function emitTransferSingle(operator, from, to, id, amount) {
                // keccak256("TransferSingle(address,address,address,uint256,uint256)")
                let signature := 0xc3d58168c5ae7397731d063d5bbf3d657854427343f4c083240f7aacaa2d0f62
                mstore(0x00, id)
                mstore(0x20, amount)
                log4(0x00, 0x40, signature, caller(), from, to)
            }
            function emitTransferBatch(operator, from, to, idArrPtr, amountArrPtr) {
                // keccak256("TransferBatch(address,address,address,uint256[],uint256[])")
                let signature := 0x4a39dc06d4c0dbc64b70af90fd698a233a518aa5d07e595d983b8c0526c8f7fb
                
                let fptr := 0x80

                let idArrTotalBytes, amountArrTotalBytes
                idArrTotalBytes := getU256ArrTotalBytesNum(idArrPtr)
                amountArrTotalBytes := getU256ArrTotalBytesNum(amountArrPtr)

                // construct ids array pointer
                mstore(fptr, 0x40)
                fptr := add(fptr, 0x20)

                // construct amounts array pointer
                mstore(fptr, add(0x40, idArrTotalBytes))
                fptr := add(fptr, 0x20)


                fptr := copyU256ArrToMem(fptr, idArrPtr)
                
                fptr := copyU256ArrToMem(fptr, amountArrPtr)

                log4(0x80, sub(fptr, 0x80), signature, caller(), from, to)
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
            function balancesPos(id, account) -> p {
                mstore(0x00, add(id, 0x100))
                mstore(0x20, account)
                p := keccak256(0x00, 0x40)
            }
            function operatorApprovalsPos(account, operator) -> p {
                mstore(0x00, add(account, 0x200))
                mstore(0x20, operator)
                p := keccak256(0x00, 0x40)
            }

            /* -------- storage access ---------- */
            function owner() -> o {
                o := sload(ownerPos())
            }
            function uri(id) {
                let fptr := 0x80
                let optr := fptr
                let uriLen := sload(uriLengthPos())
                uriLen := div(sub(uriLen, 1), 2)

                let loops := div(uriLen, 0x20)
                if mod(uriLen, 0x20) {
                    loops := add(loops, 1)
                }

                // construct return string
                // step1 point to where the string starts in the return string not in memory
                mstore(fptr, 0x20)
                fptr := add(fptr, 0x20)
                // step2 store string length
                mstore(fptr, uriLen)
                fptr := add(fptr, 0x20)
                // step3 store the actual string
                for {let i := 0} lt(i, loops) {i := add(i, 1)} {
                    let v := sload(add(uriPos(), i))
                    mstore(fptr, v)
                    fptr := add(fptr, 0x20)
                }
                
                return(optr, add(mul(loops, 0x20), 0x40))
            }
            function balanceOf(account, id) -> b {
                revertIfZeroAddress(account)
                let balancesLocation := balancesPos(id, account)
                b := sload(balancesLocation)
            }
            function balanceOfBatch(accArrPtr, idArrPtr)  {

                let accArrLen, firstAccrPtr := getArrLenAndFirstItemPtr(accArrPtr)
                let idArrLen, firstIdPtr := getArrLenAndFirstItemPtr(idArrPtr)

                require(eq(accArrLen, idArrLen))

                let fptr := 0x80
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
                    let addr := calldataload(firstAccrPtr)
                    let id := calldataload(firstIdPtr)

                    let b := balanceOf(addr, id)

                    mstore(fptr, b)
                    fptr := add(fptr, 0x20)

                    firstAccrPtr := add(firstAccrPtr, 0x20)
                    firstIdPtr := add(firstIdPtr, 0x20)
                }

                return(optr, sub(fptr, optr))
            }
            function setApprovalForAll(operator, approved) {
                require(iszero(eq(caller(), operator)))
                sstore(operatorApprovalsPos(caller(), operator), approved)
                
                emitApprovalForAll(caller(), operator, approved)
            }
            function isApprovedForAll(account, operator) -> b {
                b := sload(operatorApprovalsPos(account, operator))
            }
            function doSafeTransferAcceptanceCheck(operator, from, to, id, amount, dataArrPtr) {

                if extcodesize(to) {
                    let fptr := 0x80
                    let optr := fptr
                    
                    // keccak256("onERC1155Received(address,address,uint256,uint256,bytes)")
                    let signature := 0xf23a6e61
                    mstore(fptr, signature)
                    fptr := add(fptr, 0x20)

                    // 0x00 ... 0x1f
                    // construct operator
                    mstore(fptr, operator)
                    fptr := add(fptr, 0x20)

                    // 0x20 ... 0x3f
                    // construct from
                    mstore(fptr, from)
                    fptr := add(fptr, 0x20)

                    // 0x40 ... 0x5f
                    // construct id
                    mstore(fptr, id)
                    fptr := add(fptr, 0x20)

                    // 0x60 ... 0x7f
                    // construct from
                    mstore(fptr, amount)
                    fptr := add(fptr, 0x20)

                    let dataArrTotalBytes := getU8ArrTotalBytesNum(dataArrPtr)

                    // 0x80 ... 0x9f
                    // construct data array pointer
                    mstore(fptr, 0xa0)
                    fptr := add(fptr, 0x20)

                    fptr := copyU8ArrToMem(fptr, dataArrPtr)

                    let response := call(gas(), to, 0, add(optr, 28), sub(fptr, optr), 0x00, 4)
                    require(response)

                    let returnSignature := div(mload(0x00), 0x100000000000000000000000000000000000000000000000000000000)
                    require(eq(signature, returnSignature))

                }

            }
            function doSafeBatchTransferAcceptanceCheck(operator, from, to, idArrPtr, amountArrPtr, dataArrPtr) {

                if extcodesize(to) {
                    let fptr := 0x80
                    let optr := fptr

                    // keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)")
                    let signature := 0xbc197c81
                    
                    mstore(fptr, signature)
                    fptr := add(fptr, 0x20)

                    // 0x00 ... 0x1f
                    // construct operator
                    mstore(fptr, operator)
                    fptr := add(fptr, 0x20)

                    // 0x20 ... 0x3f
                    // construct from
                    mstore(fptr, from)
                    fptr := add(fptr, 0x20)

                    
                    let idArrTotalBytes, amountArrTotalBytes, dataArrTotalBytes
                    idArrTotalBytes := getU256ArrTotalBytesNum(idArrPtr)
                    amountArrTotalBytes := getU256ArrTotalBytesNum(amountArrPtr)
                    dataArrTotalBytes := getU8ArrTotalBytesNum(dataArrPtr)

                    // construct ids array pointer
                    mstore(fptr, 0xa0)
                    fptr := add(fptr, 0x20)

                    // construct amounts array pointer
                    mstore(fptr, add(0xa0, idArrTotalBytes))
                    fptr := add(fptr, 0x20)

                    // construct data array pointer
                    mstore(fptr, add(0xa0, add(idArrTotalBytes, amountArrTotalBytes)))
                    fptr := add(fptr, 0x20)


                    fptr := copyU256ArrToMem(fptr, idArrPtr)
                    
                    fptr := copyU256ArrToMem(fptr, amountArrPtr)

                    fptr := copyU8ArrToMem(fptr, dataArrPtr)

                    let response := call(gas(), to, 0, add(optr, 28), sub(fptr, optr), 0x00, 4)
                    require(response)

                    let returnSignature := div(mload(0x00), 0x100000000000000000000000000000000000000000000000000000000)
                    require(eq(signature, returnSignature))

                }

            }
            function _safeTransferFrom(from, to, id, amount) {
                let fromBalance := balanceOf(from, id)
                require(gte(fromBalance, amount))

                sstore(balancesPos(id, from), sub(fromBalance, amount))

                let toBalance := balanceOf(to, id)
                sstore(balancesPos(id, to), add(toBalance, amount))
            }
            function safeTransferFrom(from, to, id, amount, dataArrPtr) {
                require(or(eq(from, caller()), isApprovedForAll(from, caller())))
                revertIfZeroAddress(to)
                
                _safeTransferFrom(from, to, id, amount)
                
                emitTransferSingle(caller(), from, to, id, amount)

                doSafeTransferAcceptanceCheck(caller(), from, to, id, amount, dataArrPtr)

                return(0x00, 0x20)
            }
            function safeBatchTransferFrom(from, to, idArrPtr, amountArrPtr, dataArrPtr) {
                require(or(eq(from, caller()), isApprovedForAll(from, caller())))
                revertIfZeroAddress(to)

                let idArrLen, firstIdPtr := getArrLenAndFirstItemPtr(idArrPtr)
                let amountArrLen, firstAmountPtr := getArrLenAndFirstItemPtr(amountArrPtr)
                require(eq(idArrLen, amountArrLen))

                let id, amount
                for {let i := 0} lt(i, idArrLen) {i := add(i, 1)} {
                    id := calldataload(firstIdPtr)
                    amount := calldataload(firstAmountPtr)
                    _safeTransferFrom(from, to, id, amount)

                    firstIdPtr := add(firstIdPtr, 0x20)
                    firstAmountPtr := add(firstAmountPtr, 0x20)
                }

                emitTransferBatch(caller(), from, to, idArrPtr, amountArrPtr)

                doSafeBatchTransferAcceptanceCheck(caller(), from, to, idArrPtr, amountArrPtr, dataArrPtr)

                return(0x00, 0x20)
            }

            /* ---------- utility functions ---------- */
            function lte(a, b) -> r {
                r := iszero(gt(a, b))
            }
            function gte(a, b) -> r {
                r := iszero(lt(a, b))
            }
            function safeAdd(a, b) -> r {
                r := add(a, b)
                if or(lt(r, a), lt(r, b)) { revert(0, 0) }
            }
            function revertIfZeroAddress(addr) {
                require(addr)
            }
            function require(condition) {
                if iszero(condition) { revert(0, 0) }
            }
            /**
             *  Return item number in array
             */
            function getArrItemNum(arrPtr) -> itemNum {
                itemNum := calldataload(arrPtr)
            }
            /**
             *  Return item number in array and pointer to the first item
             */
            function getArrLenAndFirstItemPtr(arrPtr) -> arrLen, firstItemPtr {
                arrLen := getArrItemNum(arrPtr)
                // actual data pointer
                firstItemPtr := add(arrPtr, 0x20)
            }
            /**
             *  Calculate the total bytes number of prefix length plus items
             */
            function getU256ArrTotalBytesNum(u256ArrPtr) -> totalBytesNum {
                let itemNum := getArrItemNum(u256ArrPtr)
                let bytesNum := mul(itemNum, 0x20)

                totalBytesNum := add(0x20, bytesNum)
            }
            function getU8ArrTotalBytesNum(u8ArrPtr) -> totalBytesNum {
                let itemNum := getArrItemNum(u8ArrPtr)

                totalBytesNum := add(0x20, itemNum)
            }
            function copyToMem(mptr, calldataPtr, bytesNum) -> nMptr {
                // calldatacopy(t, f, s)
                // copy s bytes from calldata at position f to mem at position t
                calldatacopy(mptr, calldataPtr, bytesNum)
                nMptr := add(mptr, bytesNum)
            }
            /**
             *  If original value in calldata is 0x20
             *  then dataArrPtr passed in will be 0x24
             */
            function copyU256ArrToMem(mptr, u256ArrPtr) -> newFptr {              
                let totalBytesNum := getU256ArrTotalBytesNum(u256ArrPtr)

                newFptr := copyToMem(mptr, u256ArrPtr, totalBytesNum)
            }
            function copyU8ArrToMem(mptr, u8ArrPtr) -> newFptr {              
                let totalBytesNum := getU8ArrTotalBytesNum(u8ArrPtr)

                newFptr := copyToMem(mptr, u8ArrPtr, totalBytesNum)
            }

        }

    }

}