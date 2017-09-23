//
//  MyCustomPinAnnotationView.m
//  MyCustomPinProject
//
//  Created by Thomas Lextrait on 1/4/16.
//  Copyright © 2016 com.tlextrait. All rights reserved.
//

#import "MyCustomPinAnnotationView.h"
#import "BiclycleLocation.h"

@implementation MyCustomPinAnnotationView

- (instancetype)initWithAnnotation:(id<MKAnnotation>)annotation
{
    // The re-use identifier is always nil because these custom pins may be visually different from one another
    self = [super initWithAnnotation:annotation
                     reuseIdentifier:nil];
    
    // Fetch all necessary data from the point object
    BiclycleLocation* myCustomPointAnnotation = (BiclycleLocation*) annotation;
    self.name = myCustomPointAnnotation.name;
    
    // Callout settings - if you want a callout bubble
    self.canShowCallout = YES;
    self.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    self.image = [UIImage imageNamed:@"myPinImage"];
    
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(4, 5, 30, 25)];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor blackColor];
    label.text = [NSString stringWithFormat:@"$%@", self.name];
    label.font = [label.font fontWithSize:9];
    [self addSubview:label];
    
    return self;
}

- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent*)event
{
    UIView* hitView = [super hitTest:point withEvent:event];
    if (hitView != nil)
    {
        [self.superview bringSubviewToFront:self];
    }
    return hitView;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent*)event
{
    CGRect rect = self.bounds;
    BOOL isInside = CGRectContainsPoint(rect, point);
    if(!isInside)
    {
        for (UIView *view in self.subviews)
        {
            isInside = CGRectContainsPoint(view.frame, point);
            if(isInside)
                break;
        }
    }
    return isInside;
}

@end
