/**
 * Authors: initkfs
 */
//https://wiki.osdev.org/PS/2_Keyboard
module os.core.io.keyboard;

import os.core.io.kstdio;
import os.core.io.ports;
import os.core.util.conversion_util;

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

public enum SCANCODES
{
	CAPSLOCK = 0x3a,
	LSHIFT = 0x2a,
	RSHIFT = 0x36,
	ESC = 0x01
}

private
{
	__gshared bool isShiftPress = false;
	__gshared bool isCapsLockPress = false;
}

bool isReleased(const char code) @safe pure
{
	return (code & 128) == 128;
}

bool isPressed(const char code) @safe pure
{
	return !isReleased(code);
}

ubyte scanKeyCode()
{
	immutable ubyte scanCode = readFromPort!(ubyte)(0x60);

	if (scanCode & 0x80)
	{
		return 0;
	}

	if (isReleased(scanCode))
	{

		immutable ubyte releasedCode = cast(ubyte)(scanCode - 128);
		switch (releasedCode)
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

		return 0;
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

	return scanCode;
}

char getKeyByCode(immutable(ubyte) scanCode)
{
	if (scanCode == 0)
	{
		auto releaseKeyChar = '?';
		return releaseKeyChar;
	}

	immutable int charIndex = ((isShiftPress || isCapsLockPress) ? (scanCode * 2) + 1
			: (scanCode * 2));
	immutable(char) resultChar = scanCodeTable[charIndex];
	return resultChar;
}

char scanKey()
{
	immutable(ubyte) scanCode = scanKeyCode;
	immutable(char) resultChar = getKeyByCode(scanCode);
	return resultChar;
}
