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
import os.core.sys.exit;

extern (C) __gshared ulong KERNEL_END;

private __gshared bool isActiveShell = false;
private __gshared ubyte[100] shellCommandBuffer = [];
private __gshared ShellCommand[1] shellCommands;

struct ShellCommand
{
	string name;
	string desctiption;
	void function(immutable(char[]) args) action;

	this(string name, string desctiption, void function(immutable(char[]) args) action)
	{
		this.name = name;
		this.desctiption = desctiption;
		this.action = action;
	}
}

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

	auto exitCommand = ShellCommand("exit", "Immediate shutdown", &exitNow);

	shellCommands[0] = exitCommand;

	isActiveShell = true;
	kprintln("Shell has started. Enter the command");
	printCmd();
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

private void printCmd()
{
	enableCursor();
	kprint("$>");
}

private void scanCode()
{

	char k = scanKey();
	if (isReleased(k) || k == '\?' || k == 0)
	{
		return;
	}

	if (k == '\n' && isActiveShell)
	{
		for (int i = 0; i < shellCommandBuffer.length; i++)
		{
			if (shellCommandBuffer[i] == 0u || shellCommandBuffer[i] == ' ')
			{

				if (i == 0)
				{
					//command is empty
					return;
				}

				disableCursor();
				parseAndRunCommand(shellCommandBuffer[0 .. i], shellCommandBuffer[i .. $]);
				break;
			}
		}

		for (int i = 0; i < shellCommandBuffer.length; i++)
		{
			shellCommandBuffer[i] = 0u;
		}

		printCmd();
	}
	else if (k == '\t' && isActiveShell)
	{
		printHelp();
	}
	else if (isActiveShell)
	{
		enableCursor();
		for (int i = 0; i < shellCommandBuffer.length; i++)
		{
			ubyte c = shellCommandBuffer[i];
			if (c == 0u)
			{
				shellCommandBuffer[i] = k;
				break;
			}
		}
		char[1] charStr = [k];
		kprint(cast(string) charStr);
	}
}

private void printHelp()
{
	disableCursor();
	kprintln("");
	kprintln("Available commands:");
	foreach(int index, ShellCommand cmd; shellCommands){
		string[2] cmdInfo = [cmd.name, cmd.desctiption];
		kprintfln!string("%s - %s", cmdInfo);
	}

	printCmd();
}

private void parseAndRunCommand(ubyte[] command, ubyte[] args)
{

	immutable(string) commandStr = cast(immutable(string)) command;
	immutable(char[]) argsArray = cast(immutable(char[])) args;

	outer: foreach (size_t index, ref ShellCommand cmd; shellCommands)
	{

		string shellName = cmd.name;

		if (shellName.length != command.length)
		{
			continue;
		}
		else
		{
			for (int ii = 0; ii < shellName.length; ii++)
			{
				if (shellName[ii] != command[ii])
				{
					continue outer;
				}
			}
		}

		auto onAction = cmd.action;
		onAction(argsArray);
		return;
	}

	kprintln("");
	string[1] invalidCommand = [commandStr];
	kprintfln!string("Not found command: %s", invalidCommand);
}
