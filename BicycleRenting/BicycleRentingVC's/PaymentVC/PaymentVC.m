//
//  PaymentVC.m
//  BicycleRenting
//
//  Created by akshay bansal on 7/25/17.
//  Copyright © 2017 akshay bansal. All rights reserved.
//

#import "PaymentVC.h"
#import "Constants.h"
#import "KeychainWrapper.h"

@interface PaymentVC ()

@property (nonatomic, strong) UIView *overlayView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@end

@implementation PaymentVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

     [self.creditCardNumber setKeyboardType:UIKeyboardTypeNumberPad];
     [self.cvv setKeyboardType:UIKeyboardTypeNumberPad];
     [self.expiryDate setKeyboardType:UIKeyboardTypeDefault];
     [self.nameOnCard setKeyboardType:UIKeyboardTypeDefault];
    
    // Dismiss the keyboard when the user taps outside of a text field
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [self.view addGestureRecognizer:singleTap];

    
}


- (void)handleSingleTap:(UITapGestureRecognizer *)sender
{
    [self.view endEditing:YES];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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


- (IBAction)Back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)makePayment:(id)sender {

    //[self startActivityIndicator];
    
    
    if (![self isValidCardNumber]) {
        [self ShowErrorMsg:@"Enter Valid Card Number" title:@"Error"];
        return;
    }
    if (![self isValidName]) {
        [self ShowErrorMsg:@"Enter Valid Name" title:@"Error"];
        return;
    }
    if (![self isValidExpiry]) {
        [self ShowErrorMsg:@"Enter Valid Expiry date" title:@"Error"];
        return;
    }
    if (![self isValidCVV]) {
        [self ShowErrorMsg:@"Enter Valid CVV" title:@"Error"];
        return;
    }
    
    NSArray *datecomponets=[self.expiryDate.text componentsSeparatedByString:@"/"];
    
    NSDictionary *creditCard=[[NSDictionary alloc]
                              initWithObjectsAndKeys:
                              self.location.name,@"placeId",
                              self.creditCardNumber.text,@"number",
                              self.nameOnCard.text,@"name",
                              self.cvv.text,@"cvv",
                              datecomponets[0],@"expiryMonth",
                              datecomponets[1],@"expiryYear",
                              nil];
    
    
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURL *url = [NSURL URLWithString:UserPaymentAPI];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    KeychainWrapper *keychain = [KeychainWrapper new];
    NSString *Authtoken = [keychain myObjectForKey:Token];
    [request addValue:Authtoken forHTTPHeaderField:@"Authorization"];
    
    NSError *error=nil;
    NSData *postData = [NSJSONSerialization dataWithJSONObject:creditCard options:0 error:&error];
    [request setHTTPBody:postData];
    [request setHTTPMethod:@"POST"];
    
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
                    
                    [self RentingCompleted];
                    
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


-(BOOL)isValidCardNumber
{
    
    NSString *stricterFilterString = @"[0-9]{16,16}$";
    NSPredicate *cerditCardTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", stricterFilterString];
    return [cerditCardTest evaluateWithObject:self.creditCardNumber.text];
    
}

-(BOOL)isValidName
{
    if ([self.nameOnCard.text length]>0) {
        return true;
    }
    return false;
}

-(BOOL)isValidExpiry
{
    NSString *stricterFilterString = @"(1[0-2]|0[1-9])/[0-9]{2}";
    NSPredicate *Test = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", stricterFilterString];
    return [Test evaluateWithObject:self.expiryDate.text];
}


-(BOOL)isValidCVV
{
    NSString *stricterFilterString = @"[0-9]{3,3}$";
    NSPredicate *Test = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", stricterFilterString];
    return [Test evaluateWithObject:self.cvv.text];
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


-(void)RentingCompleted{
    dispatch_async(dispatch_get_main_queue(), ^{
    
        [self dismissViewControllerAnimated:YES completion:nil];
        self.view.window.rootViewController =(UIViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"BicycleRentingVC"];
    
    });

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
