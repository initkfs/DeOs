/**
 * Authors: initkfs
 */
module os.core.graphic.text_drawer;

private
{
    alias Display = os.core.graphic.display;
}

void drawLine(const char symbol = '#', const ubyte color = Display.CGAColors.DEFAULT_TEXT_COLOR)
{
    Display.printCharRepeat(symbol, Display.TextDisplay.DISPLAY_COLUMNS, color);
}

void drawCenterText(const string text, const ubyte color = Display.CGAColors.DEFAULT_TEXT_COLOR,
        const size_t lineWidth = Display.TextDisplay.DISPLAY_COLUMNS, const char indentSymbol = ' ')
{
    if(text.length == 0){
        return;
    }

    size_t mustBeLineWidth = lineWidth;
    if(text.length > mustBeLineWidth){
        mustBeLineWidth = text.length;
    }

    const leftAndRigthIndent = (mustBeLineWidth - text.length) / 2;

    Display.printCharRepeat(indentSymbol, leftAndRigthIndent);
    Display.printString(text, color);

    const rightPadIndent = mustBeLineWidth - text.length - leftAndRigthIndent;
    Display.printCharRepeat(indentSymbol, rightPadIndent);
}
