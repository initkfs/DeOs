/**
 * Authors: initkfs
 */
module os.core.sys.exit;

import os.core.io.ports;

//Bochs and old Qemu versions
void exitNow(immutable(char[]) args)
{
	string s = "Shutdown";
	foreach (char ss; s)
	{
		ubyte b = cast(ubyte) ss;
		writeToPortByte(0x8900, b);
	}
}
