/**
 * Authors: initkfs
 */
module os.core.util.debug_util;

private {
    alias Kstdio = os.core.io.kstdio;
}

void dumpMemory(ubyte* memoryStartPtr, ubyte* memoryEndPtrInclusive)
{
    Kstdio.kprintln;
    ubyte* memoryPosition = memoryStartPtr;
    ulong[1] size = [memoryEndPtrInclusive - memoryStartPtr + 1];
    Kstdio.kprintfln("Memory dump: %l bytes", size);

    while (memoryPosition <= memoryEndPtrInclusive)
    {
        const long[1] memAddr = [cast(long) memoryPosition];
        Kstdio.kprintf("0x%x ", memAddr);

        const ubyte memValue = cast(ubyte)*memoryPosition;
        const long[1] memAddrValue = [cast(long) memValue];
        if (memAddrValue[0] == 0)
        {
            Kstdio.kprint("0x0");
        }
        else
        {
            Kstdio.kprintf(" 0x%x", memAddrValue);
        }

        Kstdio.kprintln;
        memoryPosition++;
    }
}
