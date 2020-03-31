/**
 * Authors: initkfs
 */
module os.core.io.kstdio;

private {
    alias Display = os.core.graphic.display;
    alias ConvertionUtil = os.core.util.conversion_util;
    alias StringUtil = os.core.util.string_util;
}

struct CarriageReturn
{
    enum LF = '\n';
    enum CR = '\r';
}

void kprintChar(const char charValue, const ubyte color = 0b111){
    Display.printChar(charValue, color);
}

void kprintSpace(){
    kprintChar(' ');
}

void kprint(const string str, const ubyte color = 0b111)
{
    Display.printString(str, color);
}

void kprintln(const string str = "", const ubyte color = 0b111)
{
    kprint(str, color);
    kprintChar(CarriageReturn.LF);
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
                        kprint(arg, color);
                    }
                    continue;
                }
            case 'x':
                {
                    static if (is(typeof(arg) : long))
                    {
                        char[20] longValue = ConvertionUtil.longToChars(arg, 16);
                        size_t startIndex = StringUtil.indexOfNotZeroChar(longValue);
                        // printString("0x");
                        for (auto i = startIndex; i < longValue.length; i++)
                        {
                            immutable char ch = longValue[i];
                            kprintChar(ch);
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

        kprintChar(formatArg, color);
    }
}

private void printNumericValue(const(long) value)
{
    const char[20] longValue = ConvertionUtil.longToChars(value, 10);
    size_t startIndex = StringUtil.indexOfNotZeroChar(longValue);
    for (auto i = startIndex; i < longValue.length; i++)
    {
        immutable char ch = longValue[i];
        kprintChar(ch);
    }
}

void kprintfln(T)(const string format, const T[] args, const ubyte color = 0b111)
{
    kprintf!T(format, args, color);
    kprintChar(CarriageReturn.LF);
}
