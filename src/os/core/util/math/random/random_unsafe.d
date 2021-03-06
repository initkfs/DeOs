/**
 * Authors: initkfs
 */
module os.core.util.math.random.random_unsafe;

import os.core.util.math.random.random_intervals_util;

private __gshared ulong next = 11_111;

uint randUnsafe(uint minInclusive = 0, uint maxInclusive = 0)
{
    next = next * 1_103_515_245 + 12_345;
    uint result =  cast(uint)(next / 65_536) % 32_768;
    
    if(minInclusive == 0 && maxInclusive == 0){
        return result;
    }

    if(minInclusive > maxInclusive){
        return result;
    }

    const uint inIntervalResult = toClosedInterval!uint(result, minInclusive, maxInclusive);
    return inIntervalResult;
}

void srandUnsafe(uint seed)
{
    next = cast(uint) seed % 32768;
}
