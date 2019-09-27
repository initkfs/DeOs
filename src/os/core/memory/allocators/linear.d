/**
 * Authors: initkfs
 */
module os.core.memory.allocators.linear;

import os.core.util.error_util;
import os.core.util.assertions_util;

private
{
    __gshared ubyte* memoryCursorStart;
    __gshared ubyte* memoryCursorEnd;
    __gshared ubyte* memoryCursor;
}

void setMemoryCursorStart(immutable(ubyte*) value)
{

    kassert(value !is null);

    if (memoryCursorStart !is null)
    {
        error("Memory start cursor already set");
    }

    //TODO check end > start
    memoryCursorStart = cast(ubyte*) value;
}

immutable(ubyte*) getMemoryStart()
{
    immutable(ubyte*) startAddress = cast(immutable(ubyte*)) memoryCursorStart;
    return startAddress;
}

void setMemoryCursorEnd(immutable(ubyte*) value)
{

    kassert(value !is null);

    if (memoryCursorEnd !is null)
    {
        error("Memory end cursor already set");
    }

    memoryCursorEnd = cast(ubyte*) value;
}

size_t getAvailableMemoryBytes()
{

    kassert(memoryCursorEnd !is null);
    kassert(memoryCursorStart !is null);

    return memoryCursorEnd - memoryCursorStart;
}

immutable(ubyte*) getCurrentMemoryPosition(){
    return cast(immutable(ubyte*)) getMemoryCursor;
}

private ubyte* getMemoryCursor()
{
    return memoryCursor;
}

private void setMemoryCursor(const ubyte* value)
{
    memoryCursor = cast(ubyte*) value;
}

private void incMemoryCursor(const ulong value)
{
    memoryCursor += value;
}

private void decMemoryCursor(const ulong value)
{
    memoryCursor -= value;
}

ubyte* allocLinearDword()
{
    return allocLinear(4);
}

ubyte* allocLinearQword()
{
    return allocLinear(8);
}

ubyte* allocLinear(const size_t size)
{
    kassert(memoryCursorStart !is null);
    kassert(memoryCursorEnd !is null);

    if (memoryCursor is null)
    {
        setMemoryCursor(memoryCursorStart);
    }

    immutable size_t available = getAvailableMemoryBytes();
    if (available < size)
    {
        error("Unable to allocate memory. Memory overflow");
    }

    ubyte* startBlockAddress = getMemoryCursor;

    //TODO align
    incMemoryCursor(size);
    return startBlockAddress;
}

void resetLinearCursor()
{

    if (memoryCursor is null)
    {
        error("Cannot reset linear allocator. Memory cursor is null");
    }
    setMemoryCursor(memoryCursorStart);
}

void resetLinearAlloc()
{
    memoryCursorStart = null;
    memoryCursorEnd = null;
    memoryCursor = null;
}
