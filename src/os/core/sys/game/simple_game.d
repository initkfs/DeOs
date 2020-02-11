/**
 * Authors: initkfs
 */
module os.core.sys.game.simple_game;

private {
    alias Display = os.core.graphic.display;
    alias Kstdio = os.core.io.kstdio;
    alias LinearAllocator = os.core.memory.allocators.linear;
}

private __gshared bool isRunning = false;
private __gshared enum playerStartXPosition = 40;
private __gshared enum playerStartYPosition = 10;

private __gshared long playerXPosition = playerStartXPosition;
private __gshared long playerYPosition = playerStartYPosition;

private __gshared Enemy[8] enemies;

private struct Enemy
{
    private ulong* enemyXPosition;
    private ulong* enemyYPosition;

    this(ulong* startX, ulong* startY)
    {
        enemyXPosition = startX;
        enemyYPosition = startY;
    }

    long enemyX()
    {
        return *enemyXPosition;
    }

    long enemyY()
    {
        return *enemyYPosition;
    }

    void setEnemyX(long x)
    {
        *enemyXPosition = x;
    }

    void setEnemyY(long x)
    {
        *enemyYPosition = x;
    }
}

void gameRun()
{
    long startEnemyX = 5;
    for (int i = 0; i < enemies.length; i++)
    {
        ulong* enemyXPtr = LinearAllocator.allocLinearQword;
        ulong* enemyYPtr = LinearAllocator.allocLinearQword;
        *enemyXPtr = startEnemyX;
        *enemyYPtr = 0;
        enemies[i] = Enemy(enemyXPtr, enemyYPtr);
        startEnemyX += 10;
    }

    isRunning = true;
}

void gameStop()
{
    isRunning = false;
}

private void setPlayerInStartPosition()
{
    playerXPosition = playerStartXPosition;
    playerYPosition = playerStartYPosition;
}

private bool isEnemyAndPlayerTogether()
{
    foreach (Enemy enemy; enemies)
    {
        long enemyX = enemy.enemyX;
        long enemyY = enemy.enemyY;
        bool isKill = playerXPosition == enemyX && playerYPosition == enemyY;
        if (isKill)
        {
            return true;
        }
    }

    return false;
}

void gameUpdate(char keyboardKey = '?')
{
    if (!isRunning)
    {
        if (keyboardKey == 'c' || keyboardKey == 'C')
        {
            isRunning = true;
            setPlayerInStartPosition;
        }
        else
        {
            return;
        }
    }

    Display.clearScreen;

    if (keyboardKey == 'D' || keyboardKey == 'd')
    {
        playerXPosition++;
    }
    else if (keyboardKey == 'A' || keyboardKey == 'a')
    {
        playerXPosition--;
    }
    else if (keyboardKey == 'w' || keyboardKey == 'W')
    {
        playerYPosition--;
    }
    else if (keyboardKey == 's' || keyboardKey == 'S')
    {
        playerYPosition++;
    }

    //TODO scene matrix [][]
    long columns = Display.TextDisplay.DISPLAY_COLUMNS;
    long lines = Display.TextDisplay.DISPLAY_LINES;

    playerXPosition = clamp!long(playerXPosition, 0, columns - 1);
    playerYPosition = clamp!long(playerYPosition, 0, 20 - 1);

    foreach (Enemy enemy; enemies)
    {
        ulong* enemyYPosPtr = enemy.enemyYPosition;
        long enemyY = *enemyYPosPtr;
        enemyY++;
        *enemy.enemyYPosition = enemyY;
        if (enemyY > lines - 1)
        {
            *enemy.enemyYPosition = 0;
        }

        *enemy.enemyXPosition = clamp!long(*enemy.enemyXPosition, 0, columns - 1);
        *enemy.enemyYPosition = clamp!long(*enemy.enemyYPosition, 0, lines - 1);
    }

    if (playerXPosition == 0 || playerXPosition == Display.TextDisplay.DISPLAY_COLUMNS - 1)
    {
        gameEnd;
        return;
    }

    if (isEnemyAndPlayerTogether)
    {
        gameOver;
        return;
    }

    foreach (long currentLine; 0 .. lines)
    {
        eachColumn: foreach (long currentColumn; 0 .. columns)
        {
            foreach (Enemy enemy; enemies)
            {
                if (currentColumn == enemy.enemyX && currentLine == enemy.enemyY)
                {
                    Kstdio.kprint("|");
                    continue eachColumn;
                }
            }

            if (currentColumn == playerXPosition && currentLine == playerYPosition)
            {
                Kstdio.kprint("+");
            }
            else
            {
                Display.skipColumn;
            }

        }
        Display.newLine;
    }
}

private void gameEnd()
{
    Display.clearScreen;
    Kstdio.kprintln("Congratulations! You won the game!");
    gameStop;
}

private void gameOver()
{
    Display.clearScreen;
    Kstdio.kprintln("Game over");
    gameStop;
}

private T clamp(T)(T val, T min, T max) if (__traits(isArithmetic, T))
{
    if (val < min)
    {
        return min;
    }
    else if (val > max)
    {
        return max;
    }

    return val;
}
