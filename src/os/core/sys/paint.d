/**
 * Authors: initkfs
 */
module os.core.sys.paint;

private
{
	alias KStdio = os.core.io.kstdio;
}

void drawSierpinski(const int height, const char symbol = '*')
{
	if(height % 2 != 0){
		return;
	}

	for (int heightCounter = height - 1; heightCounter >= 0; heightCounter--)
	{
		for (int spaceCounter = 0; spaceCounter < heightCounter; spaceCounter++)
		{
			KStdio.kprintSpace;
		}

		for (int charCounter = 0; charCounter + heightCounter < height; charCounter++)
		{
			if ((charCounter & heightCounter) != 0)
			{
				KStdio.kprint("  ");
			}
			else
			{
				KStdio.kprintChar(symbol);
				KStdio.kprintSpace;
			}

		}

		KStdio.kprintln;
	}

}