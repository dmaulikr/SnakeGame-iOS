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
@synthesize startPoint = _startPoint;
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
    self.lives = 5;
    [_view updateLabels];
    _speed = 0.275;
    self.startPoint = ccp(20.0*5.0, 20.0*2.0);
    self.direction = FORWARD;
    self.lengthOfSnake = 4;
    [self initializeSnakeArray];
    [self createItem];
    self.pill = ccp(-20.0, -20.0);
}

// Revert to the previous snapshot
- (void) revertToLastSnapshot
{
    for (int i = 0; i < self.lengthOfSnake; i++)
    {
        snake[i] = snake_snapshot[i];
    }
    self.direction = direction_snapshot;
}

// Pauses/continues the game
- (void) setPaused:(BOOL)option
{
    _paused = option;
    if (option)
    {
        [_view unschedule:@selector(refresh:)];
    }
    else
    {
        [_view schedule:@selector(refresh:) interval:_speed];
    }
}

// Change the speed of the snake's motion by doing more/less frequent updates.
- (void) setSpeed:(float)s
{
    _speed = s;
    [_view unschedule:@selector(refresh:)];
    [_view schedule:@selector(refresh:) interval:s];
}

// This method was necessary because I didn't know how to declare
// the snake array as a property without converting it into an NSArray.
- (CGPoint) getSnakePieceAtIndex:(int)i
{
    return snake[i];
}

// Figure out where to position the snake at the start of the game
// and then construct it there.
- (void) initializeSnakeArray
{
    for (int i = 0; i < self.lengthOfSnake; i++)
    {
        snake[i] = ccp(self.startPoint.x-20.0*i, self.startPoint.y);
    }
    [self captureSnapshot];
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
}

// Moves the snake one tile ahead in the current direction
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
}

// Stores a snapshot of the snake's current position
// and direction in order to revert back to it later
- (void) captureSnapshot
{
    for (int i = 0; i < self.lengthOfSnake; i++)
    {
        snake_snapshot[i] = snake[i];
    }
    direction_snapshot = self.direction;
}

// Update direction of snake motion based on touch location
- (void) updateDirectionWithTouch:(CGPoint)location
{
    if (self.direction == FORWARD || self.direction == BACKWARD)
    {
        if (location.y > snake[0].y)
        {
            self.direction = UPWARD;
        }
        else if (location.y < snake[0].y - 20.0)
        {
            self.direction = DOWNWARD;
        }
    }
    else if (self.direction == UPWARD || self.direction == DOWNWARD)
    {
        if (location.x > snake[0].x + 20.0)
        {
            self.direction = FORWARD;
        }
        else if (location.x < snake[0].x)
        {
            self.direction = BACKWARD;
        }
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
        [_view unschedule:@selector(refresh:)];
        [_view displayAlertWithMessage:@"Boundary Reached"];
    }
    else if (snake[0].y == 20.0 || snake[0].y == 460.0)
    {
        if (!self.mute)
        {
            [[SimpleAudioEngine sharedEngine] playEffect:@"gameover.wav"];
        }
        self.lives--;
        [_view unschedule:@selector(refresh:)];
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
            [_view unschedule:@selector(refresh:)];
            [_view displayAlertWithMessage:@"Self-intersection detected"];
        }
    }
    // The snake gains points if it collects an item and any slow down pills
    // that are currently available get removed from the board.
    if (snake[0].x == self.item.x && snake[0].y == self.item.y)
    {
        self.points++;
        self.pill = ccp(-20.0, -20.0);
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
            snake[self.lengthOfSnake] = ccp(-20.0, -20.0);
            self.lengthOfSnake++;
            // Spawn the next item
            [self createItem];
            // Offer one slow down pill at the start of each level
            [self createSlowDownPill];
            // Record the current position of the snake
            [self captureSnapshot];
        }
        else
        {
            if (!self.mute)
            {
                [[SimpleAudioEngine sharedEngine] playEffect:@"collect.wav"];
            }
            // The snake grows one square longer
            snake[self.lengthOfSnake] = ccp(-20.0, -20.0);
            self.lengthOfSnake++;
            // Spawn the next item
            [self createItem];
            // Record the current position of the snake
            [self captureSnapshot];
        }
    }
    // The snake slows down a bit if it collects a slow down pill
    if (snake[0].x == self.pill.x && snake[0].y == self.pill.y)
    {
        if (!self.mute)
        {
            [[SimpleAudioEngine sharedEngine] playEffect:@"pill.wav"];
        }
        self.pill = ccp(-20.0, -20.0);
        [self setSpeed:self.speed+acceleration*0.020];
    }
    [_view updateLabels];
}

@end
