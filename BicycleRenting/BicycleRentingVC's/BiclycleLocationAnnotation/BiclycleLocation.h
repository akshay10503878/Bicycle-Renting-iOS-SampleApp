//
//  biclycleLocation.h
//  BicycleRenting
//
//  Created by akshay bansal on 7/25/17.
//  Copyright © 2017 akshay bansal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
@interface BiclycleLocation : MKPointAnnotation

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *location_id;

@end
