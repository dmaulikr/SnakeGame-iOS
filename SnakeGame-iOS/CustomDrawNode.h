//
//  CustomDrawNode.h
//  SnakeGame-iOS
//
//  Created by Dilip Muthukrishnan on 14-01-03.
//  Copyright 2014 __MyCompanyName__. All rights reserved.
//
//  A custom node for drawing primitives!

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "SnakeGameModel.h"

@interface CustomDrawNode : CCNode
{
    SnakeGameModel *game;
    float bgcolors[6][4];
}

- (id) initWithGame:(SnakeGameModel *)g;
- (void) drawBackground;
- (void) drawGrid;
- (void) drawSnake;
- (void) drawItem;
- (void) drawSlowDownPill;

void ccFilledRect(CGPoint v1, CGPoint v2);

@end