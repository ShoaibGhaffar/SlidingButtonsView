//
//  ViewController.m
//  ButtonSlider
//
//  Created by Shoaib Mac Mini on 04/09/2013.
//  Copyright (c) 2013 Shoaib Mac Mini. All rights reserved.
//

#import "ViewController.h"
#import "SlidingButtonsView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    SlidingButtonsView* sliderButtonView1 = [[SlidingButtonsView alloc] initWithDirection:kSliderDirectionLeft Position:CGPointMake(300, 300) ButtonImages:@"button.png", @"button.png", @"button.png", @"button.png", @"button.png", nil];
    [self.view addSubview:sliderButtonView1];
    
    SlidingButtonsView* sliderButtonView2 = [[SlidingButtonsView alloc] initWithDirection:kSliderDirectionTop Position:CGPointMake(400, 300) ButtonImages:@"button.png", @"button.png", @"button.png", @"button.png", @"button.png", nil];
    [self.view addSubview:sliderButtonView2];
    
    SlidingButtonsView* sliderButtonView3 = [[SlidingButtonsView alloc] initWithDirection:kSliderDirectionDown Position:CGPointMake(300, 400) ButtonImages:@"button.png", @"button.png", @"button.png", @"button.png", @"button.png", nil];
    [self.view addSubview:sliderButtonView3];
    
    SlidingButtonsView* sliderButtonView4 = [[SlidingButtonsView alloc] initWithDirection:kSliderDirectionRight Position:CGPointMake(400, 400) ButtonImages:@"button.png", @"button.png", @"button.png", @"button.png", @"button.png" , nil];
    [self.view addSubview:sliderButtonView4];
    
    
    //[NSMutableArray arrayWithObjects:@"button.png", @"button.png", @"button.png", @"button.png", @"button.png", nil]
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
