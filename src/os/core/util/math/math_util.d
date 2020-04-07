/**
 * Authors: initkfs
 */
module os.core.util.math.math_util;

import std.traits : isFloatingPoint;

real sqrt(real value)
{
    if (value == 0)
    {
        return 0;
    }

    if (value < 0)
    {
        return real.nan;
    }
    asm
    {
        fld value;
        fsqrt;
    }
}

long pow(const long base, const long exponent) pure @safe nothrow
{
    //0^0 must be an error
    if (base == 0)
    {
        return 0;
    }

    //TODO compare safe
    if (exponent == 0)
    {
        return 1;
    }

    if (exponent == 1)
    {
        return base;
    }

    if (exponent % 2 == 0)
    {
        const long powPreCalc = pow(base, exponent / 2);
        return powPreCalc * powPreCalc;
    }

    return pow(base, exponent - 1) * base;
}

unittest
{
    import os.core.util.assertions_util;

    kassert(pow(0, 0) == 0);
    kassert(pow(1, 0) == 1);
    kassert(pow(1, 2) == 1);
    kassert(pow(2, 0) == 1);
    kassert(pow(2, 1) == 2);
    kassert(pow(2, 2) == 4);
    kassert(pow(2, 3) == 8);
    kassert(pow(2, 17) == 131_072);
    kassert(pow(2, 23) == 8_388_608);

    //TODO isNaN
    //kassert(sqrt(-9));
    kassert(sqrt(0) == 0);
    kassert(sqrt(1) == 1);
    kassert(sqrt(4) == 2);
    kassert(sqrt(169) == 13);

}
