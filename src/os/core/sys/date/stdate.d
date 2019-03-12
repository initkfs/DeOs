/**
 * Authors: initkfs
 */
module os.core.sys.date.stdate;

import os.core.util.conversion_util;

//https://wiki.osdev.org/CMOS

import os.core.io.ports;

// private string[7] days = [
//     "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"
// ];

// private string[12] months = [
//     "January", "February", "March", "April", "May", "June", "July", "August",
//     "September", "October", "November", "December"
// ];

struct DateTimeRawInfo
{
    ubyte year;
    ubyte month;
    ubyte day;
    ubyte hour;
    ubyte minute;
    ubyte second;

    this(ubyte year, ubyte month, ubyte day, ubyte hour, ubyte minute, ubyte second)
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

private __gshared ubyte cmos_address = 0x70;
private __gshared ubyte cmos_data = 0x71;

private ubyte readFromRTCRegister(ubyte reg)
{
    writeToPortByte(cmos_address, reg);
    const ubyte rtcValue = readFromPort!ubyte(cmos_data);
    return rtcValue;
}

private DateTimeRawInfo readRealTimeClock()
{
    const ubyte year = readFromRTCRegister(0x09);
    const ubyte month = readFromRTCRegister(0x08);
    const ubyte day = readFromRTCRegister(0x07);

    const ubyte hour = readFromRTCRegister(0x04);
    const ubyte minute = readFromRTCRegister(0x02);
    const ubyte second = readFromRTCRegister(0x00);

    auto dt = DateTimeRawInfo(year, month, day, hour, minute, second);
    return dt;
}
