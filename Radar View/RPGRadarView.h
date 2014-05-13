//
//  RPGRadarView.h
//  RPGRadarView
//
//  Created by Gumdal, Raj Pawan on 5/7/14.
//  Copyright (c) 2014 Gumdal, Raj Pawan. All rights reserved.
//

#import <UIKit/UIKit.h>

// Defaults:
#define THICK_STROKES 512
#define RADAR_COLOR [UIColor colorWithRed:0.0 green:1.0 blue:0.1 alpha:0.5]
#define RPM_VALUE 30
#define FRAME_RATE 36.0 // In FPS (Frames per second)
#define DISTANCE_BW_STROKES_IN_ANGLE 0.075
#define MAX_BRIGHTNESS_ALPHA_FOR_A_STROKE 0.15
#define MIN_BRIGHTNESS_ALPHA_FOR_A_STROKE 0.0

@interface RPGRadarView : UIView
@property (nonatomic, strong) NSNumber *numberOfThickStrokes;
@property (nonatomic, strong) NSNumber *distanceBetweenStrokes; // In Angle
@property (nonatomic, strong) UIColor *radarColor;
@property (nonatomic, strong) NSNumber *radarRPM;
@property (nonatomic, strong) NSNumber *frameRate;
@property (nonatomic, strong) NSNumber *angleStep;
@property (nonatomic, strong) NSNumber *maxAlphaBrightnessForThickestStroke;
@property (nonatomic, strong) NSNumber *minAlphaBrightnessForThinneshStroke;

-(void)startAnimating;
-(void)stopAnimating;

@end
