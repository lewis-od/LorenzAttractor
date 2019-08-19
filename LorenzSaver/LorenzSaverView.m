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
        LorenzSolver *solver = [[LorenzSolver alloc] initWithTMin:0.0 tMax:40 dt:0.005];
        
        // TODO: Perform on different thread?
        [solver solve];
        
        // Plot x-z plane
        xVals = solver.x;
        zVals = solver.z;
        
        // Find min and max x,z values
        lorenzMinX = [[xVals valueForKeyPath:@"@min.floatValue"] floatValue];
        lorenzMinZ = [[zVals valueForKeyPath:@"@min.floatValue"] floatValue];
        lorenzMaxX = [[xVals valueForKeyPath:@"@max.floatValue"] floatValue];
        lorenzMaxZ = [[zVals valueForKeyPath:@"@max.floatValue"] floatValue];
    }
    return self;
}

- (void)startAnimation
{
    [super startAnimation];
    
    // Number of points drawn
    self->n = 1;
    
    // Get bounds of screen
    NSRect screenSize = [self bounds];
    screenMaxX = NSMaxX(screenSize);
    screenMaxY = NSMaxY(screenSize);
}

- (void)stopAnimation
{
    [super stopAnimation];
}

- (void)drawRect:(NSRect)rect
{
    [super drawRect:rect];
    
    // Draw in white
    [[NSColor whiteColor] set];
    
    NSBezierPath *path = [NSBezierPath bezierPath];
    [path setLineWidth:1];
    [path setLineJoinStyle:NSLineJoinStyleRound];
    
    for (int k = 0; k < self->n; k++) {
        // Scale points to screen
        NSPoint point = NSMakePoint([xVals[k] floatValue], [zVals[k] floatValue]);
        point = [self convertToScreenSpace:point];
        
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
    n = (n + 1) % [xVals count];
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

- (NSPoint)convertToScreenSpace:(NSPoint)lorenzSpace {
    float screenX = ((lorenzSpace.x - lorenzMinX) / (lorenzMaxX - lorenzMinX)) * screenMaxX;
    float screenY = ((lorenzSpace.y - lorenzMinZ) / (lorenzMaxZ - lorenzMinZ)) * screenMaxY;
    
    return NSMakePoint(screenX, screenY);
}

@end
