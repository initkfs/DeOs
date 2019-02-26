/**
 * Authors: initkfs
 */
 module os.core.io.interrupt.isr;

 import os.core.io.interrupt.idt;

 /*
* https://wiki.osdev.org/Exceptions
*/
enum EXCEPTION
{
	DIVIDE_BY_ZERO,
	DEBUG,
	NMI,
	BREAKPOINT,
	OVERFLOW,
	BOUND_RANGE_EXCEED,
	INVALID_OPCODE,
	DEVICE_NOT_AVAILABLE,
	DOUBLE_FAULT,
	SEGMENT_OVERRUN,
	INVALID_TSS,
	SEGMENT_NOT_PRESENT,
	STACK_SEGMENT_FAULT,
	GENERAL_PROTECTION_FAULT,
	PAGE_FAULT,
	RESERVED,
	FP_EXCEPTION,
	ALIGNMENT_CHECK,
	MACHINE_CHECK,
	SIMD_FP_EXCEPTION,
	VIRTUALIZATION_EXCEPTION
}

extern(C) __gshared void isr0();
extern(C) __gshared void isr1();
extern(C) __gshared void isr2();
extern(C) __gshared void isr3();
extern(C) __gshared void isr4();
extern(C) __gshared void isr5();
extern(C) __gshared void isr6();
extern(C) __gshared void isr7();
extern(C) __gshared void isr8();
extern(C) __gshared void isr9();
extern(C) __gshared void isr10();
extern(C) __gshared void isr11();
extern(C) __gshared void isr12();
extern(C) __gshared void isr13();
extern(C) __gshared void isr14();
extern(C) __gshared void isr15();
extern(C) __gshared void isr16();
extern(C) __gshared void isr17();
extern(C) __gshared void isr18();
extern(C) __gshared void isr19();
extern(C) __gshared void isr20();
extern(C) __gshared void isr21();
extern(C) __gshared void isr22();
extern(C) __gshared void isr23();
extern(C) __gshared void isr24();
extern(C) __gshared void isr25();
extern(C) __gshared void isr26();
extern(C) __gshared void isr27();
extern(C) __gshared void isr28();
extern(C) __gshared void isr29();
extern(C) __gshared void isr30();
extern(C) __gshared void isr31();

extern(C) __gshared void isr128();

void setISRs()
{
	addGateToIDT(0, cast(size_t)&isr0, 0x08, 0x8E);	//0x08 = kernel code segment, 0x8E = interrupt present, type = interrupt gate
	addGateToIDT(1, cast(size_t)&isr1, 0x08, 0x8E);
	addGateToIDT(2, cast(size_t)&isr2, 0x08, 0x8E);
	addGateToIDT(3, cast(size_t)&isr3, 0x08, 0x8E);
	addGateToIDT(4, cast(size_t)&isr4, 0x08, 0x8E);
	addGateToIDT(5, cast(size_t)&isr5, 0x08, 0x8E);
	addGateToIDT(6, cast(size_t)&isr6, 0x08, 0x8E);
	addGateToIDT(7, cast(size_t)&isr7, 0x08, 0x8E);
	addGateToIDT(8, cast(size_t)&isr8, 0x08, 0x8E);
	addGateToIDT(9, cast(size_t)&isr9, 0x08, 0x8E);
	addGateToIDT(10, cast(size_t)&isr10, 0x08, 0x8E);
	addGateToIDT(11, cast(size_t)&isr11, 0x08, 0x8E);
	addGateToIDT(12, cast(size_t)&isr12, 0x08, 0x8E);
	addGateToIDT(13, cast(size_t)&isr13, 0x08, 0x8E);
	addGateToIDT(14, cast(size_t)&isr14, 0x08, 0x8E);
	addGateToIDT(15, cast(size_t)&isr15, 0x08, 0x8E);
	addGateToIDT(16, cast(size_t)&isr16, 0x08, 0x8E);
	addGateToIDT(17, cast(size_t)&isr17, 0x08, 0x8E);
	addGateToIDT(18, cast(size_t)&isr18, 0x08, 0x8E);
	addGateToIDT(19, cast(size_t)&isr19, 0x08, 0x8E);
	addGateToIDT(20, cast(size_t)&isr20, 0x08, 0x8E);
	addGateToIDT(21, cast(size_t)&isr21, 0x08, 0x8E);
	addGateToIDT(22, cast(size_t)&isr22, 0x08, 0x8E);
	addGateToIDT(23, cast(size_t)&isr23, 0x08, 0x8E);
	addGateToIDT(24, cast(size_t)&isr24, 0x08, 0x8E);
	addGateToIDT(25, cast(size_t)&isr25, 0x08, 0x8E);
	addGateToIDT(26, cast(size_t)&isr26, 0x08, 0x8E);
	addGateToIDT(27, cast(size_t)&isr27, 0x08, 0x8E);
	addGateToIDT(28, cast(size_t)&isr28, 0x08, 0x8E);
	addGateToIDT(29, cast(size_t)&isr29, 0x08, 0x8E);
	addGateToIDT(30, cast(size_t)&isr30, 0x08, 0x8E);
	addGateToIDT(31, cast(size_t)&isr31, 0x08, 0x8E);
	//syscall
	addGateToIDT(128, cast(size_t)&isr128, 0x08, 0x8E);
}