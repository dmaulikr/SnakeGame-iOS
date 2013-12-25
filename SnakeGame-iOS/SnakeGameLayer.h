//
//  SnakeGameLayer.h
//  SnakeGame-iOS
//
//  Created by Dilip Muthukrishnan on 13-05-14.
//  Copyright Iyer Inc. 2013. All rights reserved.
//

/* Additional features:
 
    1.  One slow down pill per level (available for 30 seconds).
    2.  Currently, the points are determined by the number of items collected
        but maybe, we can simply use this for level progression, and count the
        points based on other factors such as each square moved.
    3.  High scores table.
    4.  Implement ability to save games.
    5.  For higher levels, insert death squares randomly.
    6.  Add Menu screen with options to view high scores, go through tutorial, choose between four difficulty levels (easy, normal, hard, and nightmare), and load saved games.
    7.  Implement difficulty levels: Easy, Normal, Hard, Nightmare (will affect rate of game progression).
    8.  One Up pill per level (available for 30 seconds).
    9.  Create tutorial screen (a live demonstation would be really cool!)
 
 */

#import "cocos2d.h"
#import "SnakeGameModel.h"

@interface SnakeGameLayer : CCLayer <UIAlertViewDelegate, SnakeGameDelegate>
{
    SnakeGameModel *game;
    CCLabelTTF *levelLabel;
    CCLabelTTF *pointsLabel;
    float bgcolors[6][4];
    UIAlertView *alert;
    CCMenuItem *pauseon, *pauseoff;
    CCMenuItemToggle *pauseButton;
    CCMenuItem *muteon, *muteoff;
    CCMenuItemToggle *muteButton;
}

+(CCScene *) sceneWithDifficulty:(Difficulty)difficulty;

-(id) initWithDifficulty:(Difficulty)difficulty;
- (void) displayAlertWithMessage:(NSString *)message;
- (void) refresh:(ccTime)t;
- (void) updateLabels;
- (void) drawBackground;
- (void) drawGrid;
- (void) drawSnake;
- (void) drawItem;
- (void) drawSlowDownPill;
- (void) drawBrickWall;

void ccFilledRect(CGPoint v1, CGPoint v2);

@end
