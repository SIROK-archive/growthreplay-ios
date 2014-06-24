//
//  GRViewController.m
//  GrowthReplaySample
//
//  Created by A13048 on 2014/02/13.
//  Copyright (c) 2014年 SIROK. All rights reserved.
//

#import "GRViewController.h"

@interface GRViewController ()

@end

@implementation GRViewController

@synthesize count;
@synthesize label;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(countUp) userInfo:nil repeats:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) countUp {
    self.count += 0.1f;
    self.label.text = [NSString stringWithFormat:@"%.1lf", self.count];
}

@end
