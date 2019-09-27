/**
 * Authors: initkfs
 */
module os.core.util.algo.kstack;

import os.core.util.error_util;

struct KStackSmall
{
    private
    {
        int stackPointer = -1;
        int[100] storage;
    }

    void push(int value)
    {
        if (stackPointer == storage.length)
        {
            error("Stack's storage is overflow");
        }
        stackPointer++;
        storage[stackPointer] = value;
    }

    int peek()
    {
        if (isEmpty())
        {
            error("Stack is empty");
        }
        return storage[stackPointer];
    }

    int pop()
    {
        if (isEmpty())
        {
            error("Stack is empty");
        }
        int value = peek();
        stackPointer--;
        return value;
    }

    bool isEmpty()
    {
        return (stackPointer == -1);
    }

}
