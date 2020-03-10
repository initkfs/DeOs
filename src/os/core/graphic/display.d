/**
 * Authors: initkfs
 */
module os.core.graphic.display;

private
{
    alias Kstdio = os.core.io.kstdio;
    alias Ports = os.core.io.ports;
}

__gshared struct TextDisplay
{
    enum DISPLAY_COLUMNS = 80;
    enum DISPLAY_LINES = 25;
    enum DISPLAY_ATTRIBUTE = 7;
    enum DISPLAY_MAX_INDEX = DISPLAY_COLUMNS * DISPLAY_LINES * 2;
}

__gshared struct CGAColors
{
    enum COLOR_BLACK = 0; //00 00 00
    enum COLOR_BLUE = 1; //00 00 AA
    enum COLOR_GREEN = 0x02; //00 AA 00
    enum COLOR_CYAN = 3; //00 AA AA
    enum COLOR_RED = 4; //AA 00 00
    enum COLOR_PURPLE = 5; //AA 00 AA
    enum COLOR_BROWN = 6; //AA 55 00
    enum COLOR_GRAY = 7; //AA AA AA
    enum COLOR_DARK_GRAY = 8; //55 55 55
    enum COLOR_LIGHT_BLUE = 9; //55 55 FF
    enum COLOR_LIGHT_GREEN = 10; //55 FF 55
    enum COLOR_LIGHT_CYAN = 11; //55 FF FF
    enum COLOR_LIGHT_RED = 12; //FF 55 55
    enum COLOR_LIGHT_PURPLE = 13; //FF 55 FF
    enum COLOR_YELLOW = 14; //FF FF 55
    enum COLOR_WHITE = 15; //FF FF FF
    enum DEFAULT_TEXT_COLOR = COLOR_GRAY;
}

__gshared struct CGAInfoColors
{
    enum COLOR_SUCCESS = CGAColors.COLOR_LIGHT_GREEN;
    enum COLOR_WARNING = CGAColors.COLOR_YELLOW;
    enum COLOR_INFO = CGAColors.COLOR_CYAN;
    enum COLOR_ERROR = CGAColors.COLOR_LIGHT_RED;
}

private
{
    __gshared ubyte* TEXT_VIDEO_MEMORY_ADDRESS = cast(ubyte*) 0xB8000;
    __gshared bool cursorEnabled = false;

    __gshared int displayIndexX = 0;
    __gshared int displayIndexY = 0;
}

bool isCursorEnabled()
{
    return cursorEnabled;
}

//https://wiki.osdev.org/Text_Mode_Cursor
void enableCursor(const ubyte cursorStart = 0, const ubyte cursorEnd = TextDisplay.DISPLAY_COLUMNS)
{
    if (isCursorEnabled)
    {
        return;
    }

    Ports.writeToPortByte(0x3D4, 0x0A);

    const currStart = Ports.readFromPort!ubyte(0x3D5);
    Ports.writeToPortByte(0x3D5, (currStart & 0xC0) | cursorStart);

    Ports.writeToPortByte(0x3D4, 0x0B);

    const currEnd = Ports.readFromPort!ubyte(0x3D5);
    Ports.writeToPortByte(0x3D5, (currEnd & 0xE0) | cursorEnd);

    cursorEnabled = true;
}

//https://wiki.osdev.org/Text_Mode_Cursor
void disableCursor()
{
    if (!isCursorEnabled)
    {
        return;
    }

    Ports.writeToPortByte(0x3D4, 0x0A);
    Ports.writeToPortByte(0x3D5, 0x20);
    cursorEnabled = false;
}

private void updateCursor()
{
    const uint pos = displayIndexY * TextDisplay.DISPLAY_COLUMNS + displayIndexX;

    Ports.writeToPortByte(0x3D4, 0x0F);
    Ports.writeToPortByte(0x3D5, (pos & 0xFF));
    Ports.writeToPortByte(0x3D4, 0x0E);
    Ports.writeToPortByte(0x3D5, ((pos >> 8) & 0xFF));
}

private size_t updateCoordinates()
{
    if (displayIndexX > TextDisplay.DISPLAY_COLUMNS - 1)
    {
        newLine;
    }

    //row = chars in row * 2 (char + color)
    const rowBytesCount = displayIndexY * TextDisplay.DISPLAY_COLUMNS * 2;
    const currentColumnBytesCount = displayIndexX * 2;

    const positionByteX = rowBytesCount + currentColumnBytesCount;
    return positionByteX;
}

private void resetCoordinates()
{
    displayIndexX = 0;
    displayIndexY = 0;
}

void newLine()
{
    displayIndexY++;
    displayIndexX = 0;
}

void skipColumn()
{
    displayIndexX++;
    updateCoordinates;
}

private void writeToTextVideoMemory(size_t position, const ubyte value,
        const ubyte color = CGAColors.DEFAULT_TEXT_COLOR)
{
    TEXT_VIDEO_MEMORY_ADDRESS[position] = value;
    TEXT_VIDEO_MEMORY_ADDRESS[position + 1] = color;
}

private void printToTextVideoMemory(const ubyte value,
        const ubyte color = CGAColors.DEFAULT_TEXT_COLOR)
{
    const size_t position = updateCoordinates;

    writeToTextVideoMemory(position, value, color);

    displayIndexX++;
    updateCursor;
}

void scroll(uint lines = 1)
{
    //TODO text buffer
    clearScreen;
    resetCoordinates;
}

void printCharRepeat(const char symbol, const size_t repeatCount = 1,
        const ubyte color = CGAColors.DEFAULT_TEXT_COLOR)
{

    size_t mustBeSymboltring = repeatCount;
    const size_t maxChars = TextDisplay.DISPLAY_COLUMNS * TextDisplay.DISPLAY_LINES;
    if (mustBeSymboltring > maxChars)
    {
        mustBeSymboltring = maxChars;
    }

    foreach (index; 0 .. mustBeSymboltring)
    {
        printChar(symbol, color);
    }
}

void printChar(const char symbol, const ubyte color = CGAColors.DEFAULT_TEXT_COLOR)
{
    //TODO use ascii module
    if (symbol == Kstdio.CarriageReturn.LF || symbol == Kstdio.CarriageReturn.CR)
    {
        newLine;
        return;
    }

    if (displayIndexY > TextDisplay.DISPLAY_LINES - 1)
    {
        scroll;
    }

    printToTextVideoMemory(symbol, color);
}

/*
* The symbol must be known at compile time.
* TextDrawer.drawUntil!('*', (symbol, symbolCount) => symbolCount <= 5); //*****
*/
void printCharUntil(const char symbol, bool function(const char, const size_t) symbolCountPredicate,
        const ubyte color = Display.CGAColors.DEFAULT_TEXT_COLOR)()
{
    size_t charsCount = 1;
    while (symbolCountPredicate(symbol, charsCount))
    {
        Display.printChar(symbol, color);
        charsCount++;
    }
}

void printString(const string str, const ubyte color = CGAColors.DEFAULT_TEXT_COLOR)
{
    foreach (char c; str)
    {
        printChar(c, color);
    }
}

void printStringRepeat(const string str, const size_t repeatCount = 1,
        const ubyte color = CGAColors.DEFAULT_TEXT_COLOR)
{

    size_t mustBeStringCount = repeatCount;
    const size_t maxStrings = (TextDisplay.DISPLAY_LINES * TextDisplay.DISPLAY_COLUMNS) / str
        .length;
    if (mustBeStringCount > maxStrings)
    {
        mustBeStringCount = maxStrings;
    }

    foreach (index; 0 .. mustBeStringCount)
    {
        printString(str, color);
    }
}

void println(const string str = "", const ubyte color = CGAColors.DEFAULT_TEXT_COLOR)
{
    printString(str, color);
    printChar(Kstdio.CarriageReturn.LF);
}

void printSpace(const size_t count = 1, const char spaceChar = ' ')
{
   printCharRepeat(spaceChar, count);
}

void clearScreen()
{
    bool isCursorDisabled = false;
    if (cursorEnabled)
    {
        disableCursor;
        isCursorDisabled = true;
    }
    resetCoordinates;
    immutable charCount = TextDisplay.DISPLAY_COLUMNS * TextDisplay.DISPLAY_LINES;
    foreach (index; 0 .. charCount)
    {
        //don't use black color
        printToTextVideoMemory(' ');
    }
    resetCoordinates;
    if (isCursorDisabled)
    {
        enableCursor;
    }
}
