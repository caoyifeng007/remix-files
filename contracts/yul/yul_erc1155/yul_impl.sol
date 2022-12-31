// SPDX-License-Identifier: GPL-3.0

object "MyYulERC1155" {

    // constructor
    code {
        /* -------- storage layout ---------- */
        function ownerPos() -> p { p := 0 }
        function stringLengthPos() -> p { p := 1 }
        function stringPos() -> p {
            mstore(0x00, stringLengthPos())
            p := keccak256(0x00, 0x20)
        }

        // Store the owner in slot 0.
        sstore(ownerPos(), caller())

        // Store the (length * 2 + 1) in slot 1.
        sstore(stringLengthPos(), 0x4f)

        // Store the actual string bytes in slot keccak256(1)
        sstore(stringPos(), 0x68747470733a2f2f67616d652e6578616d706c652f6170692f6974656d2f7b69)
        sstore(add(stringPos(), 1), 0x647d2e6a736f6e00000000000000000000000000000000000000000000000000)

        datacopy(0, dataoffset("runtime"), datasize("runtime"))
        return(0, datasize("runtime"))
    }

    data "uri" "https://game.example/api/item/{id}.json"

    object "runtime" {

        code {
            /* -------- storage layout ---------- */
            function ownerPos() -> p { p := 0 }
            function stringLengthPos() -> p { p := 1 }
            function stringPos() -> p {
                mstore(0x00, stringLengthPos())
                p := keccak256(0x00, 0x20)
            }

            mstore(0x00, sload(stringPos()))
            mstore(0x20, sload(add(stringPos(), 1)))

            // mstore(0x00, stringPos())
            return(0, 0x40)

        }

    }

}