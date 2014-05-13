//
//  RPGRadarView.m
//  RPGRadarView
//
//  Created by Gumdal, Raj Pawan on 5/7/14.
//  Copyright (c) 2014 Gumdal, Raj Pawan. All rights reserved.
//

#import "RPGRadarView.h"

#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)
#define RADIANS_TO_DEGREES(radians) ((radians) * (180.0 / M_PI))

@interface RPGRadarView()
@property (nonatomic, strong) NSTimer *animationTimer;
@property (nonatomic, strong) NSNumber *currentAngle;   // Angle of the thickest stroke
@end

@implementation RPGRadarView
@synthesize currentAngle = currentAngle_;
-(void)setCurrentAngle:(NSNumber *)inCurrentAngle
{
    if (inCurrentAngle!=currentAngle_)
    {
        // If angle is in negative convert it to other quadrant in positive
        if (inCurrentAngle.floatValue<0)
        {
            inCurrentAngle = [NSNumber numberWithFloat:(360.0 + inCurrentAngle.floatValue)];
        }
        
        // If angle is more than 360
        inCurrentAngle = [NSNumber numberWithFloat:fmodf(inCurrentAngle.floatValue, 360.0)];
        
        currentAngle_ = inCurrentAngle;
    }
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // http://www.raywenderlich.com/34003/core-graphics-tutorial-curves-and-layers
    // http://stackoverflow.com/questions/3804453/iphone-how-to-make-a-circle-path-for-a-cakeyframeanimation
    // http://stackoverflow.com/questions/3418652/help-drawing-circle-in-iphone
    
    // Drawing the circle
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGMutablePathRef circularPath = CGPathCreateMutable();
    CGRect pathRect = CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height); // some rect you define. A circle has equal width/height; radius is half the values you specify here
    CGPathAddEllipseInRect(circularPath, NULL, pathRect);
    CGContextAddPath(context, circularPath);
    UIColor *fillColor = RADAR_COLOR;
    CGContextSetFillColorWithColor(context, fillColor.CGColor);
    CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
//    CGContextFillPath(context);
//    CGContextStrokePath(context);
    // http://stackoverflow.com/a/9397811/260665
    CGContextDrawPath(context, kCGPathFillStroke);
    CGPathRelease(circularPath);
    
    // Start drawing the strokes now
    int numberOfThickStrokes = THICK_STROKES;
    if (self.numberOfThickStrokes)
        numberOfThickStrokes = [self.numberOfThickStrokes intValue];
    CGFloat currentStrokeAngle = 0.0;
    if (self.currentAngle)
        currentStrokeAngle = [self.currentAngle floatValue];
    CGFloat distanceBetweenStrokeInAngle = DISTANCE_BW_STROKES_IN_ANGLE;
    if (self.distanceBetweenStrokes)
        distanceBetweenStrokeInAngle = [self.distanceBetweenStrokes floatValue];
    CGPoint centerOfCircle = CGPointMake(self.bounds.size.width / 2.0, self.bounds.size.height / 2.0);
    CGFloat radiusOfCircle = self.bounds.size.width / 2.0; // Width and height should be same always!
    CGFloat maxBrightestAlphaVal = MAX_BRIGHTNESS_ALPHA_FOR_A_STROKE;
    if (self.maxAlphaBrightnessForThickestStroke)
    {
        maxBrightestAlphaVal = self.maxAlphaBrightnessForThickestStroke.floatValue;
    }
    CGFloat minBrightestAlphaVal = MIN_BRIGHTNESS_ALPHA_FOR_A_STROKE;
    if (self.minAlphaBrightnessForThinneshStroke)
    {
        minBrightestAlphaVal = self.minAlphaBrightnessForThinneshStroke.floatValue;
    }
    CGFloat alphaStepVal = (maxBrightestAlphaVal - minBrightestAlphaVal) / numberOfThickStrokes; // Alpha delta per stroke!
    for (int i=0; i<numberOfThickStrokes; i++)
    {
        CGMutablePathRef strokePath = CGPathCreateMutable();
        
        CGFloat ithStrokeAngle = currentStrokeAngle - i*distanceBetweenStrokeInAngle;
        // Find point on circumference for the given angle: http://stackoverflow.com/a/839931/260665
        CGFloat iX = centerOfCircle.x + radiusOfCircle * cos(DEGREES_TO_RADIANS(ithStrokeAngle));
        CGFloat iY = centerOfCircle.y + radiusOfCircle * sin(DEGREES_TO_RADIANS(ithStrokeAngle));
        
        // Draw line
        CGFloat iAlphaVal = (maxBrightestAlphaVal - alphaStepVal*i);
        UIColor *lineColor = [UIColor colorWithRed:0.0 green:1.0 blue:0.7 alpha:iAlphaVal];
        CGContextSetStrokeColorWithColor(context, lineColor.CGColor);
        CGPathMoveToPoint(strokePath, nil, centerOfCircle.x, centerOfCircle.y);
        CGPathAddLineToPoint(strokePath, nil, iX, iY);
        CGContextAddPath(context, strokePath);
        CGContextStrokePath(context);
//        CGContextDrawPath(context, kCGPathFillStroke);

        CGPathRelease(strokePath);
    }
}

-(void)startAnimating
{
    [self configureAnimation];
}

-(void)stopAnimating
{
    [self.animationTimer invalidate];
    [self setAnimationTimer:nil];
}

-(void)configureAnimation
{
    if (self.animationTimer)
        [self stopAnimating];
    
    // Frame rate:
    CGFloat frameRate = (1.0 / FRAME_RATE);
    if (self.frameRate)
        frameRate = (1.0 / [self.frameRate floatValue]);
    [NSTimer scheduledTimerWithTimeInterval:frameRate
                                     target:self
                                   selector:@selector(timerFireMethod:)
                                   userInfo:nil
                                    repeats:YES];
}

- (void)timerFireMethod:(NSTimer *)timer
{
    [self setNeedsDisplay];
    
    CGFloat rotationsPerMinute = RPM_VALUE;
    if (self.radarRPM)
        rotationsPerMinute = self.radarRPM.floatValue;
    CGFloat rotationsPerSecond = rotationsPerMinute / 60.0;
    
    // Frame rate:
    CGFloat numberOfFramesInOneSec = FRAME_RATE;
    if (self.frameRate)
        numberOfFramesInOneSec = [self.frameRate floatValue];

    // Number of stepping angles depends upon the rotationsPerSecond and the frame rate. Per rotation = 360 deg
    CGFloat totalAngleToBeCoveredPerSecond = rotationsPerSecond * 360.0;
    CGFloat angleStep = totalAngleToBeCoveredPerSecond / numberOfFramesInOneSec;

    CGFloat currentAngleFloat = self.currentAngle.floatValue;
    currentAngleFloat += angleStep;
    [self setCurrentAngle:[NSNumber numberWithFloat:currentAngleFloat]];
}

@end
