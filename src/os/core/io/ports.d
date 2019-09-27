/**
 * Authors: initkfs
 */
module os.core.io.ports;

void writeToPortByte(const ushort port, const ubyte data) @safe
{
	uint rawValue = data;
	asm @trusted
	{
		mov DX, port;
		mov EAX, rawValue;
		out DX, AL;
	}
}

void writeToPortShort(const ushort port, const ushort data) @safe
{
	uint rawValue = data;
	asm @trusted
	{
		mov DX, port;
		mov EAX, rawValue;
		out DX, AX;
	}
}

void writeToPortInt(const ushort port, const uint data) @safe
{
	uint rawValue = data;
	asm @trusted
	{
		mov DX, port;
		mov EAX, rawValue;
		out DX, EAX;
	}
}

T readFromPort(T)(const ushort port) @safe
		if (is(T == ubyte) || is(T == ushort) || is(T == uint))
{
	T resultValue;

	//TODO check port
	static if (is(T == ubyte))
	{
		asm @trusted
		{
			mov DX, port;
			in AL, DX;
			mov resultValue, AL;
		}
	}
	else static if (is(T == ushort))
	{
		asm @trusted
		{
			mov DX, port;
			in AX, DX;
			mov resultValue, AX;
		}
	}
	else static if (is(T == uint))
	{
		asm @trusted
		{
			mov DX, port;
			in EAX, DX;
			mov resultValue, EAX;
		}
	}

	return resultValue;
}
