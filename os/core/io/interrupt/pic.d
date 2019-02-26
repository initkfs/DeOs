/**
 * Authors: initkfs
 */
module os.core.io.interrupt.pic;
import os.core.io.ports;

//https://wiki.osdev.org/8259_PIC
//TODO APIC https://wiki.osdev.org/APIC
enum PIC1 = 0x20;
enum PIC2 = 0xA0;
enum PIC1_COMMAND	= PIC1;
enum PIC1_DATA		= PIC1+1;
enum PIC2_COMMAND	= PIC2;
enum PIC2_DATA		= PIC2+1;

enum PICEnd			= 0x20; /* End-of-interrupt command code */

enum Timer0		= 0x40;
enum Timer1 	= 0x41;
enum Timer2 	= 0x42;
enum TimerMode	= 0x43;

void sendEndPIC1(){
    writeToPortByte(PIC1_COMMAND, PICEnd);
}

void sendEndPIC2(){
    writeToPortByte(PIC2_COMMAND, PICEnd);
}