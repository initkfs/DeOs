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
