/**
 * Authors: initkfs
 * https://wiki.osdev.org/Interrupt_Descriptor_Table
 */
 module os.core.io.interrupt.idt;

__gshared IDTPointer idtPointer;
__gshared IDT64Entry[256] idtEntries;

struct IDT64Entry
{
	align(1):
	ushort offset_1; 	// offset bits 0..15
	ushort selector; 	// a code segment selector in GDT or LDT
	ubyte ist;       	// bits 0..2 holds Interrupt Stack Table offset, rest of bits zero.
	ubyte type_attr; 	// type and attributes
	ushort offset_2; 	// offset bits 16..31
	uint offset_3; 		// offset bits 32..63
	uint zero = 0;     	// reserved
}

struct IDTPointer
{
	align(1):
	ushort size;
	ulong base;
}

void addGateToIDT(ubyte num, size_t base, ushort selector, ubyte flags)
{
    //offset bits 0..15
	idtEntries[num] = IDT64Entry(cast(ushort)(base & 0xFFFF),
						selector,
						cast(ubyte)0,		
						flags,
						cast(ushort)((base >> 16) & 0xFFFF),
						cast(uint)((base >> 32) & 0xFFFFFFFF));
}

void setIDT()
{
	idtPointer.size = cast(ushort)((idtEntries[0].sizeof * 256) - 1);
	idtPointer.base = cast(ulong)&idtEntries;
	void *idtPointerAddr = cast(void*)(&idtPointer);

	asm
	{
		mov RAX, idtPointerAddr;
		lidt [RAX];
		sti;
	}
}