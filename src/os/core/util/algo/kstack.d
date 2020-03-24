/**
 * Authors: initkfs
 */
module os.core.util.algo.kstack;

import os.core.util.error_util;

struct KStackSmall(T)
{
    private
    {
        int stackPointer = -1;
        T[100] storage;
    }

    void push(T value)
    {
        if (stackPointer == storage.length)
        {
            error("Stack's storage is overflow");
        }
        stackPointer++;
        storage[stackPointer] = value;
    }

    T peek()
    {
        if (isEmpty)
        {
            error("Stack is empty");
        }
        return storage[stackPointer];
    }

    T pop()
    {
        if (isEmpty)
        {
            error("Stack is empty");
        }
        T value = peek;
        stackPointer--;
        return value;
    }

    bool isEmpty()
    {
        return (stackPointer == -1);
    }

    size_t size(){
        return stackPointer + 1;
    }

}
