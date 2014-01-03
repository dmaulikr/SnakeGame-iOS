//
//  SnakeGameModel.h
//  SnakeGame-iOS
//
//  Created by Dilip Muthukrishnan on 13-11-25.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "SimpleAudioEngine.h"

// The four possible directions of movement
typedef enum directionTypes
{
    FORWARD,
    BACKWARD,
    UPWARD,
    DOWNWARD
    
} Direction;

// The three difficulty levels
typedef enum difficultyTypes
{
    EASY,
    NORMAL,
    HARD
    
} Difficulty;

@protocol SnakeGameDelegate

- (void) unschedule:(SEL)selector;
- (void) schedule:(SEL)selector interval:(ccTime)interval;
- (void) scheduleOnce:(SEL) selector delay:(ccTime) delay;
- (void) pauseSchedulerAndActions;
- (void) resumeSchedulerAndActions;
- (void) updateLabels;
- (void) toggleDirectionArrows;
- (void) removeSlowDownPill;
- (void) displayAlertWithMessage:(NSString *)message;

@end

@interface SnakeGameModel : NSObject
{
    id<SnakeGameDelegate> _view;
    CGPoint snake[350];                                 // The current position of the snake
    float acceleration;                                 // Depends on the difficulty level
}

@property (nonatomic, assign) int level;                // Levels increase as the snake grows
@property (nonatomic, assign) int points;               // Collecting items gives you points
@property (nonatomic, assign) float speed;              // This is INVERSELY proportional to the snake's speed!
@property (nonatomic, assign) CGPoint startPoint;       // The snake's home position
@property (nonatomic, assign) CGPoint item;             // The collectible item
@property (nonatomic, assign) CGPoint pill;             // The slow down pill
@property (nonatomic, assign) int lengthOfSnake;
@property (nonatomic, assign) Direction direction;      // The current direction of motion
@property (nonatomic, assign) BOOL paused;
@property (nonatomic, assign) BOOL mute;
@property (nonatomic, assign) int lives;                // Number of remaining lives for the snake

- (id) initWithView:(id)layer difficulty:(Difficulty)difficulty;
- (void) resetGame;
- (void) spawnSnakeFromBoundary;
- (void) setSpeed:(float)s;
- (CGPoint) getSnakePieceAtIndex:(int)i;
- (void) initializeSnakeArray;
- (void) createItem;
- (void) createSlowDownPill;
- (void) updateSnakeArray;
- (void) updateDirectionWithTouch:(CGPoint)location;
- (void) updateGameState;

@end
