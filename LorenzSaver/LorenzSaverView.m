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
        // Animate at 60 FPS
        [self setAnimationTimeInterval:1/60.0];
        
        // Get bounds of screen
        NSRect screenSize = [self bounds];
        screenMaxX = NSMaxX(screenSize);
        screenMaxY = NSMaxY(screenSize);
        
        // Plot curve from t=0 to t=40, solve using timestep of 0.005
        LorenzSolver *solver = [[LorenzSolver alloc] initWithTMin:0.0 tMax:40 dt:0.005];
        
        // TODO: Perform on different thread?
        [solver solve];
        
        // Plot x-z plane
        NSArray *xVals = solver.x;
        NSArray *zVals = solver.z;
        
        // Find min and max x,z values
        lorenzMinX = [[xVals valueForKeyPath:@"@min.floatValue"] floatValue];
        lorenzMinZ = [[zVals valueForKeyPath:@"@min.floatValue"] floatValue];
        lorenzMaxX = [[xVals valueForKeyPath:@"@max.floatValue"] floatValue];
        lorenzMaxZ = [[zVals valueForKeyPath:@"@max.floatValue"] floatValue];
        
        // Convert points to screen coordinates
        points = [NSMutableArray arrayWithCapacity:xVals.count];
        for (int i = 0; i < xVals.count; i++) {
            NSPoint point = NSMakePoint([xVals[i] floatValue], [zVals[i] floatValue]);
            point = [self convertToScreenSpace:point];
            // Must store points as NSValues since NSPoint is not an NSObject
            NSValue *pointVal = [NSValue valueWithPoint:point];
            [points addObject:pointVal];
        }
        
        ScreenSaverDefaults *settings = [ScreenSaverDefaults defaultsForModuleWithName:@"LorenzSaver"];
        [settings registerDefaults:@{
                                     @"shouldColour": @YES,
                                     @"shouldDisplayParams": @NO
                                     }];
        shouldColour = [settings boolForKey:@"shouldColour"];
        shouldDisplayParams = [settings boolForKey:@"shouldDisplayParams"];
        
        [self setupColours];
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
    
    for (int k = 1; k < self->n; k++) {
        NSPoint prevPoint = [points[k - 1] pointValue];
        NSPoint nextPoint = [points[k] pointValue];
        
        NSColor *colour = colours[k % colours.count];
        [colour set];
        
        NSBezierPath *path = [NSBezierPath bezierPath];
        [path setLineWidth:1];
        [path setLineJoinStyle:NSLineJoinStyleRound];
        
        [path moveToPoint:prevPoint];
        [path lineToPoint:nextPoint];
        
        [path stroke];
    }
}

- (void)animateOneFrame
{
    n = (n + 1) % [points count];
    [self setNeedsDisplay:YES];
}

- (BOOL)hasConfigureSheet
{
    return YES;
}

- (NSWindow *)configureSheet
{
    if (configSheet == nil) {
        if ([NSBundle loadNibNamed:@"LorenzSaverSheet" owner:self] == NO) {
            NSLog(@"Error loading config sheet");
            NSBeep();
        }
    }
    
    ScreenSaverDefaults *settings = [ScreenSaverDefaults defaultsForModuleWithName:@"LorenzSaver"];
    [shouldColourCheckbox setState:[settings boolForKey:@"shouldColour"]];
    [shouldDisplayParamsCheckbox setState:[settings boolForKey:@"shouldDisplayParams"]];
    
    return (NSWindow *)configSheet;
}

- (IBAction)sheetOkAction:(id)sender {
    shouldColour = [shouldColourCheckbox state];
    shouldDisplayParams = [shouldDisplayParamsCheckbox state];
    
    ScreenSaverDefaults *settings = [ScreenSaverDefaults defaultsForModuleWithName:@"LorenzSaver"];
    [settings setBool:shouldColour forKey:@"shouldColour"];
    [settings setBool:shouldDisplayParams forKey:@"shouldDisplayParams"];
    [settings synchronize];
    
    [self setupColours];
    
    [[NSApplication sharedApplication] endSheet:configSheet];
}

- (IBAction)sheetCancelAction:(id)sender {
    [[NSApplication sharedApplication] endSheet:configSheet];
}

- (NSPoint)convertToScreenSpace:(NSPoint)lorenzSpace {
    float screenX = ((lorenzSpace.x - lorenzMinX) / (lorenzMaxX - lorenzMinX)) * screenMaxX;
    float screenY = ((lorenzSpace.y - lorenzMinZ) / (lorenzMaxZ - lorenzMinZ)) * screenMaxY;
    
    return NSMakePoint(screenX, screenY);
}

- (void)setupColours {
    if (shouldColour) {
        // Line segments are drawn using colours from this array, in order
        int nColours = 1000; // Larger number means smoother gradient
        colours = [NSMutableArray arrayWithCapacity:nColours];
        for (float hue = 0.0; hue <= 1.0; hue += 1.0/nColours) {
            NSColor *colour = [NSColor colorWithHue:hue saturation:1.0 brightness:1.0 alpha:1.0];
            [colours addObject:colour];
        }
    } else {
        colours = [NSMutableArray arrayWithObject:[NSColor whiteColor]];
    }
}

@end
