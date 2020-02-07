/**
 * Authors: initkfs
 */
module os.core.timer.uptime_timer;

private __gshared ulong uptimeTick;

void updateTimer(){
    uptimeTick++;
}

ulong getUptimeTick(){
    return uptimeTick;
}