/**
 * Authors: initkfs
 */
module os.core.io.interrupt.irq;

private {
	alias Ports = os.core.io.ports;
	alias Idt = os.core.io.interrupt.idt;
	alias Pic = os.core.io.interrupt.pic;
}

/*
* https://wiki.osdev.org/Interrupts
*/
enum IRQs
{
	TIMER,
	KEYBOARD,
	CASCADE, //Cascade (used internally by the two PICs. never raised)
	COM2,
	COM1,
	LPT2,
	FLOPPY,
	LPT1,
	CMOS_RTC, //CMOS real-time clock (if enabled)
	PERIPHERAL1,
	PERIPHERAL2,
	PERIPHERAL3,
	PS2MOUSE,
	FPU_COPROCESSOR, //FPU / Coprocessor / Inter-processor
	ATA1, //Primary ATA Hard Disk
	ATA2 //Secondary ATA Hard Disk
}

extern (C) __gshared void irq0();
extern (C) __gshared void irq1();
extern (C) __gshared void irq2();
extern (C) __gshared void irq3();
extern (C) __gshared void irq4();
extern (C) __gshared void irq5();
extern (C) __gshared void irq6();
extern (C) __gshared void irq7();
extern (C) __gshared void irq8();
extern (C) __gshared void irq9();
extern (C) __gshared void irq10();
extern (C) __gshared void irq11();
extern (C) __gshared void irq12();
extern (C) __gshared void irq13();
extern (C) __gshared void irq14();
extern (C) __gshared void irq15();

extern (C) __gshared void isr128();

//https://wiki.osdev.org/Interrupts_tutorial
private void remapIRQs()
{
	Ports.writeToPortByte(Pic.PIC1_COMMAND, 0x11);
	Ports.writeToPortByte(Pic.PIC2_COMMAND, 0x11);
	Ports.writeToPortByte(Pic.PIC1_DATA, 0x20);
	Ports.writeToPortByte(Pic.PIC2_DATA, 0x28);
	Ports.writeToPortByte(Pic.PIC1_DATA, 0x04);
	Ports.writeToPortByte(Pic.PIC2_DATA, 0x02);
	Ports.writeToPortByte(Pic.PIC1_DATA, 0x01);
	Ports.writeToPortByte(Pic.PIC2_DATA, 0x01);
	Ports.writeToPortByte(Pic.PIC1_DATA, 0x00);
	Ports.writeToPortByte(Pic.PIC2_DATA, 0x00);
}

void setIRQs()
{
	remapIRQs;

	Idt.addGateToIDT(32, cast(size_t)&irq0, 0x08, 0x8E);
	Idt.addGateToIDT(33, cast(size_t)&irq1, 0x08, 0x8E);
	Idt.addGateToIDT(34, cast(size_t)&irq2, 0x08, 0x8E);
	Idt.addGateToIDT(35, cast(size_t)&irq3, 0x08, 0x8E);
	Idt.addGateToIDT(36, cast(size_t)&irq4, 0x08, 0x8E);
	Idt.addGateToIDT(37, cast(size_t)&irq5, 0x08, 0x8E);
	Idt.addGateToIDT(38, cast(size_t)&irq6, 0x08, 0x8E);
	Idt.addGateToIDT(39, cast(size_t)&irq7, 0x08, 0x8E);
	Idt.addGateToIDT(40, cast(size_t)&irq8, 0x08, 0x8E);
	Idt.addGateToIDT(41, cast(size_t)&irq9, 0x08, 0x8E);
	Idt.addGateToIDT(42, cast(size_t)&irq10, 0x08, 0x8E);
	Idt.addGateToIDT(43, cast(size_t)&irq11, 0x08, 0x8E);
	Idt.addGateToIDT(44, cast(size_t)&irq12, 0x08, 0x8E);
	Idt.addGateToIDT(45, cast(size_t)&irq13, 0x08, 0x8E);
	Idt.addGateToIDT(46, cast(size_t)&irq14, 0x08, 0x8E);
	Idt.addGateToIDT(47, cast(size_t)&irq15, 0x08, 0x8E);
}

// void sendInerruptEnd(unsigned char irq)
// {
// 	if(irq >= 8)
// 		outb(PIC2_COMMAND,PIC_EOI);

// 	outb(PIC1_COMMAND,PIC_EOI);
// }

@safe void enableInterrupts(){
	asm @trusted {
		sti;
	}
}

@safe void disableInterrupts(){
	asm @trusted {
		sti;
	}
}
