//
//  MenuLayer.h
//  SnakeGame-iOS
//
//  Created by Dilip Muthukrishnan on 13-12-22.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"
#import "SnakeGameLayer.h"

@interface MenuLayer : CCLayer
{
    CCSprite *bg;
    CCMenuItemImage *playgame, *highscores, *tutorial;
    CCMenuItemImage *easy, *normal, *hard, *nightmare;
}

+(CCScene *) scene;

-(void) playGameSelected:(id)sender;

@end
