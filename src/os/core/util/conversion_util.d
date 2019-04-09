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
pure @safe void itoa(int n, char[] s)
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

pure @safe private void reverse(char[] s)
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
pure @safe char[20] longToString(const long longValue, const int base)
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
    return "0";
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

// unittest
// {
//   assert("0" == longToString(0, 10));
//   assert("1" == longToString(1, 10));
//   assert("-1" == longToString(-1, 10));
//   assert("648356" == longToString(648356, 10));
//   assert("9223372036854775807" == longToString(9223372036854775807, 10));
//   assert("-9223372036854775807" == longToString(-9223372036854775807, 10));
//   assert("7FFFFFFFFFFFFFFF" == longToString(0x7FFFFFFFFFFFFFFF, 16));
//   //TODO negative hex?
// }
