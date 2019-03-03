/**
 * Authors: initkfs
 */
module os.core.io.keyboard;

import os.core.io.kstdio;
import os.core.io.ports;

private __gshared char[178] scanCodeTable = [
	'\?', '\?', //0 unused
	'\?', '\?', //ESC
	'1', '!', '2', '@', '3', '#', '4', '$', '5', '%', '6', '^', '7', '&', '8',
	'*', '9', '(', '0', ')', '-', '_', '=', '+', '\b', '\b', //backspace
	'\t', '\t', //tab
	'q',
	'Q', 'w', 'W', 'e', 'E', 'r', 'R', 't', 'T', 'y', 'Y', 'u', 'U', 'i', 'I',
	'o', 'O', 'p', 'P', '[', '{', ']', '}', '\n', '\n', '\?', '\?', //left ctrl
	'a', 'A',
	's', 'S', 'd', 'D', 'f', 'F', 'g', 'G', 'h', 'H', 'j', 'J', 'k', 'K',
	'l', 'L', ';', ':', '\'', '\"', '`', '~', '\?', '\?', //left shift
	'\\', '|', 'z', 'Z',
	'x', 'X', 'c', 'C', 'v', 'V', 'b', 'B', 'n', 'N', 'm', 'M', ',', '<',
	'.', '>', '/', '\?', '\?', '\?', //right shift
	'\?', '\?', //keypad * or */PrtScrn
	'\?', '\?', //left alt
	' ', ' ', //space bar
	'\?',
	'\?', //isCapsLockPress lock
	'\?', '\?', //F1
	'\?', '\?', //F2
	'\?', '\?', //F3
	'\?', '\?', //F4
	'\?', '\?', //F5
	'\?', '\?', //F6
	'\?', '\?', //F7
	'\?', '\?', //F8
	'\?', '\?', //F9
	'\?', '\?', //F10
	'\?', '\?', //NumLock
	'\?', '\?', //ScrollLock
	'7', '\?', //Keypad-7/Home
	'8', '\?', //Keypad-8/Up
	'9', '\?', //Keypad-9/PgUp
	'-', '\?', //Keypad -
	'4', '\?', //Keypad-4/left
	'5', '\?', //Keypad-5
	'6', '\?', //Keypad-6/Right
	'+', '\?', //Keypad +
	'1', '\?', //Keypad-1/End
	'2', '\?', //Keypad-2/Down
	'3', '\?', //Keypad-3/PgDn
	'4', '\?', //Keypad-0/Insert
	'.', '\?', //Keypad ./Del
	'\?', '\?', //Alt-SysRq
	'\?', '\?', //F11 or F12. Depends
	'\?', '\?', //non-US
	'\?', '\?', //F11
	'\?', '\?' //F12
];

private enum SCANCODES
{
	CAPSLOCK = 0x3a,
	LSHIFT = 0x2a,
	RSHIFT = 0x36
}

private __gshared bool isShiftPress = false;
private __gshared bool isCapsLockPress = false;

public bool isReleased(char code)
{
	return (code & 128) == 128;
}

public bool isPressed(char code)
{
	return !isReleased(code);
}

public __gshared char scanKey()
{
	ubyte scanCode = readFromPort!(ubyte)(0x60);

	if (scanCode & 0x80)
	{
		return 0;
	}

	if (isReleased(scanCode))
	{

		scanCode = cast(ubyte)(scanCode - 128);
		switch (scanCode)
		{
		case SCANCODES.CAPSLOCK:
			isCapsLockPress = isCapsLockPress ? false : true;
			break;
		case SCANCODES.LSHIFT:
			isShiftPress = false;
			break;
		case SCANCODES.RSHIFT:
			isShiftPress = false;
			break;
		default:
		}
	}
	else
	{
		switch (scanCode)
		{
		case SCANCODES.LSHIFT:
			isShiftPress = true;
			break;
		case SCANCODES.RSHIFT:
			isShiftPress = true;
			break;
		case SCANCODES.CAPSLOCK:
			break;
		default:
		}
	}

	int charIndex = ((isShiftPress || isCapsLockPress) ? (scanCode * 2) + 1 : (scanCode * 2));
	char resultChar = scanCodeTable[charIndex];
	return resultChar;
}
