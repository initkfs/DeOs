/**
 * Authors: initkfs
 */
module os.core.util.string_util;

//TODO template
size_t indexOfNot(const char[] str, const char notChar)
{
    size_t startIndex;
    for (auto i = 0; i < str.length; i++)
    {
        immutable char ch = str[i];
        if (ch != notChar)
        {
            break;
        }
        else
        {
            startIndex++;
        }
    }
    return startIndex;
}

size_t indexOfNotZeroChar(const char[] str)
{
    return indexOfNot(str, '0');
}

bool strEqual(string s1, string s2)
{
    if (s1.length != s2.length)
    {
        return false;
    }

    if (s1.length == 0 && s2.length == 0)
    {
        return true;
    }

    for (int i = 0; i < s1.length; i++)
    {
        const char char1 = s1[i];
        const char char2 = s2[i];
        if (char1 != char2)
        {
            return false;
        }
    }

    return true;
}

unittest
{
    import os.core.util.assertions_util;

    kassert(strEqual("", ""));
    kassert(!strEqual("a", ""));
    kassert(!strEqual("", "a"));
    kassert(strEqual("a", "a"));
    kassert(!strEqual("ab", "a"));
    kassert(!strEqual("a", "ab"));
    kassert(strEqual("ab", "ab"));
}
