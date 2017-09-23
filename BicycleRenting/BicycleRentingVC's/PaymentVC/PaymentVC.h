//
//  PaymentVC.h
//  BicycleRenting
//
//  Created by akshay bansal on 7/25/17.
//  Copyright © 2017 akshay bansal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BiclycleLocation.h"

@interface PaymentVC : UIViewController

@property(nonatomic,strong)BiclycleLocation *location;
@property(nonatomic,assign)NSInteger payableAmount;
@property (strong, nonatomic) IBOutlet UITextField *creditCardNumber;
@property (strong, nonatomic) IBOutlet UITextField *nameOnCard;
@property (strong, nonatomic) IBOutlet UITextField *expiryDate;
@property (strong, nonatomic) IBOutlet UITextField *cvv;

@end
