//
//  PushAnimatedSegue.m
//  CirclesPIMP
//
//  Created by Anton Krasnokutskiy on 12/8/14.
//  Copyright (c) 2014 Anton. All rights reserved.
//

#import "PushAnimatedSegue.h"

@implementation PushAnimatedSegue

-(void) perform{
    CATransition* transition = [CATransition animation];
    
    transition.duration = 0.2;
    transition.type = kCATransitionFade;
    
    [[self.sourceViewController navigationController].view.layer addAnimation:transition forKey:kCATransition];
    [[self.sourceViewController navigationController] pushViewController:[self destinationViewController] animated:NO];
}

@end
