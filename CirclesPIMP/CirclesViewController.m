//
//  ViewController.m
//  CirclesPIMP
//
//  Created by Anton Krasnokutskiy on 12/8/14.
//  Copyright (c) 2014 Anton. All rights reserved.
//

#import "CirclesViewController.h"
#import "Circle.h"
#import "Geometry.h"
#import "HighScore.h"

#include <stdlib.h>
#include "AppDelegate.h"
#include "stdio.h"

#define MIN_REQUIRED_DISTANCE 350
#define MAX_DISTANCE 1e9
#define MAX_AMOUNT_OF_REATTEMPT 5
#define ALLOWABLE_DEVIATION 40
#define SPEED_OF_GROWING 8.0
#define SPEED_OF_KILLING 40
#define PERIOD_BETWEEN_GEN 1.0
#define min(a, b) ((a < b) ? (a) : (b))
#define max(a, b) ((a > b) ? (a) : (b))

@interface CirclesViewController () {
    float xTL;
    float yTL;
    float xBR;
    float yBR;
    Circle *circle;
    NSMutableArray *balls;
    bool circlesSimpleGeneratorIsRunning;
    NSTimer *circlesSimpleGenerator;
    HighScore *score;
}
    
@end

@implementation CirclesViewController

@synthesize context = _context;


- (void)viewDidLoad {
    [super viewDidLoad];
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    self.effect = [[GLKBaseEffect alloc] init];
    score = [[HighScore alloc] init];
    [self updateUIScore];
    // Do any additional setup after loading the view, typically from a nib.
    if (!self.context) {
        NSLog(@"Error in ES context");
    }
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.enableSetNeedsDisplay = YES;
    view.drawableMultisample = GLKViewDrawableMultisample4X;
    [EAGLContext setCurrentContext:self.context];
    float aspect = fabsf(self.view.bounds.size.height / self.view.bounds.size.width);
    xTL = -500;
    xBR = 500;
    yTL = -500 * aspect;
    yBR = 500 * aspect;
    
    GLKMatrix4 projectionMatrix = GLKMatrix4MakeOrtho(xTL, xBR, yBR, yTL, -1024, 1024);
    self.effect.transform.projectionMatrix = projectionMatrix;
    
    // ---------- OPENGL IS INITIALIZED -----------
    
//    circle = [[Circle alloc] initWithEffect:self.effect andColor:GLKVector4Make(1, .235 / .225, .059 / .255, 1) andPosition:GLKVector2Make(200, 200)];
    balls = [[NSMutableArray alloc] init];
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    circlesSimpleGeneratorIsRunning = false;
    [self startCircleGenerator];
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    appDelegate.game = self;
}

- (void)generateCircleInMainThread {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self generateCircle];
        [self generateCircle];
        circlesSimpleGeneratorIsRunning = true;
        [self stopCircleGenerator];
        [self startCircleGenerator];
        NSLog(@"%d", self.paused == true ? 1 : 0);
    });
}

- (void)startCircleGenerator {
    if (circlesSimpleGeneratorIsRunning)
        return;
    circlesSimpleGenerator = [NSTimer scheduledTimerWithTimeInterval:PERIOD_BETWEEN_GEN target:self selector:@selector(generateCircleInMainThread) userInfo:nil repeats:YES];
    circlesSimpleGeneratorIsRunning = true;
}

- (void)stopCircleGenerator {
    circlesSimpleGeneratorIsRunning = false;
    if([circlesSimpleGenerator isValid]){
        [circlesSimpleGenerator invalidate];
    }
}

- (void)generateCircle {
    // Sorry for this...
    GLKVector4 CIRCLES_COLORS[] = {
        GLKVector4Make(.216/.255, .067/.255, .021/.255, 1),
        GLKVector4Make(.255/.255, .235/.255, .059/.255, 1),
        GLKVector4Make(.205/.255, .220/.255, .057/.255, 1),
        GLKVector4Make(.255/.255, .152/.255, .0/.255, 1),
    };
    
    float x = 0;
    float y = 0;
    int width = xBR - xTL;
    int height = yBR - yTL;
    bool found = false;
    for (int i = 0; i < MAX_AMOUNT_OF_REATTEMPT; i++) {
        x = xTL + arc4random_uniform(width);
        y = yTL + arc4random_uniform(height);
        float minDistance = MAX_DISTANCE;
        if ([balls count] != 0) {
            for (int j = 0; j < [balls count]; j++)
                minDistance = min(minDistance,
                                  [Geometry distanceFromPointX:x andY:y toCircle:[balls objectAtIndex:j]]);
            if (minDistance > MIN_REQUIRED_DISTANCE) {
                found = true;
                break;
            }
        } else {
            found = true;
            break;
        }
    }
    if (found) {
        Circle *genCircle = [[Circle alloc] initWithEffect:self.effect andColor:CIRCLES_COLORS[arc4random_uniform(sizeof(CIRCLES_COLORS) / sizeof(CIRCLES_COLORS[0]))] andPosition:GLKVector2Make(x, y) andSpeed:SPEED_OF_GROWING andKillingSpeed:SPEED_OF_KILLING];
        [balls addObject:genCircle];
    }
}

- (void)updateUIScore {
    [[self currentScore] setText:[[NSString alloc] initWithFormat:@"%d", score.currentScore]];
    [[self highScore] setText:[[NSString alloc] initWithFormat:@"%d", score.highScore]];
}

- (int)deleteIfExistsX:(float)x Y:(float)y {
    for (int i = 0; i < [balls count]; i++) {
        if ([Geometry distanceFromPointX:x andY:y toCircle:[balls objectAtIndex:i]] < ALLOWABLE_DEVIATION) {
            float r = [[balls objectAtIndex:i] radius];
            [score updateCurrentScore:[score currentScore] + ((int) (r * r) / 10000)];
            [self updateUIScore];
            [[balls objectAtIndex:i] killCircleX:x Y:y];
            return i;
        }
    }
    return -1;
}

- (NSArray *)tryToGetHitPair {

    for (int i = 0; i < [balls count]; i++) {
        for (int j = i + 1; j < [balls count]; j++) {
            float tmp = [Geometry distanceFrom:[balls objectAtIndex:i] toAnother:[balls objectAtIndex:j]];
            float criticDistance = 0;
            if (tmp <= criticDistance) {
                return @[[balls objectAtIndex:i], [balls objectAtIndex:j]];
            }
        }
    }
    return [[NSArray alloc] init];
}

- (void)updateSystem {
    for (int i = 0; i < [balls count]; i++) {
        [(Circle *)balls[i] updatePhysics];
        if ([(Circle *)balls[i] readyToDelete])
            [balls removeObjectAtIndex:i];
    }
    NSArray *hitPair = [self tryToGetHitPair];
    if ([hitPair count] != 0) {
        [self restartGame];
    }
}

- (void)restartGame {
    [balls removeAllObjects];
    [score updateCurrentScore:0];
    [self updateUIScore];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint location = [touch locationInView:self.view];
    float wView = self.view.window.bounds.size.width;
    float hView = self.view.window.bounds.size.height;
    float wGame = -xTL + xBR;
    float hGame = -yTL + yBR;
    float x = (location.x / wView) * wGame + xTL;
    float y = (location.y / hView) * hGame + yTL;
    [self deleteIfExistsX:x Y:y];
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    //    if (![self.token.accessToken  isEqual: @"empty"]) {
    //        NSLog(@"%@", self.token.accessToken);
    
    glClearColor(0.096 / .255, 0.125 / .255, 0.139 / .255, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    for (int i = 0; i < [balls count]; i++)
        [[balls objectAtIndex:i] render];
    [self updateSystem];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
