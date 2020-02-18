/**
 * Authors: initkfs
 */
module os.core.util.conversion_util;

// /**
// * TODO Ldc2 memory error, but dmd2 works
// * TODO http://www.strudel.org.uk/itoa/
// * https://stackoverflow.com/questions/190229/where-is-the-itoa-function-in-linux
// * https://ru.wikipedia.org/wiki/Itoa_(Си)
// */
void itoa(int n, char[] s) @safe pure
{
  int i;
  int sign;

  if ((sign = n) < 0)
    n = -n;
  i = 0;
  do
  {
    s[i++] = n % 10 + '0';
  }
  while ((n /= 10) > 0);
  if (sign < 0)
    s[i++] = '-';
  s[i] = '\0';
  reverse(s);
}

public int charToInt(char character) @safe pure
{
  int intChar = character - '0';
  return intChar;
}

private void reverse(char[] s) @safe pure
{
  size_t i;
  size_t j;
  char c;

  for (i = 0, j = s.length - 1; i < j; i++, j--)
  {
    c = s[i];
    s[i] = s[j];
    s[j] = c;
  }
}

/*
* https://stackoverflow.com/questions/18858115/c-long-long-to-char-conversion-function-in-embedded-system
*/
char[20] longToChars(const long longValue, const int base) @safe pure
{
  char[20] buf = "00000000000000000000";
  immutable char[16] alphabet = "0123456789ABCDEF";

  if (base < 2 || base > 16)
  {
    return buf;
  }

  long val = longValue;

  if (val == 0)
  {
    return buf;
  }

  immutable maxDigits = 19;
  immutable bool isNeg = (val < 0);

  if (isNeg)
  {
    val = -val;
  }

  int i = maxDigits;
  for (; val && i; --i, val /= base)
  {
    immutable digitBaseRemainder = val % base;
    buf[i] = alphabet[digitBaseRemainder];
  }

  if (isNeg)
  {
    buf[i--] = '-';
  }

  return buf;
}

unittest
{
  import os.core.util.assertions_util;

  kassert("00000000000000000000" == longToChars(0, 10));
  kassert("00000000000000000001" == longToChars(1, 10));
  kassert("000000000000000000-1" == longToChars(-1, 10));
  kassert("00000000000000648356" == longToChars(648356, 10));
  kassert("09223372036854775807" == longToChars(9223372036854775807, 10));
  kassert("-9223372036854775807" == longToChars(-9223372036854775807, 10));
  kassert("00007FFFFFFFFFFFFFFF" == longToChars(0x7FFFFFFFFFFFFFFF, 16));
  //TODO negative hex?
}
