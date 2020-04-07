/**
 * Authors: initkfs
 */
module kernel;

import os.core.util.assertions_util;

alias Display = os.core.graphic.display;
alias TextDrawer = os.core.graphic.text_drawer;
alias TextBoxDrawer = os.core.graphic.text_box_drawer;
alias Kstdio = os.core.io.kstdio;
alias Keyboard = os.core.io.keyboard;
alias Ports = os.core.io.ports;
alias Idt = os.core.io.interrupt.idt;
alias Isr = os.core.io.interrupt.isr;
alias Irq = os.core.io.interrupt.irq;
alias Pic = os.core.io.interrupt.pic;
alias LinearAllocator = os.core.memory.allocators.linear;
alias Date = os.core.sys.date.stdate;
alias Cli = os.core.sys.cli;
alias Calc = os.core.sys.calc;
alias Exit = os.core.sys.exit;
alias SimpleGame = os.core.sys.game.simple_game;
alias UptimeTimer = os.core.timer.uptime_timer;
alias PauseTimer = os.core.timer.pause_timer;

alias TestUtil = os.core.util.test_util;
alias ConversionUtil = os.core.util.conversion_util;
alias StringUtil = os.core.util.string_util;
alias MathUtil = os.core.util.math.math_util;

extern (C) __gshared ulong KERNEL_END;

private
{
	__gshared string osLogoData = import("os_logo.txt");
	__gshared string osName = "DeOs";
	__gshared string osVersion = "0.1a";
}

//TODO extract and switch context. Delegates don't work from another module
private __gshared bool isGame = false;

extern (C) void kmain(uint magic, size_t* multibootInfoAddress)
{
	Display.disableCursor;

	immutable ubyte* memoryStart = cast(immutable(ubyte*))&KERNEL_END;
	//TODO parse page tables
	immutable ubyte* memoryEnd = cast(immutable(ubyte*))(0x200 * 0x32 * 0x1000 + memoryStart);

	//Initialize linear allocator
	LinearAllocator.setMemoryCursorStart(memoryStart);
	LinearAllocator.setMemoryCursorEnd(memoryEnd);

	Isr.setISRs;
	Irq.setIRQs;
	Idt.setIDT;

	Kstdio.kprintln(osLogoData, Display.CGAColors.COLOR_LIGHT_GREEN);
	PauseTimer.pauseInTicks(5);
	Display.clearScreen;

	Kstdio.kprintln("Testing modules...");
	TestUtil.runTest!(ConversionUtil);
	TestUtil.runTest!(StringUtil);
	TestUtil.runTest!(MathUtil);

	TestUtil.runTest!(Calc);

	Display.clearScreen;

	const ubyte uiInfoColor = Display.CGAInfoColors.COLOR_INFO;
	Cli.setCliPromptColor(uiInfoColor);

	Cli.cliCommands[0] = Cli.CliCommand("exit", "Immediate shutdown", &exitNowCommand);
	Cli.cliCommands[1] = Cli.CliCommand("clear", "Clear screen", &clearScreenCommand);
	Cli.cliCommands[2] = Cli.CliCommand("date",
			"Print date in format: year-month-day hour-min-sec", &dateTimeCommand);
	Cli.cliCommands[3] = Cli.CliCommand("mem", "Print memory information", &memDebugCommand);
	Cli.cliCommands[4] = Cli.CliCommand("game", "Run simple game", &runSimpleGameCommand);
	Cli.cliCommands[5] = Cli.CliCommand("info", "Print hardware information", &infoCommand);
	Cli.cliCommands[6] = Cli.CliCommand("calc",
			"Run simple calculator. Without a dynamic array, the calculator accepts number as a character, i.e. < 10.",
			&calcCommand);
	Cli.cliCommands[7] = Cli.CliCommand("paint", "Run simple painter", &paintCommand);

	TextBoxDrawer.drawSimpleBox(osName, uiInfoColor);

	//TODO remove cursor
	Cli.enableCli;
	Kstdio.kprintln("Shell has started. Enter the command");
	Cli.printCmd;
}

private void exitNowCommand(immutable(Cli.CliCommand) cmd, immutable(char[]) args)
{
	Exit.exitNow;
}

private void clearScreenCommand(immutable(Cli.CliCommand) cmd, immutable(char[]) args)
{
	Display.clearScreen;
}

private void memDebugCommand(immutable(Cli.CliCommand) cmd, immutable(char[]) args)
{
	string memStartFormat = "Memory start address: 0x%x";
	string memUsedFormat = "Memory used: %l bytes";

	Kstdio.kprintln;

	const long[1] memStartAddrValues = [
		cast(long) LinearAllocator.getMemoryStart
	];
	Kstdio.kprintfln(memStartFormat, memStartAddrValues);

	if (LinearAllocator.getCurrentMemoryPosition !is null)
	{
		string memCurrentFormat = "Memory current address: 0x%x";
		const long[1] memCurrentAddrValues = [
			cast(long) LinearAllocator.getCurrentMemoryPosition
		];
		Kstdio.kprintfln(memCurrentFormat, memCurrentAddrValues);

		const long memUsedValue = LinearAllocator.getCurrentMemoryPosition
			- LinearAllocator.getMemoryStart;
		const long[1] memUsedValues = [memUsedValue];
		Kstdio.kprintfln(memUsedFormat, memUsedValues);
	}
}

private void runSimpleGameCommand(immutable(Cli.CliCommand) cmd, immutable(char[]) args)
{
	runSimpleGame;
}

private void runSimpleGame()
{
	Display.disableCursor;
	Cli.disableCli;
	Display.clearScreen;
	SimpleGame.gameRun;
	isGame = true;
}

private void dateTimeCommand(immutable(Cli.CliCommand) cmd, immutable(char[]) args)
{
	Date.printDateTime;
}

private void infoCommand(immutable(Cli.CliCommand) cmd, immutable(char[]) args)
{
	import os.core.io.cpuid;

	const char[12] vendorInfo;
	readCpuidVendor(cast(uint*) vendorInfo.ptr);

	const string[1] vendorInfoParts = [cast(string) vendorInfo];

	Kstdio.kprintln;
	Kstdio.kprintf("Vendor: %s", vendorInfoParts);
	Kstdio.kprintln;
}

private void calcCommand(immutable(Cli.CliCommand) cmd, immutable(char[]) args)
{
	const long result = Calc.calc(args);

	const long[1] resultParts = [result];

	Kstdio.kprintln;
	Kstdio.kprintf("%l", resultParts);
	Kstdio.kprintln;
}

private void paintCommand(immutable(Cli.CliCommand) cmd, immutable(char[]) args)
{
	alias Painter = os.core.sys.paint;

	if (args.length == 0)
	{
		return;
	}

	const char firstArg = args[0];
	Kstdio.kprintln;
	switch (firstArg)
	{
	case 's':
		Painter.drawSierpinski(8);
		break;
	case 'c':
	    Painter.drawCircle(5);
		break;
	default:
	}
}

extern (C) __gshared void runInterruptServiceRoutine(const ulong num, const ulong err)
{
	switch (num)
	{
	case Isr.EXCEPTION.PAGE_FAULT:
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
	case Irq.IRQs.TIMER:

		UptimeTimer.updateTimer();

		//TODO move
		if (isGame)
		{
			SimpleGame.gameUpdate;
		}
		break;
	case Irq.IRQs.KEYBOARD:
		scanCode;
		break;
	default:
	}

	if (num >= 40)
	{
		Pic.sendEndPIC2;
	}
	Pic.sendEndPIC1;
}

private void scanCode()
{
	immutable ubyte keyCode = Keyboard.scanKeyCode;
	immutable char k = Keyboard.getKeyByCode(keyCode);
	if (Keyboard.isReleased(k) || k == 0 || keyCode == 0) // k == '\?' 
	{
		return;
	}

	if (isGame)
	{
		//TODO move to context
		SimpleGame.gameUpdate(k);
		if (k == 'q' || k == 'Q')
		{
			SimpleGame.gameStop;
			isGame = false;
			Display.clearScreen;
			Cli.enableCli;
			Cli.printCmd;
		}
		return;
	}

	if (Cli.isCliEnabled)
	{
		Cli.applyForCli(k);
	}
}
