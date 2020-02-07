/**
 * Authors: initkfs
 */
module os.core.timer.pause_timer;

private
{
    alias UptimeTimer = os.core.timer.uptime_timer;
    __gshared ulong shortPauseTicks = 10;
}

void pauseInTicks(const ulong ticksCount)
{
    //TODO overflow
    ulong newValue = UptimeTimer.getUptimeTick + ticksCount;
    while (UptimeTimer.getUptimeTick < newValue)
    {

    }
}

void pauseShort()
{
    pauseInTicks(shortPauseTicks);
}
