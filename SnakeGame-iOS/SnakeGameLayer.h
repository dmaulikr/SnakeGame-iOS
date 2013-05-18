//
//  SnakeGameLayer.h
//  SnakeGame-iOS
//
//  Created by Dilip Muthukrishnan on 13-05-14.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"

// HelloWorldLayer
@interface SnakeGameLayer : CCLayerColor
{
    float startX, startY;
	NSString *direction;
	CGPoint snake[30];
	int lengthOfSnake;
	CGPoint items[20];;
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

- (void) drawGrid;
- (void) drawSnake;
- (void) initializeSnakeArray;
- (void) initializeItemsArray;
- (void) updateSnakeArray;
void ccFilledRect(CGPoint v1, CGPoint v2);

@end
