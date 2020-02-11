/**
 * Authors: initkfs
 */
module os.core.graphic.display;

private {
    alias Kstdio = os.core.io.kstdio;
    alias Ports = os.core.io.ports;
}

private
{
    __gshared ubyte* TEXT_VIDEO_MEMORY_ADDRESS = cast(ubyte*) 0xB8000;
    __gshared int displayIndexX = 0;
    __gshared int displayIndexY = 0;
    __gshared bool cursorEnabled = false;
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

    immutable currStart = Ports.readFromPort!ubyte(0x3D5);
    Ports.writeToPortByte(0x3D5, (currStart & 0xC0) | cursorStart);

    Ports.writeToPortByte(0x3D4, 0x0B);

    immutable currEnd = Ports.readFromPort!ubyte(0x3D5);
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
    immutable uint pos = displayIndexY * TextDisplay.DISPLAY_COLUMNS + displayIndexX;

    Ports.writeToPortByte(0x3D4, 0x0F);
    Ports.writeToPortByte(0x3D5, (pos & 0xFF));
    Ports.writeToPortByte(0x3D4, 0x0E);
    Ports.writeToPortByte(0x3D5, ((pos >> 8) & 0xFF));
}

private size_t updateCoordinates()
{
    //position = (y_position * characters_per_line) + x_position;
    if (displayIndexX > TextDisplay.DISPLAY_COLUMNS)
    {
        newLine;
    }

    immutable position = displayIndexY * 160 + displayIndexX * 2;
    return position;
}

void newLine()
{
    displayIndexY++;
    displayIndexX = 0;
}

void skipColumn(){
    displayIndexX++;
    updateCoordinates;
}

private void writeToTextVideoMemory(const ubyte value, const ubyte color = 0b111)
{
    auto textVideoMemoryAddress = TEXT_VIDEO_MEMORY_ADDRESS;

    immutable size_t position = updateCoordinates;

    ubyte* newAddress = textVideoMemoryAddress + position;
    *newAddress = value;
    //write color
    newAddress++;
    *newAddress = color;

    displayIndexX++;
    updateCursor;
}

void scroll(uint lines = 1)
{
    //TODO text buffer
}

void printChar(const char val, const ubyte color = 0b111)
{
    //TODO use ascii module
    if (val == Kstdio.CarriageReturn.LF || val == Kstdio.CarriageReturn.CR)
    {
        newLine;
        return;
    }

    if (displayIndexY >= TextDisplay.DISPLAY_LINES)
    {
        scroll;
    }

    writeToTextVideoMemory(val, color);
}

void printString(const string str, const ubyte color = CGAColors.COLOR_WHITE)
{
    foreach (char c; str)
    {
        printChar(c, color);
    }
}

void println(const string str = "", const ubyte color = 0b111)
{
    printString(str, color);
    printChar(Kstdio.CarriageReturn.LF);
}

void clearScreen()
{
    immutable color = 0b111;
    //TODO check display index;
    immutable displayMatrix = TextDisplay.DISPLAY_COLUMNS * TextDisplay.DISPLAY_LINES;
    foreach (index; 0 .. displayMatrix)
    {
        TEXT_VIDEO_MEMORY_ADDRESS[index * 2] = ' ';
        TEXT_VIDEO_MEMORY_ADDRESS[index * 2 + 1] = color;
    }
    displayIndexX = 0;
    displayIndexY = 0;
}
