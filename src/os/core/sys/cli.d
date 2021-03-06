/**
 * Authors: initkfs
 */
module os.core.sys.cli;

private {
    alias Display = os.core.graphic.display;
    alias Kstdio = os.core.io.kstdio;
}

private
{
    __gshared ubyte[100] shellCommandBuffer = [];
    __gshared bool isActiveShell = false;
    __gshared ubyte[100] cliCommandBuffer = [];
    __gshared ubyte cliPromptColor = Display.CGAColors.DEFAULT_TEXT_COLOR;
    __gshared ubyte cliErrorColor = Display.CGAInfoColors.COLOR_ERROR;
    __gshared ubyte cliInfoColor = Display.CGAColors.DEFAULT_TEXT_COLOR;
}

//TODO remove public access
public __gshared CliCommand[8] cliCommands;

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

void setCliPromptColor(const ubyte color){
    cliPromptColor = color;
}

void setCliErrorColor(const ubyte color){
    cliErrorColor = color;
}

void setCliInfoColor(const ubyte color){
    cliInfoColor = color;
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
    Display.enableCursor;
    Kstdio.kprint("$>", cliPromptColor);
}

private void printHelp()
{
    Display.disableCursor;
    Kstdio.kprintln;
    Kstdio.kprintln("Available commands:", cliInfoColor);
    foreach (int index, CliCommand cmd; cliCommands)
    {
        string[2] cmdInfo = [cmd.name, cmd.desctiption];
        Kstdio.kprintfln!string("%s - %s", cmdInfo, cliInfoColor);
    }

    printCmd;
}

void applyForCli(char k)
{
    if (k == '\n' && isActiveShell)
    {
        int commandEndPosition = 0;
        for (int i = 0; i < cliCommandBuffer.length; i++)
        {
            if(cliCommandBuffer[i] == ' ' && commandEndPosition == 0){
                commandEndPosition = i;
                continue;
            }
            
            if (cliCommandBuffer[i] == 0u)
            {

                if (i == 0)
                {
                    //command is empty
                    return;
                }

                Display.disableCursor;
                commandEndPosition = commandEndPosition == 0 ? i : commandEndPosition;
                parseAndRunCommand(cliCommandBuffer[0 .. commandEndPosition], cliCommandBuffer[commandEndPosition + 1 .. i]);
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
        Display.enableCursor;
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
        Kstdio.kprint(cast(string) charStr);
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

    Kstdio.kprintln;
    string[1] invalidCommand = [commandStr];
    Kstdio.kprintfln!string("Not found command: %s", invalidCommand, cliErrorColor);
}
