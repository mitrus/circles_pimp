//
//  ViewController.h
//  CirclesPIMP
//
//  Created by Anton Krasnokutskiy on 12/8/14.
//  Copyright (c) 2014 Anton. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>

@interface CirclesViewController : GLKViewController

@property (strong, nonatomic) EAGLContext *context;
@property (strong) GLKBaseEffect *effect;
@property (weak, nonatomic) IBOutlet UILabel *currentScore;
@property (weak, nonatomic) IBOutlet UILabel *highScore;

- (void)startCircleGenerator;
- (void)stopCircleGenerator;

@end

