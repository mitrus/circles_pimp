//
//  HighScore.m
//  CirclesPIMP
//
//  Created by Anton Krasnokutskiy on 12/8/14.
//  Copyright (c) 2014 Anton. All rights reserved.
//

#import "HighScore.h"
#import "NSFileManager-AES.h"

@interface HighScore () {
}

@end

@implementation HighScore 

@synthesize currentScore = _currentScore;
@synthesize highScore = _highScore;

- (id)init {
    if (self = [super init]) {
        _highScore = (int) [[NSUserDefaults standardUserDefaults] integerForKey:@"high_score"];
        
    }
    return self;
}

- (void)updateCurrentScore:(int)score {
    _currentScore = score;
    if (score > _highScore) {
        _highScore = score;
        [[NSUserDefaults standardUserDefaults] setInteger:score forKey:@"high_score"];
    }
}

@end
