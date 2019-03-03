/**
 * Authors: initkfs
 */
module os.core.util.error_util;

import os.core.io.kstdio;

void error(string message, string file = __FILE__, int line = __LINE__)
{
  string[2] strMessages = [message, file];
  kprintf!string("ERROR: %s in %s. ", strMessages);

  int[1] lineMessages = [line];
  kprintf!int("Line: %d", lineMessages);
  asm
  {
    cli;
  }
  while (true)
  {
  }
}
