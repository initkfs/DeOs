module os.core.sys.cli;

import os.core.graphic.display;
import os.core.io.kstdio;

private
{
    __gshared ubyte[100] shellCommandBuffer = [];
    __gshared bool isActiveShell = false;
    __gshared ubyte[100] cliCommandBuffer = [];
}

//TODO remove public access
public __gshared CliCommand[6] cliCommands;

struct CliCommand
{
    string name;
    string desctiption;
    void function(immutable(CliCommand) cmd, immutable(char[]) args) action;

    this(string name, string desctiption, void function(immutable(CliCommand),
            immutable(char[]) args) action)
    {
        this.name = name;
        this.desctiption = desctiption;
        this.action = action;
    }
}

void enableCli()
{
    isActiveShell = true;
}

void disableCli()
{
    isActiveShell = false;
}

bool isCliEnabled()
{
    return isActiveShell;
}

void printCmd()
{
    enableCursor;
    kprint("$>");
}

private void printHelp()
{
    disableCursor;
    kprintln;
    kprintln("Available commands:");
    foreach (int index, CliCommand cmd; cliCommands)
    {
        string[2] cmdInfo = [cmd.name, cmd.desctiption];
        kprintfln!string("%s - %s", cmdInfo);
    }

    printCmd;
}

void applyForCli(char k)
{
    if (k == '\n' && isActiveShell)
    {
        for (int i = 0; i < cliCommandBuffer.length; i++)
        {
            if (cliCommandBuffer[i] == 0u || cliCommandBuffer[i] == ' ')
            {

                if (i == 0)
                {
                    //command is empty
                    return;
                }

                disableCursor;
                parseAndRunCommand(cliCommandBuffer[0 .. i], cliCommandBuffer[i .. $]);
                break;
            }
        }

        for (int i = 0; i < cliCommandBuffer.length; i++)
        {
            cliCommandBuffer[i] = 0u;
        }

        if (isCliEnabled)
        {
            printCmd;
        }
    }
    else if (k == '\t' && isActiveShell)
    {
        printHelp;
    }
    else if (isActiveShell)
    {
        enableCursor;
        for (int i = 0; i < cliCommandBuffer.length; i++)
        {
            immutable ubyte c = cliCommandBuffer[i];
            if (c == 0u)
            {
                cliCommandBuffer[i] = k;
                break;
            }
        }
        char[1] charStr = [k];
        kprint(cast(string) charStr);
    }
}

private void parseAndRunCommand(ubyte[] command, ubyte[] args)
{

    immutable(string) commandStr = cast(immutable(string)) command;
    immutable(char[]) argsArray = cast(immutable(char[])) args;

    outer: foreach (size_t index, ref CliCommand cmd; cliCommands)
    {

        immutable cliCommandName = cmd.name;

        if (cliCommandName.length != command.length)
        {
            continue;
        }
        else
        {
            for (int ii = 0; ii < cliCommandName.length; ii++)
            {
                if (cliCommandName[ii] != command[ii])
                {
                    continue outer;
                }
            }
        }

        auto onAction = cmd.action;
        onAction(cmd, argsArray);
        return;
    }

    kprintln;
    string[1] invalidCommand = [commandStr];
    kprintfln!string("Not found command: %s", invalidCommand);
}
