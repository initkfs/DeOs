/**
 * Authors: initkfs
 */
module os.core.io.kstdio;

import os.core.graphic.display;
import os.core.util.conversion_util;
import os.core.util.string_util;

struct CarriageReturn
{
    enum LF = '\n';
    enum CR = '\r';
}

void kprint(string str, ubyte color = 0b111)
{
    printString(str, color);
}

void kprintln(string str, ubyte color = 0b111)
{
    printString(str, color);
    printChar(CarriageReturn.LF);
}

void kprintf(T)(string format, T[] args, ubyte color = 0b111)
{
    //TODO add stack
    bool formatFound;
    int formatIndex;
    foreach (char formatArg; format)
    {

        if (formatFound)
        {
            if (formatIndex >= args.length)
            {
                return;
            }

            formatFound = false;
            T arg = args[formatIndex];
            formatIndex++;
            switch (formatArg)
            {
            case 'd':
                {
                    //TODO long?
                    static if (is(typeof(arg) : int))
                    {
                        char[20] intValue = longToString(arg, 10);
                        size_t startIndex = indexOfNotZeroChar(intValue);
                        for (auto i = startIndex; i < intValue.length; i++)
                        {
                            char ch = intValue[i];
                            printChar(ch);
                        }
                    }
                    continue;
                }
            case 's':
                {
                    static if (is(typeof(arg) : string))
                    {
                        printString(arg, color);
                    }
                    continue;
                }
            case 'x':
                {
                    static if (is(typeof(arg) : long))
                    {
                        char[20] longValue = longToString(arg, 16);
                        size_t startIndex = indexOfNotZeroChar(longValue);
                        printString("0x");
                        for (auto i = startIndex; i < longValue.length; i++)
                        {
                            char ch = longValue[i];
                            printChar(ch);
                        }
                    }
                    continue;
                }
            default:
                {
                    continue;
                }
            }
        }

        formatFound = formatArg == '%';
        if (formatFound)
        {
            continue;
        }

        printChar(formatArg, color);
    }
}

void kprintfln(T)(string format, T[] args, ubyte color = 0b111)
{
    kprintf!T(format, args, color);
    printChar(CarriageReturn.LF);
}
