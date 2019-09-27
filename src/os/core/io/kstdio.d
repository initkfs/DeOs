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

void kprint(const string str, const ubyte color = 0b111)
{
    printString(str, color);
}

void kprintln(const string str = "", const ubyte color = 0b111)
{
    printString(str, color);
    printChar(CarriageReturn.LF);
}

void kprintf(T)(const string format, const T[] args, const ubyte color = 0b111)
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
                       printNumericValue(arg);
                    }
                    continue;
                }
            case 'l':
                {
                    static if (is(typeof(arg) : long))
                    {
                       printNumericValue(arg);
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
                        // printString("0x");
                        for (auto i = startIndex; i < longValue.length; i++)
                        {
                            immutable char ch = longValue[i];
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

private void printNumericValue(const(long) value)
{
    const char[20] longValue = longToString(value, 10);
    size_t startIndex = indexOfNotZeroChar(longValue);
    for (auto i = startIndex; i < longValue.length; i++)
    {
        immutable char ch = longValue[i];
        printChar(ch);
    }
}

void kprintfln(T)(const string format, const T[] args, const ubyte color = 0b111)
{
    kprintf!T(format, args, color);
    printChar(CarriageReturn.LF);
}
