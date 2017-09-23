//
//  SelectBicycleTypeVC.h
//  BicycleRenting
//
//  Created by akshay bansal on 7/25/17.
//  Copyright © 2017 akshay bansal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BiclycleLocation.h"

@interface SelectBicycleTypeVC : UIViewController
@property(nonatomic,strong)BiclycleLocation *location;
@property (strong, nonatomic) IBOutlet UILabel *place;
@property (strong, nonatomic) IBOutlet UISegmentedControl *bicycleType;
@property (strong, nonatomic) IBOutlet UIButton *payButton;
@end
