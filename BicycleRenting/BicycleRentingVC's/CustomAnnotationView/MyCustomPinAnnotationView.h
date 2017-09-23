//
//  MyCustomPinAnnotationView.h
//  MyCustomPinProject
//
//  Created by Thomas Lextrait on 1/4/16.
//  Copyright © 2016 com.tlextrait. All rights reserved.
//

#import <MapKit/MapKit.h>


@interface MyCustomPinAnnotationView : MKAnnotationView

@property (nonatomic,copy) NSString *name;

- (instancetype)initWithAnnotation:(id<MKAnnotation>)annotation;

@end
