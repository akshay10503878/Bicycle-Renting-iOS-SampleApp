//
//  BicycleRentingVC.m
//  BicycleRenting
//
//  Created by akshay bansal on 7/25/17.
//  Copyright © 2017 akshay bansal. All rights reserved.
//

#import "BicycleRentingVC.h"
#import "BiclycleLocation.h"
#import "SelectBicycleTypeVC.h"
#import "Constants.h"

@interface BicycleRentingVC ()
{
    NSMutableArray *bicycleLocations;

}
@property (nonatomic, strong) UIView *overlayView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;


@end

@implementation BicycleRentingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.mapView.delegate=self;
    self.mapView.showsUserLocation = YES;
    [self addAllPins];
    
    bicycleLocations=[[NSMutableArray alloc] init];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




- (void)getMapCoordinates {
    
    //[self startActivityIndicator];

    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURL *url = [NSURL URLWithString:UserPlacesAPI];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setHTTPMethod:@"GET"];
    
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (!error && data!=nil)
        {
            if ([response isKindOfClass:[NSHTTPURLResponse class]])
            {
                NSError *jsonError=nil;
                NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
                
                if (jsonError) {
                    [self ShowErrorMsg:@"Json Parsing Error" title:@"ERROR"];
                    
                }
                else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [self stopActivityIndicator];
                    });
                    [self plotBicyclePositions:data];
                    
                }
            }
            else
            {
                [self ShowErrorMsg:@"Response Error" title:@"ERROR"];
                
            }
        }
        else
        {
            NSLog(@"error : %@",@[error.localizedDescription]);
            [self ShowErrorMsg:error.localizedDescription title:@"ERROR"];
        }
    }] ;
    
    [postDataTask resume];
    [session finishTasksAndInvalidate];
    
}


-(void)ShowErrorMsg:(NSString*)msg title:(NSString*)title{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        UIAlertController *alert=[UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *ok=[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
            
        }];
        [alert addAction:ok];
        
        [self presentViewController:alert animated:YES completion:nil];
        
        
    });
    
    
}


-(void) startActivityIndicator{
    
    self.overlayView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.overlayView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.activityIndicator.center = self.overlayView.center;
    [self.overlayView addSubview:self.activityIndicator];
    [self.activityIndicator startAnimating];
    [self.view addSubview:self.overlayView];
    
}

-(void) stopActivityIndicator{
    
    [self.activityIndicator stopAnimating];
    [self.overlayView removeFromSuperview];
    self.overlayView=nil;
    self.activityIndicator=nil;
    
    
}



#pragma MapView Delegate Functions
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 800, 800);
    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
    
    // Add an annotation
    MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
    point.coordinate = userLocation.coordinate;
    point.title = @"Where am I?";
    
    [self.mapView addAnnotation:point];

}

- (MKAnnotationView *)mapView:(MKMapView *)map viewForAnnotation:(id <MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
         [self.mapView.userLocation setTitle:@"I am here"];
        return nil;
    }
    static NSString *AnnotationViewID = @"annotationView";
    
    MKAnnotationView *annotationView = (MKAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:AnnotationViewID];
    
    if (annotationView == nil){
        annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID];
    }
    else{
        annotationView.annotation = annotation;
    }
    
    annotationView.image = [UIImage imageNamed:@"locationPin.png"];

    
    UIImageView *imageView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bookingIcon.png"]];
    annotationView.leftCalloutAccessoryView = imageView;

    
    UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 25, 25);
    [button setImage:[UIImage imageNamed:@"next.png"] forState:UIControlStateNormal];
    annotationView.rightCalloutAccessoryView = button;
    
    [annotationView setCanShowCallout:YES];
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    
    [self dismissViewControllerAnimated:YES completion:nil];
    SelectBicycleTypeVC *vc =(SelectBicycleTypeVC *)[self.storyboard instantiateViewControllerWithIdentifier:@"SelectBicycleTypeVC"];
    vc.location= view.annotation;
    [self presentViewController:vc animated:YES completion:nil];

    
}






-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    
    
}


#pragma try
-(void)addAllPins
{
    
    NSArray *name=[[NSArray alloc]initWithObjects:
                   @"VelaCherry",
                   @"Perungudi",
                   @"Tharamani", nil];
    
    NSMutableArray *arrCoordinateStr = [[NSMutableArray alloc] initWithCapacity:name.count];
    
    [arrCoordinateStr addObject:@"12.970760345459, 80.2190093994141"];
    [arrCoordinateStr addObject:@"12.9752297537231, 80.2313079833984"];
    [arrCoordinateStr addObject:@"12.9788103103638, 80.2412414550781"];
    
    for(int i = 0; i < name.count; i++)
    {
        [self addPinWithTitle:name[i] AndCoordinate:arrCoordinateStr[i]];
    }
    [self.mapView setSelectedAnnotations:bicycleLocations];
    [self zoomToFitMapAnnotations:self.mapView];
    [self.mapView setSelectedAnnotations:bicycleLocations];
}


-(void)addPinWithTitle:(NSString *)title AndCoordinate:(NSString *)strCoordinate
{
    // clear out any white space
    strCoordinate = [strCoordinate stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    // convert string into actual latitude and longitude values
    NSArray *components = [strCoordinate componentsSeparatedByString:@","];
    
    double latitude = [components[0] doubleValue];
    double longitude = [components[1] doubleValue];
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
    
    
    BiclycleLocation *newlocation = [[BiclycleLocation alloc] init];
    newlocation.name=title;

    newlocation.coordinate=coordinate;
    
    [bicycleLocations addObject:newlocation];
    [_mapView addAnnotation:newlocation];
    
}





#pragma plot bicle positions from downloaded data
- (void)plotBicyclePositions:(NSData *)responseData {
    
    /*--Clear the Old Data--*/
    for (id<MKAnnotation> annotation in self
         .mapView.annotations) {
        [self.mapView removeAnnotation:annotation];
    }
    
    
    NSDictionary *root = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
    NSArray *data = [root objectForKey:@"places"];
    
    for (NSDictionary *row in data) {
        double  latitude = [[[row objectForKey:@"location"] valueForKey:@"lat"] doubleValue];
        double  longitude = [[[row objectForKey:@"location"] valueForKey:@"lng"] doubleValue];
        NSString * name = [row objectForKey:@"name"];
        NSString * location_id = [row objectForKey:@"id"];
        CLLocationCoordinate2D coordinate;
        coordinate.latitude = latitude;
        coordinate.longitude = longitude;
        
        BiclycleLocation *newlocation = [[BiclycleLocation alloc] init];
        newlocation.name=name;
        newlocation.location_id=location_id;
        newlocation.coordinate=coordinate;
        
        [bicycleLocations addObject:newlocation];
        [_mapView addAnnotation:newlocation];
    }
}

- (void)zoomToFitMapAnnotations:(MKMapView *)mapView {
    if ([mapView.annotations count] == 0) return;
    
    CLLocationCoordinate2D topLeftCoord;
    topLeftCoord.latitude = -90;
    topLeftCoord.longitude = 180;
    
    CLLocationCoordinate2D bottomRightCoord;
    bottomRightCoord.latitude = 90;
    bottomRightCoord.longitude = -180;
    
    for(id<MKAnnotation> annotation in mapView.annotations) {
        topLeftCoord.longitude = fmin(topLeftCoord.longitude, annotation.coordinate.longitude);
        topLeftCoord.latitude = fmax(topLeftCoord.latitude, annotation.coordinate.latitude);
        bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, annotation.coordinate.longitude);
        bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, annotation.coordinate.latitude);
    }
    
    MKCoordinateRegion region;
    region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5;
    region.center.longitude = topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5;
    
    // Add a little extra space on the sides
    region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 1.1;
    region.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 1.1;
    
    region = [mapView regionThatFits:region];
    [mapView setRegion:region animated:YES];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
