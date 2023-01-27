// SPDX-License-Identifier: GPL-3.0

object "Simple" {
    code {
        datacopy(0, dataoffset("runtime"), datasize("runtime"))    // line1
        return(0, datasize("runtime"))        
    }

    object "runtime" {
        
        code {
            codecopy(0x00, 0x00, 32)
            // mstore(0x00, 2)
            return(0x00, 0x20)
        }
    }
}