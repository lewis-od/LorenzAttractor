//
//  LorenzSaverView.m
//  LorenzSaver
//
//  Created by Lewis O'Driscoll on 18/08/2019.
//  Copyright © 2019 Lewis O'Driscoll. All rights reserved.
//

#import "LorenzSaverView.h"

@implementation LorenzSaverView

- (instancetype)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{    
    self = [super initWithFrame:frame isPreview:isPreview];
    if (self) {
        [self setAnimationTimeInterval:1/60.0];
        
        // Plot curve from t=0 to t=40, solve using timestep of 0.005
        solver = [[LorenzSolver alloc] initWithTMin:0.0 tMax:40 dt:0.005];
        
        // TODO: Perform on different thread?
        [solver solve];
    }
    return self;
}

- (void)startAnimation
{
    [super startAnimation];
    
    // Number of points drawn
    self->n = 1;
}

- (void)stopAnimation
{
    [super stopAnimation];
}

- (void)drawRect:(NSRect)rect
{
    [super drawRect:rect];
    
    // Get bounds of screen
    NSRect screenSize = [self bounds];
    float screenMaxX = NSMaxX(screenSize);
    float screenMaxY = NSMaxY(screenSize);
    
    // Plot x-z plane
    NSArray *xVals = solver.x;
    NSArray *zVals = solver.z;
    // Find min and max x,z values
    float lorenzMinX = [[xVals valueForKeyPath:@"@min.floatValue"] floatValue];
    float lorenzMinZ = [[zVals valueForKeyPath:@"@min.floatValue"] floatValue];
    float lorenzMaxX = [[xVals valueForKeyPath:@"@max.floatValue"] floatValue];
    float lorenzMaxZ = [[zVals valueForKeyPath:@"@max.floatValue"] floatValue];
    
    // Draw in white
    [[NSColor whiteColor] set];
    
    NSBezierPath *path = [NSBezierPath bezierPath];
    [path setLineWidth:1];
    [path setLineJoinStyle:NSLineJoinStyleRound];
    
    for (int k = 0; k < self->n; k++) {
        // Scale points to screen
        float pointX = (([xVals[k] floatValue] - lorenzMinX) / (lorenzMaxX - lorenzMinX)) * screenMaxX;
        float pointY = (([zVals[k] floatValue] - lorenzMinZ) / (lorenzMaxZ - lorenzMinZ)) * screenMaxY;
        NSPoint point = NSMakePoint(pointX, pointY);
        
        if (k == 0) {
            // First point - move cursor here
            [path moveToPoint:point];
        } else {
            // Draw line from previous point to this point
            [path lineToPoint:point];
        }
    }
    
    // Draw the path
    [path stroke];
}

- (void)animateOneFrame
{
    n = (n + 1) % [solver.x count];
    [self setNeedsDisplay:YES];
}

- (BOOL)hasConfigureSheet
{
    return NO;
}

- (NSWindow*)configureSheet
{
    return nil;
}

@end
