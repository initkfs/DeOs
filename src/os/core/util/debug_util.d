/**
 * Authors: initkfs
 */
module os.core.util.debug_util;

import os.core.io.kstdio;

void dumpMemory(ubyte* memoryStartPtr, ubyte* memoryEndPtrInclusive)
{
    kprintln;
    ubyte* memoryPosition = memoryStartPtr;
    ulong[1] size = [memoryEndPtrInclusive - memoryStartPtr + 1];
    kprintfln("Memory dump: %l bytes", size);

    while (memoryPosition <= memoryEndPtrInclusive)
    {
        const long[1] memAddr = [cast(long) memoryPosition];
        kprintf("0x%x ", memAddr);

        const ubyte memValue = cast(ubyte)*memoryPosition;
        const long[1] memAddrValue = [cast(long) memValue];
        if (memAddrValue[0] == 0)
        {
            kprint("0x0");
        }
        else
        {
            kprintf(" 0x%x", memAddrValue);
        }

        kprintln;
        memoryPosition++;
    }
}
