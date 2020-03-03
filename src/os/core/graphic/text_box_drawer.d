/**
 * Authors: initkfs
 */
module os.core.graphic.text_box_drawer;

private
{
    alias Display = os.core.graphic.display;
    alias TextDrawer = os.core.graphic.text_drawer;
    const char sideSymbol = '#';
}

void drawBoxTop(const ubyte color = Display.CGAColors.DEFAULT_TEXT_COLOR,
        const char symbol = sideSymbol)
{
    TextDrawer.drawLine(symbol, color);
}

void drawBoxBottom(const ubyte color = Display.CGAColors.DEFAULT_TEXT_COLOR,
        const char symbol = sideSymbol)
{
    TextDrawer.drawLine(symbol, color);
}

void drawBoxSides(const size_t sideHeight = 1,
        const ubyte color = Display.CGAColors.DEFAULT_TEXT_COLOR, const char symbol = sideSymbol)
{
    const size_t symbolCount = Display.TextDisplay.DISPLAY_COLUMNS;
    const size_t maxRightSymbolIndex = symbolCount - 1;

    //quadratic complexity O(N^2), but the box height will not be particularly large
    foreach (indexSide; 0 .. sideHeight)
    {
        foreach (indexSymbol; 0 .. symbolCount)
        {
            if (indexSymbol == 0 || indexSymbol == maxRightSymbolIndex)
            {
                Display.printChar(symbol, color);
            }
            else
            {
                Display.printSpace;
            }
        }
    }

}

void drawBox(size_t height = 5, const ubyte color = Display.CGAColors.DEFAULT_TEXT_COLOR,
        const char symbol = sideSymbol)
{
    drawBoxTop(color, symbol);
    drawBoxSides(height, color, symbol);
    drawBoxBottom(color, symbol);
}
