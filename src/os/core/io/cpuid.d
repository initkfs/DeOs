/**
 * Authors: initkfs
 * https://wiki.osdev.org/CPUID
 * https://en.wikipedia.org/wiki/CPUID
 */
module os.core.io.cpuid;

void readCpuidVendor(uint* vendor12CharsPtr)
{
	asm
	{
		xor RAX, RAX;
		cpuid;
		mov RAX, vendor12CharsPtr;
		mov [RAX], EBX;
		mov [RAX + 4], EDX;
		mov [RAX + 8], ECX;
	}
}