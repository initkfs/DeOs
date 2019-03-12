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
import os.core.sys.cli;
import os.core.sys.exit;

extern (C) __gshared ulong KERNEL_END;

extern (C) void kmain(uint magic, size_t* multibootInfoAddress)
{
	disableCursor();
	kprintln("DeOs. Version: 0.1a. Author: inikfs");

	size_t* memoryStart = cast(size_t*)&KERNEL_END;
	//TODO parse page tables
	size_t* memoryEnd = cast(size_t*)(0x200 * 0x32 * 0x1000 + memoryStart);

	//Initialize linear allocator
	setMemoryCursorStart(memoryStart);
	setMemoryCursorEnd(memoryEnd);

	setISRs();
	setIRQs();
	setIDT();

	cliCommands[0] = CliCommand("exit", "Immediate shutdown", &exitNowCommand);
	cliCommands[1] = CliCommand("clear", "Clear screen", &clearScreenCommand);

	enableCli();
	kprintln("Shell has started. Enter the command");
	printCmd();
}

private void exitNowCommand(immutable(char[]) args){
	exitNow();
}

private void clearScreenCommand(immutable(char[]) args){
	clearScreen();
}

public extern (C) __gshared void runInterruptServiceRoutine(ulong num, ulong err)
{
	switch (num)
	{
	case EXCEPTION.PAGE_FAULT:
		break;
	default:
	}
}

public extern (C) __gshared void runInterruptRequest(ulong num, ulong err)
{
	//irqs 0-15 are mapped to interrupt service routines 32-47
	uint irq = cast(uint) num - 32;

	switch (irq)
	{
	case IRQs.TIMER:
		break;
	case IRQs.KEYBOARD:
		scanCode();
		break;
	default:
	}

	if (num >= 40)
	{
		sendEndPIC2();
	}

	sendEndPIC1();
}

private void scanCode()
{

	char k = scanKey();
	if (isReleased(k) || k == '\?' || k == 0)
	{
		return;
	}

	if(isCliEnabled()){
		applyForCli(k);
		return;
	}
}
