//
//  RPGViewController.m
//  RPGRadarView
//
//  Created by Gumdal, Raj Pawan on 5/7/14.
//  Copyright (c) 2014 Gumdal, Raj Pawan. All rights reserved.
//

#import "RPGViewController.h"

@interface RPGViewController ()

@end

@implementation RPGViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self.radarView startAnimating];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
