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
}

private
{
    __gshared ubyte* TEXT_VIDEO_MEMORY_ADDRESS = cast(ubyte*) 0xB8000;
    __gshared bool cursorEnabled = false;

    __gshared int displayIndexX = 0;
    __gshared int displayIndexY = 0;

    __gshared const int DEFAULT_TEXT_COLOR = CGAColors.COLOR_GRAY;
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
        const ubyte color = DEFAULT_TEXT_COLOR)
{
    TEXT_VIDEO_MEMORY_ADDRESS[position] = value;
    TEXT_VIDEO_MEMORY_ADDRESS[position + 1] = color;
}

private void printToTextVideoMemory(const ubyte value, const ubyte color = DEFAULT_TEXT_COLOR)
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

void printChar(const char val, const ubyte color = DEFAULT_TEXT_COLOR)
{
    //TODO use ascii module
    if (val == Kstdio.CarriageReturn.LF || val == Kstdio.CarriageReturn.CR)
    {
        newLine;
        return;
    }

    if (displayIndexY > TextDisplay.DISPLAY_LINES - 1)
    {
        scroll;
    }

    printToTextVideoMemory(val, color);
}

void printString(const string str, const ubyte color = DEFAULT_TEXT_COLOR)
{
    foreach (char c; str)
    {
        printChar(c, color);
    }
}

void println(const string str = "", const ubyte color = DEFAULT_TEXT_COLOR)
{
    printString(str, color);
    printChar(Kstdio.CarriageReturn.LF);
}

void clearScreen()
{
    bool isCursorDisabled = false;
    if(cursorEnabled){
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
    if(isCursorDisabled){
        enableCursor;
    }
}
