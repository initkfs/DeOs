/**
 * Authors: initkfs
 */
module os.core.sys.date.stdate;

import os.core.io.kstdio;
import os.core.io.ports;
import os.core.io.interrupt.irq;

//https://wiki.osdev.org/CMOS

// private string[7] days = [
//     "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"
// ];

// private string[12] months = [
//     "January", "February", "March", "April", "May", "June", "July", "August",
//     "September", "October", "November", "December"
// ];

private struct DateTimeRawInfo
{
    ubyte year;
    ubyte month;
    ubyte day;
    ubyte hour;
    ubyte minute;
    ubyte second;

    this(const ubyte year, const ubyte month, const ubyte day, const ubyte hour,
            const ubyte minute, const ubyte second)
    {
        //TODO validate
        this.year = year;
        this.month = month;
        this.day = day;
        this.hour = hour;
        this.minute = minute;
        this.second = second;
    }
}

private
{
    __gshared ubyte cmos_address = 0x70;
    __gshared ubyte cmos_data = 0x71;
}

private ubyte readFromRTCRegister(const ubyte reg)
{
    writeToPortByte(cmos_address, reg);
    immutable ubyte rtcValue = readFromPort!ubyte(cmos_data);
    return rtcValue;
}

private DateTimeRawInfo readRealTimeClock()
{
    immutable ubyte year = readFromRTCRegister(0x09);
    immutable ubyte month = readFromRTCRegister(0x08);
    immutable ubyte day = readFromRTCRegister(0x07);

    immutable ubyte hour = readFromRTCRegister(0x04);
    immutable ubyte minute = readFromRTCRegister(0x02);
    immutable ubyte second = readFromRTCRegister(0x00);

    immutable dt = DateTimeRawInfo(year, month, day, hour, minute, second);
    return dt;
}

void printDateTime()
{

    //disableInterrupts();
    DateTimeRawInfo dt = readRealTimeClock();
    //enableInterrupts();

    ubyte[6] dtInfo = [dt.year, dt.month, dt.day, dt.hour, dt.minute, dt.second];

    kprintln();
    //TODO format lead zero, full year, etc
    kprintfln!ubyte("%x-%x-%x %x-%x-%x", dtInfo);
}
