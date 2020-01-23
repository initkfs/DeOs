module os.core.sys.game.simple_game;

import os.core.graphic.display;
import os.core.io.kstdio;
import os.core.memory.allocators.linear;

private __gshared bool isRunning = false;
private __gshared enum playerStartXPosition = 40;
private __gshared enum playerStartYPosition = 10;

private __gshared size_t playerXPosition = playerStartXPosition;
private __gshared size_t playerYPosition = playerStartYPosition;

private __gshared Enemy[8] enemies;

private __gshared size_t currentTick = 0;

private struct Enemy
{
    private size_t* enemyXPosition;
    private size_t* enemyYPosition;

    this(size_t* startX, size_t* startY)
    {
        enemyXPosition = startX;
        enemyYPosition = startY;
    }

    size_t enemyX()
    {
        return *enemyXPosition;
    }

    size_t enemyY()
    {
        return *enemyYPosition;
    }

    void setEnemyX(size_t x)
    {
        *enemyXPosition = x;
    }

    void setEnemyY(size_t x)
    {
        *enemyYPosition = x;
    }
}

void gameRun()
{
    size_t startEnemyX = 5;
    for (int i = 0; i < enemies.length; i++)
    {
        size_t* enemyXPtr = allocLinearQword;
        size_t* enemyYPtr = allocLinearQword;
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
        size_t enemyX = enemy.enemyX;
        size_t enemyY = enemy.enemyY;
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
        size_t* enemyYPosPtr = enemy.enemyYPosition;
        size_t enemyY = *enemyYPosPtr;
        enemyY++;
        *enemy.enemyYPosition = enemyY;
        if (enemyY > lines - 1)
        {
            *enemy.enemyYPosition = 0;
        }

        *enemy.enemyXPosition = clamp!size_t(*enemy.enemyXPosition, 0, columns - 1);
        *enemy.enemyYPosition = clamp!size_t(*enemy.enemyYPosition, 0, lines - 1);
    }

    if (playerXPosition == 0 || playerXPosition == TextDisplay.DISPLAY_COLUMNS - 1)
    {
        gameEnd;
        return;
    }

    if (isEnemyAndPlayerTogether)
    {
        gameOver;
        return;
    }

    foreach (size_t currentLine; 0 .. lines)
    {
        eachColumn: foreach (size_t currentColumn; 0 .. columns)
        {
            foreach (Enemy enemy; enemies)
            {
                // size_t x = enemy.enemyY;
                // long[1] xx = [cast(long) x];
                // kprintfln("%l", xx);
                if (currentColumn == enemy.enemyX && currentLine == enemy.enemyY)
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
    kprintln("Congratulations! You won the game!");
    gameStop;
}

private void gameOver()
{
    clearScreen;
    kprintln("Game over");
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
