//
//  Utility.h
//  BicycleRenting
//
//  Created by akshay bansal on 7/25/17.
//  Copyright © 2017 akshay bansal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utility : NSObject


-(void)ShowErrorMsg:(NSString*)msg title:(NSString*)title;
+(void)ShowErrorCodeMsg:(NSString*)code;
@end
