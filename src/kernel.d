/**
 * Authors: initkfs
 */
import os.core.graphic.display;
import os.core.io.kstdio;
import os.core.util.assertions_util;
import os.core.io.keyboard;
import os.core.io.ports;
import os.core.io.interrupt.idt;
import os.core.io.interrupt.isr;
import os.core.io.interrupt.irq;
import os.core.io.interrupt.pic;
import os.core.memory.allocators.linear;
import os.core.sys.date.stdate;
import os.core.sys.cli;
import os.core.sys.exit;
import os.core.util.conversion_util;

extern (C) __gshared ulong KERNEL_END;

extern (C) void kmain(uint magic, size_t* multibootInfoAddress)
{
	disableCursor;

	immutable ubyte* memoryStart = cast(immutable(ubyte*))&KERNEL_END;
	//TODO parse page tables
	immutable ubyte* memoryEnd = cast(immutable(ubyte*))(0x200 * 0x32 * 0x1000 + memoryStart);

	//Initialize linear allocator
	setMemoryCursorStart(memoryStart);
	setMemoryCursorEnd(memoryEnd);

	setISRs;
	setIRQs;
	setIDT;

	cliCommands[0] = CliCommand("exit", "Immediate shutdown", &exitNowCommand);
	cliCommands[1] = CliCommand("clear", "Clear screen", &clearScreenCommand);
	cliCommands[2] = CliCommand("date",
			"Print date in format: year-month-day hour-min-sec", &dateTimeCommand);
	cliCommands[3] = CliCommand("mem", "Print memory information", &memDebugCommand);
	enableCli;
	kprintln("Shell has started. Enter the command");
	printCmd;
}

private void exitNowCommand(immutable(CliCommand) cmd, immutable(char[]) args)
{
	exitNow;
}

private void clearScreenCommand(immutable(CliCommand) cmd, immutable(char[]) args)
{
	clearScreen;
}

private void memDebugCommand(immutable(CliCommand) cmd, immutable(char[]) args)
{
	string memStartFormat = "Memory start address: 0x%x";
	string memUsedFormat = "Memory used: %l bytes";

	println;

	const long[1] memStartAddrValues = [cast(long) getMemoryStart];
	kprintfln(memStartFormat, memStartAddrValues);

	if (getCurrentMemoryPosition !is null)
	{
		string memCurrentFormat = "Memory current address: 0x%x";
		const long[1] memCurrentAddrValues = [cast(long) getCurrentMemoryPosition];
		kprintfln(memCurrentFormat, memCurrentAddrValues);

		const long memUsedValue = getCurrentMemoryPosition - getMemoryStart;
		const long[1] memUsedValues = [memUsedValue];
		kprintfln(memUsedFormat, memUsedValues);
	}
}

private void dateTimeCommand(immutable(CliCommand) cmd, immutable(char[]) args)
{
	printDateTime;
}

extern (C) __gshared void runInterruptServiceRoutine(const ulong num, const ulong err)
{
	switch (num)
	{
	case EXCEPTION.PAGE_FAULT:
		break;
	default:
	}
}

extern (C) __gshared void runInterruptRequest(const ulong num, const ulong err)
{
	//irqs 0-15 are mapped to interrupt service routines 32-47
	immutable uint irq = cast(immutable(uint)) num - 32;
	switch (irq)
	{
	case IRQs.TIMER:

		break;
	case IRQs.KEYBOARD:
		scanCode;
		break;
	default:
	}

	if (num >= 40)
	{
		sendEndPIC2;
	}
	sendEndPIC1;
}

private void scanCode()
{
	immutable ubyte keyCode = scanKeyCode;
	immutable char k = getKeyByCode(keyCode);
	if (isReleased(k) || k == 0 || keyCode == 0) // k == '\?' 
	{
		return;
	}

	if (isCliEnabled)
	{
		applyForCli(k);
	}
}
