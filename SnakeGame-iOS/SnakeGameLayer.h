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
    4.  Pause button.
    5.  Keep track of the number of lives and reset level instead of game when player still has lives.
    6.  Saving games.
    7.  Menu screen with level selection, sound config, and loading saved games.
    8.  For higher levels, insert death squares randomly.
 
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
    CCMenuItemImage *pauseButton;
    CCMenuItem *muteon, *muteoff;
    CCMenuItemToggle *muteButton;
}

+(CCScene *) scene;

- (void) displayAlertWithMessage:(NSString *)message;
- (void) refresh:(ccTime)t;
- (void) updateLabels;
- (void) drawBackground;
- (void) drawGrid;
- (void) drawSnake;
- (void) drawItem;
- (void) drawBrickWall;

void ccFilledRect(CGPoint v1, CGPoint v2);

@end
