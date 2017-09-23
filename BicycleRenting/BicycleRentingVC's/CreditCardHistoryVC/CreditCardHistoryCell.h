//
//  CreditCardHistoryCell.h
//  BicycleRenting
//
//  Created by akshay bansal on 7/25/17.
//  Copyright © 2017 akshay bansal. All rights reserved.
//


#import <UIKit/UIKit.h>


@interface CreditCardHistoryCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UITextField *creditCardNumber;
@property (weak, nonatomic) IBOutlet UITextField *name;
@property (weak, nonatomic) IBOutlet UITextField *expiryDate;
@property (weak, nonatomic) IBOutlet UITextField *cvv;
@property (weak, nonatomic) IBOutlet UITextField *placeID;

@end
