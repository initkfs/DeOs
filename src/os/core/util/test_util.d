/**
 * Authors: initkfs
 */
module os.core.util.test_util;

//TODO wtf type?
void runTest(alias anyModule)()
{
	//The -unittest flag needs to be passed to the compiler.
	foreach (unitTestFunction; __traits(getUnitTests, anyModule))
	{
		unitTestFunction();
	}
}
