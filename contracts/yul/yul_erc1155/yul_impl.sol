// SPDX-License-Identifier: GPL-3.0

object "MyYulERC1155" {

    // constructor
    code {
        // Store the owner in slot 0.
        sstore(0, caller())

        // Store the uri in slot 1.
        sstore(1, caller())

        datacopy(0, dataoffset("runtime"), datasize("runtime"))
        return(0, datasize("runtime"))
    }

    data "uri" "https://game.example/api/item/{id}.json"

    object "runtime" {

        code {
            mstore(0, 0x123)
            return(0, 0x20)
        }
    }

}