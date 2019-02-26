/**
 * Authors: initkfs
 */
module os.kernel;

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

extern(C) __gshared ulong KERNEL_END;

private __gshared bool isActiveShell = false;
private __gshared ubyte[100] shellCommand = [];

extern (C) void kmain(uint magic, size_t *multibootInfoAddress)
{
	disableCursor();
	kprintln("DeOs. Version: 0.1a. Author: inikfs");

	size_t* memoryStart = cast(size_t*)&KERNEL_END;
	//TODO parse page tables
	size_t* memoryEnd = cast(size_t*) (0x200 * 0x32 * 0x1000 + memoryStart);

	//Initialize linear allocator
	setMemoryCursorStart(memoryStart);
	setMemoryCursorEnd(memoryEnd);

	setISRs();
	setIRQs();
	setIDT();
}

//Bochs and old Qemu versions
private void powerOff(){
	string s = "Shutdown";
	foreach(char ss; s) {
		ubyte b = cast(ubyte) ss;
		writeToPortByte(0x8900, b);
	}
}

public extern(C) __gshared void runInterruptServiceRoutine(ulong num, ulong err)
{
	switch(num)
	{
		case EXCEPTION.PAGE_FAULT:
			break;
		default:
	}
}

public extern(C) __gshared void runInterruptRequest(ulong num, ulong err)
{
	//irqs 0-15 are mapped to interrupt service routines 32-47
	uint irq = cast(uint)num - 32;

	switch(irq){
		case IRQs.TIMER:
			break;
		case IRQs.KEYBOARD:
			scanCode();
			break;
		default:
	}

	if(num >= 40) {
		sendEndPIC2();
	}

	sendEndPIC1();
}

private void scanCode(){
	
	char k = scanKey();
	    if(isReleased(k) || k == '\?' || k == 0){
			return;
		}

		if(k == '`'){
			isActiveShell = true;
			//foreach(int i; shellCommand){
			for(int i = 0; i< shellCommand.length; i++){
				shellCommand[i] = 0u;
			}
			kprintln("Shell has started. Enter the command");
			kprint("$>");
			enableCursor();
		} else if(k == '\n' && isActiveShell){
			isActiveShell = false;
			disableCursor();
			for(int i = 0; i< shellCommand.length; i++){
				if(shellCommand[i] == 0u){
					parseAndRunCommand(shellCommand[0..i]);
					break;
				}
			}
		} else if(isActiveShell){
			for(int i = 0; i< shellCommand.length; i++) {
				ubyte c = shellCommand[i];
				if(c == 0u){
					shellCommand[i] = k;
					break;
				}
			}
			char[1] charStr = [k];
			kprint(cast(string) charStr);
			}
}

private void parseAndRunCommand(ubyte[] command){

	string commandStr = cast(string) command;

	if("exit" == command){
		powerOff;
	}else {
		kprintln("");
		string[1] invalidCommand = [commandStr];
		kprintfln!string("Not found command: %s", invalidCommand);
	}
}
