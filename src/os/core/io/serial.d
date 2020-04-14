/**
 * Authors: initkfs
 * See https://wiki.osdev.org/Serial_Ports
 */
module os.core.io.serial;

private
{
	alias Ports = os.core.io.ports;
}

struct SerialPorts
{
	enum COM1 = 0x3F8;
	enum COM2 = 0x2F8;
	enum COM3 = 0x3E8;
	enum COM4 = 0x2E8;
}

struct SerialPort
{
	private
	{
		const ushort portAddress;
	}

	this(const ushort portAddress)
	{
		this.portAddress = portAddress;
	}

	void initPort()
	{
		Ports.writeToPortByte(cast(ushort)(portAddress + 1), 0x00); // Disable all interrupts
		Ports.writeToPortByte(cast(ushort)(portAddress + 3), 0x80); // Enable DLAB
		Ports.writeToPortByte(cast(ushort)(portAddress + 0), 0x03); // Set divisor to 3, 38400 baud
		Ports.writeToPortByte(cast(ushort)(portAddress + 1), 0x00); // hi byte
		Ports.writeToPortByte(cast(ushort)(portAddress + 3), 0x03); // 8 bits, no parity, one stop bit
		Ports.writeToPortByte(cast(ushort)(portAddress + 2), 0xC7); // Enable FIFO, clear them, with 14-byte threshold
		Ports.writeToPortByte(cast(ushort)(portAddress + 4), 0x0B); // IRQs enabled, RTS/DSR set
	}

	bool hasReceived()
	{
		const ubyte result = Ports.readFromPort!ubyte(cast(ushort)(portAddress + 5)) & 1;
		return result != 0;
	}

	ubyte read()
	{
		while (!hasReceived)
		{
		}

		return Ports.readFromPort!ubyte(portAddress);
	}

	bool transmitIsEmpty()
	{
		const ubyte result = Ports.readFromPort!ubyte(cast(ushort)(portAddress + 5)) & 0x20;
		return result != 0;
	}

	void writeString(const string s)
	{
		foreach (char symbol; s)
		{
			write(symbol);
		}
	}

	void write(const ubyte a)
	{
		while (!transmitIsEmpty)
		{
		}

		Ports.writeToPortByte(portAddress, a);
	}

}
