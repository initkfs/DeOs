module os.core.sys.game.simple_game;

import os.core.graphic.display;
import os.core.io.kstdio;

private __gshared bool isRunning = false;
private __gshared enum playerStartXPosition = 40;
private __gshared enum playerStartYPosition = 10;

private __gshared size_t playerXPosition = playerStartXPosition;
private __gshared size_t playerYPosition = playerStartYPosition;

private __gshared Enemy[1] enemies;

private __gshared size_t currentTick = 0;

private struct Enemy
{
    __gshared size_t enemyXPosition = 0;
    __gshared size_t enemyYPosition = 0;

    this(size_t startX, size_t startY)
    {
        enemyXPosition = startX;
        enemyYPosition = startY;
    }
}

void gameRun()
{
    enemies[0] = Enemy(45, 0);
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
        size_t enemyX = enemy.enemyXPosition;
        size_t enemyY = enemy.enemyYPosition;
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
            if (isEnemyAndPlayerTogether())
            {
                setPlayerInStartPosition;
            }
        }
        else
        {
            return;
        }
    }

    currentTick++;

    clearScreen;

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
    size_t columns = TextDisplay.DISPLAY_COLUMNS;
    size_t lines = TextDisplay.DISPLAY_LINES;

    playerXPosition = clamp!size_t(playerXPosition, 0, columns - 1);
    playerYPosition = clamp!size_t(playerYPosition, 0, 20 - 1);

    foreach (Enemy enemy; enemies)
    {
        enemy.enemyYPosition++;
        if (enemy.enemyYPosition > lines - 1)
        {
            enemy.enemyYPosition = 0;
        }

        enemy.enemyXPosition = clamp!size_t(enemy.enemyXPosition, 0, columns - 1);
        enemy.enemyYPosition = clamp!size_t(enemy.enemyYPosition, 0, lines - 1);
    }

    if (isEnemyAndPlayerTogether)
    {
        gameEnd;
        return;
    }

    foreach (size_t currentLine; 0 .. lines)
    {
        eachColumn: foreach (size_t currentColumn; 0 .. columns)
        {
            foreach (Enemy enemy; enemies)
            {
                if (currentColumn == enemy.enemyXPosition && currentLine == enemy.enemyYPosition)
                {
                    kprint("|");
                    continue eachColumn;
                }
            }

            if (currentColumn == playerXPosition && currentLine == playerYPosition)
            {
                kprint("+");
            }
            else
            {
                skipColumn;
            }

        }
        newLine;
    }
}

private void gameEnd()
{
    clearScreen;
    kprintln("Game end");
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
