//
//  SnakeGameModel.m
//  SnakeGame-iOS
//
//  Created by Dilip Muthukrishnan on 13-11-25.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "SnakeGameModel.h"

@implementation SnakeGameModel

@synthesize level = _level;
@synthesize points = _points;
@synthesize speed = _speed;
@synthesize item = _item;
@synthesize pill = _pill;
@synthesize lengthOfSnake = _lengthOfSnake;
@synthesize direction = _direction;
@synthesize paused = _paused;
@synthesize mute = _mute;
@synthesize lives = _lives;

- (id) initWithView:(id)layer difficulty:(Difficulty)difficulty
{
    if (self = [super init])
    {
        _view = layer;
        if (difficulty == EASY)
        {
            acceleration = 1.0;
        }
        else if (difficulty == NORMAL)
        {
            acceleration = 1.25;
        }
        else if (difficulty == HARD)
        {
            acceleration = 1.5;
        }
    }
    return self;
}

// Reset the game back to square one.
- (void) resetGame
{
    self.level = 1;
    self.points = 0;
    self.lives = 10;
    [_view updateLabels];
    self.speed = 0.275;
    self.direction = FORWARD;
    // Set the position of the snake's head and initialize
    // the length of the snake to 1.
    snake[0] = ccp(20.0*1.0, 20.0*2.0);
    _lengthOfSnake = 1;
    [_view growSnake];
    // Extend the snake further.
    self.lengthOfSnake = 4;
    // This array needs to be updated repeatedly because each
    // update only incremets the snake's position by one square.
    for (int i = 0; i < self.lengthOfSnake; i++)
    {
        [self updateSnakeArray];
    }
    [self createItem];
    self.pill = ccp(-20.0, -20.0);
    [_view updateItems];
    [_view updateBackgroundWithFlash:NO];
}

// Pauses/continues the game
- (void) setPaused:(BOOL)option
{
    _paused = option;
    if (option)
    {
        [_view pauseSchedulerAndActions];
    }
    else
    {
        [_view resumeSchedulerAndActions];
    }
    [_view toggleDirectionArrows];
    [_view updateItems];
    [_view updateBackgroundWithFlash:NO];
}

// Change the speed of the snake's motion by doing more/less frequent updates.
- (void) setSpeed:(float)s
{
    _speed = s;
    [_view unschedule:@selector(update:)];
    [_view schedule:@selector(update:) interval:s];
}

// Grow the snake by the amount specified
- (void) setLengthOfSnake:(int)lengthOfSnake
{
    int increment = lengthOfSnake - _lengthOfSnake;
    // Only accept a bigger length
    if (increment)
    {
        for (int i = 0; i < increment; i++)
        {
            snake[_lengthOfSnake] = ccp(-20.0, -20.0);
            _lengthOfSnake++;
            [_view growSnake];
        }
    }
}

// This method was necessary because I didn't know how to declare
// the snake array as a property without converting it into an NSArray.
- (CGPoint) getSnakePieceAtIndex:(int)i
{
    return snake[i];
}

// Create a new item in a random location such that it does not
// actually touch the snake!
- (void) createItem
{
    CGPoint position;
    BOOL validPosition = NO;
    while (!validPosition)
    {
        int x = arc4random() % 14 + 1;
        int y = arc4random() % 21 + 2;
        position = ccp(20.0 * x, 20.0 * y);
        for (int j = 0; j < self.lengthOfSnake; j++)
        {
            if (position.x == snake[j].x && position.y == snake[j].y)
            {
                break;
            }
            else if (j == self.lengthOfSnake-1)
            {
                self.item = position;
                validPosition = YES;
            }
        }
    }
}

// Create a slow down pill; same logic as for creating an item, except
// don't position it in the same place as the item!
- (void) createSlowDownPill
{
    CGPoint position;
    BOOL validPosition = NO;
    while (!validPosition)
    {
        int x = arc4random() % 14 + 1;
        int y = arc4random() % 21 + 2;
        position = ccp(20.0 * x, 20.0 * y);
        if (position.x == self.item.x && position.y == self.item.y)
        {
            continue;
        }
        for (int j = 0; j < self.lengthOfSnake; j++)
        {
            if (position.x == snake[j].x && position.y == snake[j].y)
            {
                break;
            }
            else if (j == self.lengthOfSnake-1)
            {
                self.pill = position;
                validPosition = YES;
            }
        }
    }
    // Remove the slow down pill after ten seconds!
    [_view scheduleOnce:@selector(removeSlowDownPill) delay:10.0];
}

// Moves the snake ONE tile ahead in the current direction
- (void) updateSnakeArray
{
    for (int i = self.lengthOfSnake-1; i > 0; i--)
    {
        snake[i] = snake[i-1];
    }
    if (self.direction == FORWARD)
    {
        float x = snake[0].x + 20;
        float y = snake[0].y;
        snake[0] = ccp(x, y);
    }
    else if (self.direction == BACKWARD)
    {
        float x = snake[0].x - 20;
        float y = snake[0].y;
        snake[0] = ccp(x, y);
    }
    else if (self.direction == DOWNWARD)
    {
        float x = snake[0].x;
        float y = snake[0].y - 20;
        snake[0] = ccp(x, y);
    }
    else if (self.direction == UPWARD)
    {
        float x = snake[0].x;
        float y = snake[0].y + 20;
        snake[0] = ccp(x, y);
    }
    [_view updateSnake];
}

// Spawn snake from one of the walls after dying to give
// the player a proper chance to get out of impossible situations
// like dead-end self-intersections.
- (void) spawnSnakeFromBoundary
{
    // First, randomly pick a spawning direction
    Direction d = (Direction)arc4random() % 4;
    // Then, build the snake's tail in the opposite direction
    while (1)
    {
        int x, y;
        if (d == FORWARD)
        {
            x = 1;
            y = arc4random() % 21 + 2;
            for (int i = 1; i < self.lengthOfSnake; i++)
            {
                snake[i] = ccp(20.0 * (x-i), 20.0 * y);
            }
        }
        else if (d == BACKWARD)
        {
            x = 14;
            y = arc4random() % 21 + 2;
            for (int i = 1; i < self.lengthOfSnake; i++)
            {
                snake[i] = ccp(20.0 * (x+i), 20.0 * y);
            }
        }
        else if (d == UPWARD)
        {
            x = arc4random() % 14 + 1;
            y = 2;
            for (int i = 1; i < self.lengthOfSnake; i++)
            {
                snake[i] = ccp(20.0 * x, 20.0 * (y-i));
            }
        }
        else if (d == DOWNWARD)
        {
            x = arc4random() % 14 + 1;
            y = 22;
            for (int i = 1; i < self.lengthOfSnake; i++)
            {
                snake[i] = ccp(20.0 * x, 20.0 * (y+i));
            }
        }
        // Check if the position of the snake's head is valid
        CGPoint position = ccp(20.0 * x, 20.0 * y);
        if (position.x == self.item.x && position.y == self.item.y)
        {
            continue;
        }
        else if (position.x == self.pill.x && position.y == self.pill.y)
        {
            continue;
        }
        else
        {
            snake[0] = position;
            self.direction = d;
            [_view toggleDirectionArrows];
            [_view updateSnake];
            break;
        }
    }
}

// Update direction of snake motion based on touch location.  This code
// could definitely afford to be rewritten to make it less verbose!
- (void) updateDirectionWithTouch:(CGPoint)location
{
    if ((location.y > snake[0].y) && (snake[0].x != snake[1].x))
    {
        self.direction = UPWARD;
    }
    else if ((location.y < snake[0].y - 20.0) && (snake[0].x != snake[1].x))
    {
        self.direction = DOWNWARD;
    }
    else if ((location.x > snake[0].x + 20.0) && (snake[0].x > snake[1].x))
    {
        self.direction = FORWARD;
    }
    else if ((location.x < snake[0].x) && (snake[0].x < snake[1].x))
    {
        self.direction = BACKWARD;
    }
    else if ((location.x > snake[0].x + 20.0) && (snake[0].y != snake[1].y))
    {
        self.direction = FORWARD;
    }
    else if ((location.x < snake[0].x) && (snake[0].y != snake[1].y))
    {
        self.direction = BACKWARD;
    }
    else if ((location.y > snake[0].y + 20.0) && (snake[0].y > snake[1].y))
    {
        self.direction = UPWARD;
    }
    else if ((location.y < snake[0].y) && (snake[0].y < snake[1].y))
    {
        self.direction = DOWNWARD;
    }
}

// Update the state of the game at this moment
- (void) updateGameState
{
    // First, move the snake.
    [self updateSnakeArray];
    // The game is over if the snake runs into any of the walls.
    if (snake[0].x == 0.0 || snake[0].x == 300.0)
    {
        if (!self.mute)
        {
            [[SimpleAudioEngine sharedEngine] playEffect:@"gameover.wav"];
        }
        self.lives--;
        [_view updateLabels];
        [_view removeSlowDownPill];
        self.paused = YES;
        [_view displayAlertWithMessage:@"Boundary Reached"];
    }
    else if (snake[0].y == 20.0 || snake[0].y == 460.0)
    {
        if (!self.mute)
        {
            [[SimpleAudioEngine sharedEngine] playEffect:@"gameover.wav"];
        }
        self.lives--;
        [_view updateLabels];
        [_view removeSlowDownPill];
        self.paused = YES;
        [_view displayAlertWithMessage:@"Boundary Reached"];
    }
    // The game is over if the snake touches its own tail.
    for (int i = 1; i < self.lengthOfSnake; i++)
    {
        if (snake[0].x == snake[i].x && snake[0].y == snake[i].y)
        {
            if (!self.mute)
            {
                [[SimpleAudioEngine sharedEngine] playEffect:@"gameover.wav"];
            }
            self.lives--;
            [_view updateLabels];
            [_view removeSlowDownPill];
            self.paused = YES;
            [_view displayAlertWithMessage:@"Self-intersection detected"];
            break;
        }
    }
    // The snake gains points if it collects an item. Any slow down pills
    // that are currently available get removed from the board.
    if (snake[0].x == self.item.x && snake[0].y == self.item.y)
    {
        self.points++;
        if (self.pill.x)
        {
            [_view removeSlowDownPill];
        }
        // THe game will proceed to the next level after gaining a certain
        // number of points.  The speed will also increase, accordingly.
        if (self.points > 0 && self.points % 5 == 0)
        {
            if (!self.mute)
            {
                [[SimpleAudioEngine sharedEngine] playEffect:@"success.wav"];
            }
            self.level++;
            [self setSpeed:self.speed-acceleration*0.020];
            // The snake grows one square longer
            self.lengthOfSnake++;
            // Spawn the next item
            [self createItem];
            // Offer one slow down pill at the start of each level
            [self createSlowDownPill];
            [_view updateBackgroundWithFlash:YES];
        }
        else
        {
            if (!self.mute)
            {
                [[SimpleAudioEngine sharedEngine] playEffect:@"collect.wav"];
            }
            // The snake grows one square longer
            self.lengthOfSnake++;
            // Spawn the next item
            [self createItem];
        }
        [_view updateLabels];
        [_view updateItems];
    }
    // The snake slows down a bit if it collects a slow down pill
    if (snake[0].x == self.pill.x && snake[0].y == self.pill.y)
    {
        if (!self.mute)
        {
            [[SimpleAudioEngine sharedEngine] playEffect:@"slowdown.wav"];
        }
        [_view removeSlowDownPill];
        [_view updateItems];
        [self setSpeed:self.speed+acceleration*0.020];
    }
}

@end
