/**
 * Authors: initkfs
 */
module os.core.util.error_util;

import os.core.io.kstdio;

void error(const string message, const string file = __FILE__, const int line = __LINE__)
{
  immutable(string[2]) strMessages = [message, file];
  kprintf!string("ERROR: %s in %s. ", strMessages);

  immutable(int[1]) lineMessages = [line];
  kprintf!int("Line: %d", lineMessages);
  asm @trusted
  {
    cli;
  }
  while (true)
  {
  }
}
