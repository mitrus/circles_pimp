//
//  HighScore.h
//  CirclesPIMP
//
//  Created by Anton Krasnokutskiy on 12/8/14.
//  Copyright (c) 2014 Anton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface HighScore : NSObject

@property int currentScore;
@property int highScore;

- (void)updateCurrentScore:(int)score;

@end
