/**
 * Authors: initkfs
 */
module os.core.sys.exit;

private {
	alias Ports = os.core.io.ports;
}

//Bochs and old Qemu versions
void exitNow()
{
	immutable s = "Shutdown";
	foreach (char ss; s)
	{
		immutable ubyte b = cast(ubyte) ss;
		Ports.writeToPortByte(0x8900, b);
	}
}
