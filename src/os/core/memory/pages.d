/**
 * Authors: initkfs
 */
module os.core.memory.pages;

pure @safe size_t getPageLevel4PhysAddr()
{
	size_t retVal;
	asm pure @trusted
	{
		mov RAX, CR3;
		mov retVal, RAX;
	}
	return retVal;
}
