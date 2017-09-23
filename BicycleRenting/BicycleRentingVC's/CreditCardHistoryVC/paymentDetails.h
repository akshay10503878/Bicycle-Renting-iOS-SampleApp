//
//  paymentDetails.h
//  BicycleRenting
//
//  Created by akshay bansal on 7/25/17.
//  Copyright © 2017 akshay bansal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface paymentDetails : NSObject

@property(nonatomic,copy)NSString*updatedAt;
@property(nonatomic,copy)NSString*createdAt;

/*--credit card details--*/
@property(nonatomic,copy)NSString *number;
@property(nonatomic,copy)NSString *name;
@property(nonatomic,copy)NSString *cvv;
@property(nonatomic,copy)NSString *expiryMonth;
@property(nonatomic,copy)NSString *expiryyear;

/*--renting details--*/
@property(nonatomic,copy)NSString *email;
@property(nonatomic,copy)NSString *placeId;
@end
