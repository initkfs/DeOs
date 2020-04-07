/**
 * Authors: initkfs
 */
module os.core.sys.paint;

private
{
	alias KStdio = os.core.io.kstdio;
	alias Math = os.core.util.math.math_util;
}

void drawSierpinski(const int height, const char symbol = '*')
{
	if (height % 2 != 0)
	{
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

void drawCircle(int radius, const char symbol = '*')
{
	real distance;

	const long diameter = 2 * radius;
	const real distanceСorrection = 0.5;

	for (long horizontalCounter = 0; horizontalCounter <= diameter; horizontalCounter++)
	{
		for (long verticalCounter = 0; verticalCounter <= diameter; verticalCounter++)
		{
			distance = Math.sqrt((horizontalCounter - radius) * (horizontalCounter - radius) + (
					verticalCounter - radius) * (verticalCounter - radius));

			if ((distance > (radius - distanceСorrection))
					&& (distance < (radius + distanceСorrection)))
			{
				KStdio.kprintChar(symbol);
			}
			else
			{
				KStdio.kprintSpace;
			}
		}

		KStdio.kprintln;
	}

}
