/**
 * Authors: initkfs
 */
module os.core.memory.pages;

size_t getPageLevel4PhysAddr() @safe pure
{
	size_t retVal;
	asm pure @trusted
	{
		mov RAX, CR3;
		mov retVal, RAX;
	}
	return retVal;
}
