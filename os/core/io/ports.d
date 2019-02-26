/**
 * Authors: initkfs
 */
module os.core.io.ports;

void writeToPortByte(ushort port, ubyte data)
{
	uint rawValue = data;
	asm {
		mov DX, port;
		mov EAX, rawValue;
		out DX, AL;
	}
}

void writeToPortShort(ushort port, ushort data)
{
	uint rawValue = data;
	asm {
		mov DX, port;
		mov EAX, rawValue;
		out DX, AX;
	}
}

void writeToPortInt(ushort port, uint data)
{
	uint rawValue = data;
	asm {
		mov DX, port;
		mov EAX, rawValue;
		out DX, EAX;
	}
}

T readFromPort(T)(ushort port) if (is(T == ubyte) || is(T == ushort) || is(T == uint))
{
	T resultValue;

	//TODO check port
	static if(is(T == ubyte)){
		asm{
			mov DX, port;
			in AL, DX;
			mov resultValue, AL;
		}
	} else static if(is(T == ushort)){
		asm{
			mov DX, port;
			in AX, DX;
			mov resultValue, AX;
		}
	} else static if(is(T == uint)){
		asm{
			mov DX, port;
			in EAX, DX;
			mov resultValue, EAX;
		}
	}

	return resultValue;
}