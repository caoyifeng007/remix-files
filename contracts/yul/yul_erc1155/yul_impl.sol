// SPDX-License-Identifier: GPL-3.0

object "MyYulERC1155" {

    code {
        datacopy(0, dataoffset("runtime"), datasize("runtime"))
        return(0, datasize("runtime"))
    }

    object "runtime" {

        code {
            mstore(0, 0x123)
            return(0, 0x20)
        }
    }

}