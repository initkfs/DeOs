/**
 * Authors: initkfs
 */
module os.core.util.assertions_util;

import os.core.util.error_util;

public void kassert(const bool condition, const string file = __FILE__, const int line = __LINE__)
{
	if (!condition)
	{
		error("Assertion failed", file, line);
	}
}
