/**
 * Authors: initkfs
 */
module os.core.memory.allocators.linear;

private __gshared size_t* memoryCursorStart = null;
private __gshared size_t* memoryCursorEnd = null;
private __gshared size_t* memoryCursor = null;

import os.core.util.error_util;
import os.core.util.assertions_util;

void setMemoryCursorStart(size_t* value){

    kassert(value !is null);
    
    if(memoryCursorStart !is null){
        error("Memory start cursor already set");
    }

    //TODO check end > start
    memoryCursorStart = value;
}

void setMemoryCursorEnd(size_t* value){

    kassert(value !is null);

    if(memoryCursorEnd !is null){
        error("Memory end cursor already set");
    }

    memoryCursorEnd = value;
}

size_t getAvailableMemoryBytes(){
    
    kassert(memoryCursorEnd !is null);
    kassert(memoryCursorStart !is null);

    return memoryCursorEnd - memoryCursorStart;
}

private size_t* getMemoryCursor(){
    return memoryCursor;
}

private void setMemoryCursor(size_t* value){
    memoryCursor = value;
}

private void incMemoryCursor(ulong value){
    memoryCursor += value;
}

private void decMemoryCursor(ulong value){
    memoryCursor -= value;
}

size_t* allocLinear(size_t size)
{
    kassert(memoryCursorStart !is null);
    kassert(memoryCursorEnd !is null);

    if(memoryCursor is null){
        setMemoryCursor(memoryCursorStart);
    }

    size_t available = getAvailableMemoryBytes();
    if(available < size){
        error("Unable to allocate memory. Memory overflow");
    }

    //TODO align
    incMemoryCursor(size);
    return getMemoryCursor();
}

void resetLinearCursor(){

    if(memoryCursor is null){
        error("Cannot reset linear allocator. Memory cursor is null");
    }
    setMemoryCursor(memoryCursorStart);
}

void resetLinearAlloc(){
    memoryCursorStart=null;
    memoryCursorEnd=null;
    memoryCursor=null;
}