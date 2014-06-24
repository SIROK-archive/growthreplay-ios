//
//  GRViewController.h
//  GrowthReplaySample
//
//  Created by A13048 on 2014/02/13.
//  Copyright (c) 2014年 SIROK. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GRViewController : UIViewController {
    
    float count;
    IBOutlet UILabel *label;
    
}

@property (nonatomic) float count;
@property (nonatomic) IBOutlet UILabel *label;

@end
