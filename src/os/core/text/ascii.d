/**
 * Authors: initkfs
 */
module os.core.text.ascii;

//TODO ascii table implementation
bool isEnter(const char code) @safe pure
{
	return code == '\n';
}
