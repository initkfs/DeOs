/**
 * Authors: initkfs
 */
module os.core.text.ascii;

//TODO ascii table implementation
pure @safe bool isEnter(const char code)
{
	return code == '\n';
}
