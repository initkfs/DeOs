module os.core.workers.kworker;

import os.core.io.kstdio;

struct KWorker
{
    private void function(immutable(ubyte) keyCode, immutable(char) keySymbol) onInput;
    private void function() onExit;
    private void function() onRun;

    this(void function() onRun, void function() onExit,
            void function(immutable(ubyte) keyCode, immutable(char) keySymbol) onInput)
    {
        this.onRun = onRun;
        this.onExit = onExit;
        this.onInput = onInput;
    }

    void input(immutable(ubyte) keyCode, immutable(char) keySymbol)
    {
        this.onInput(keyCode, keySymbol);
    }

    void exit()
    {
        this.onExit();
    }

    void run()
    {
       this.onRun();
    }
}
