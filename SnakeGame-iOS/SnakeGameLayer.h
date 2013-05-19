//
//  SnakeGameLayer.h
//  SnakeGame-iOS
//
//  Created by Dilip Muthukrishnan on 13-05-14.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "SimpleAudioEngine.h"

// HelloWorldLayer
@interface SnakeGameLayer : CCLayer <UIAlertViewDelegate>
{
    float startX, startY;
	NSString *direction;
	CGPoint snake[30];
	int lengthOfSnake;
    int numberOfItems;
	CGPoint items[20];;
    UIAlertView *alert;
    BOOL gamePaused;
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

- (void) resetGame;
- (void) drawBackground;
- (void) drawGrid;
- (void) drawSnake;
- (void) drawItems;
- (void) initializeSnakeArray;
- (void) initializeItemsArray;
- (void) updateSnakeArray;
void ccFilledRect(CGPoint v1, CGPoint v2);

@end
