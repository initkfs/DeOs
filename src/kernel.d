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
import os.core.workers.kworker;

extern (C) __gshared ulong KERNEL_END;

private __gshared KWorker*[1] workers;
private __gshared currentWorkerIndex = 0;
private __gshared size_t currentTick = 0;
private __gshared int tickCount = 10;

extern (C) void kmain(uint magic, size_t* multibootInfoAddress)
{
	disableCursor();

	immutable size_t* memoryStart = cast(immutable(size_t*))&KERNEL_END;
	//TODO parse page tables
	immutable size_t* memoryEnd = cast(immutable(size_t*))(0x200 * 0x32 * 0x1000 + memoryStart);

	//Initialize linear allocator
	setMemoryCursorStart(memoryStart);
	setMemoryCursorEnd(memoryEnd);

	setISRs();
	setIRQs();
	setIDT();

	cliCommands[0] = CliCommand("exit", "Immediate shutdown", &exitNowCommand);
	cliCommands[1] = CliCommand("clear", "Clear screen", &clearScreenCommand);
	cliCommands[2] = CliCommand("date",
			"Print date in format: year-month-day hour-min-sec", &dateTimeCommand);
	enableCli();
	kprintln("Shell has started. Enter the command");
	printCmd();
}

private void updateWorkers()
{
	currentTick = 1;
	while (currentTick % tickCount != 0)
	{
		immutable workerCount = workers.length;
		if (currentWorkerIndex >= workerCount)
		{
			currentWorkerIndex = 0;
		}

		KWorker* worker = workers[currentWorkerIndex];
		if (worker !is null)
		{
			worker.run();
			if (workerCount > 0)
			{
				currentWorkerIndex++;
			}
		}

		currentTick++;
	}
}

private void exitNowCommand(immutable(CliCommand) cmd, immutable(char[]) args)
{
	exitNow();
}

private void clearScreenCommand(immutable(CliCommand) cmd, immutable(char[]) args)
{
	clearScreen();
}

private void dateTimeCommand(immutable(CliCommand) cmd, immutable(char[]) args)
{
	printDateTime();
}

private void changeContext()
{
	disableCursor();
	disableCli();
	clearScreen();
}

private void onExitCommand()
{
	disableCursor();
	clearScreen();
	enableCursor();
	enableCli();
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
		scanCode();
		break;
	default:
	}

	if (num >= 40)
	{
		sendEndPIC2();
	}
	sendEndPIC1();

	updateWorkers();
}

private void scanCode()
{
	immutable ubyte keyCode = scanKeyCode();
	immutable char k = getKeyByCode(keyCode);
	if (isReleased(k) || k == 0 || keyCode == 0) // k == '\?' 
	{
		return;
	}

	// if (currentContext !is null)
	// {
	// 	SimpleContext* context = getCurrentContext();

	// 	if (keyCode == SCANCODES.ESC)
	// 	{ //ESC
	// 		context.exit();
	// 		resetContext();
	// 		onExitCommand();
	// 		return;
	// 	}

	// 	context.input(keyCode, k);
	// }
	// else
	// {
	if (isCliEnabled())
	{
		applyForCli(k);
	}
	// }
}
