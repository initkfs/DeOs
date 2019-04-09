/**
 * Authors: initkfs
 */
module os.core.memory.allocators.linear;

private __gshared size_t* memoryCursorStart = null;
private __gshared size_t* memoryCursorEnd = null;
private __gshared size_t* memoryCursor = null;

import os.core.util.error_util;
import os.core.util.assertions_util;

void setMemoryCursorStart(const size_t* value)
{

    kassert(value !is null);

    if (memoryCursorStart !is null)
    {
        error("Memory start cursor already set");
    }

    //TODO check end > start
    memoryCursorStart = cast(size_t*)value;
}

void setMemoryCursorEnd(const size_t* value)
{

    kassert(value !is null);

    if (memoryCursorEnd !is null)
    {
        error("Memory end cursor already set");
    }

    memoryCursorEnd = cast(size_t*)value;
}

size_t getAvailableMemoryBytes()
{

    kassert(memoryCursorEnd !is null);
    kassert(memoryCursorStart !is null);

    return memoryCursorEnd - memoryCursorStart;
}

private size_t* getMemoryCursor()
{
    return memoryCursor;
}

private void setMemoryCursor(const size_t* value)
{
    memoryCursor = cast(ulong*)value;
}

private void incMemoryCursor(const ulong value)
{
    memoryCursor += value;
}

private void decMemoryCursor(const ulong value)
{
    memoryCursor -= value;
}

size_t* allocLinear(const size_t size)
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

    //TODO align
    incMemoryCursor(size);
    return getMemoryCursor();
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
