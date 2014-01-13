//
//  SnakeGameLayer.h
//  SnakeGame-iOS
//
//  Created by Dilip Muthukrishnan on 13-05-14.
//  Copyright Iyer Inc. 2013. All rights reserved.
//

/* Additional features:
 
    1.  Currently, the points are determined by the number of items collected
        but maybe, we can simply use this for level progression, and count the
        points based on other factors such as each square moved.
    2.  High scores table.
    3.  Implement ability to save games.
    4.  For higher levels, insert death squares randomly.
    5.  Add Menu screen with options to view high scores, go through tutorial, choose between four difficulty levels (easy, normal, hard, and nightmare), and load saved games.
    6.  Implement difficulty levels: Easy, Normal, Hard, Nightmare (will affect rate of game progression).
    7.  One Up pill per level (available for 30 seconds).
    8.  Create tutorial screen (a live demonstation would be really cool!)
    9.  Implement swipe gestures to control the snake.
 
 */

#import "cocos2d.h"
#import "SnakeGameModel.h"

@interface SnakeGameLayer : CCLayer <UIAlertViewDelegate, SnakeGameDelegate>
{
    SnakeGameModel *game;
    float bgcolors[6][4];
    CCLabelTTF *levelLabel;
    CCLabelTTF *pointsLabel;
    CCLabelTTF *livesLabel;
    UIAlertView *alert;
    CCMenuItem *pauseon, *pauseoff;
    CCMenuItemToggle *pauseButton;
    CCMenuItem *muteon, *muteoff;
    CCMenuItemToggle *muteButton;
    CCSprite *up, *down, *left, *right;
    CCSprite *bg, *item, *pill;
    NSMutableArray *snake;
}

+(CCScene *) sceneWithDifficulty:(Difficulty)difficulty;

-(id) initWithDifficulty:(Difficulty)difficulty;
- (void) displayAlertWithMessage:(NSString *)message;
- (void) updateLabels;
- (void) updateBackgroundWithFlash:(BOOL)flash;
- (void) updateItems;
- (void) updateSnake;
- (void) growSnake;
- (void) toggleDirectionArrows;
- (void) removeSlowDownPill;
- (void) drawBrickWall;

@end
