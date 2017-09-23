//
//  LoginViewController.m
//  BicycleRenting
//
//  Created by akshay bansal on 7/24/17.
//  Copyright © 2017 akshay bansal. All rights reserved.
//

#import "LoginViewController.h"
#import "KeychainWrapper.h"
#import "Constants.h"
#import "BicycleRentingVC.h"

@interface LoginViewController ()<UITextFieldDelegate>
@property (nonatomic, strong) UIView *overlayView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Dismiss the keyboard when the user taps outside of a text field
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [self.view addGestureRecognizer:singleTap];

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

- (void)handleSingleTap:(UITapGestureRecognizer *)sender
{
    [self.view endEditing:YES];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)login:(id)sender {
    /*needs to be removed after server working*/
    [self nextPage];
    
//    
//    if (![self isValidUserName]) {
//        [self ShowErrorMsg:@"Invalid UserName" title:@"Error"];
//        return;
//    }
//    if (![self isValidPassword]) {
//        [self ShowErrorMsg:@"Passord should be minimum 3 letter" title:@"Invalid Password"];
//        return;
//    }
//    [self startActivityIndicator];
//    [self loginforUser:self.userName.text withPassword:self.userPassword.text];
}


-(BOOL)isValidUserName
{
    
    if ([self.userName.text length]>0) {
        return true;
    }
    return false;
    
}

-(BOOL)isValidPassword
{
    if ([self.userPassword.text length]>4) {
        return true;
    }
    return false;
}



-(void)loginforUser:(NSString *)user withPassword:(NSString*)password
{
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURL *url = [NSURL URLWithString:UserLoginAPI];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    NSString *postBody = [NSString stringWithFormat:@"{ \"email\": \"%@\",\"password\": \"%@\"}",user,password];
    [request setHTTPBody:[postBody dataUsingEncoding:NSUTF8StringEncoding]];
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
                    
                    [self processResponse:jsonResponse];
                    
                    
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

-(void)ShowErrorCodeMsg:(NSString*)code{
    
    NSString *msg;
    switch ([code integerValue]) {
        case 422:
            msg=@"InvalidJson";
            break;
        case 400:
            msg=@"Bad Request user already exist";
            break;
        case 401:
            msg=@"Unauthorised user ,Please register first";
            break;
        case 1002:
            msg=@"PlaceNotFound";
            break;
        case 1004:
            msg=@"PaymentSuccess";
        default:
            break;
    }
    [self ShowErrorMsg:msg title:@"ERROR"];
    
}




-(void)processResponse:(NSDictionary*)data{

    KeychainWrapper *keychain = [KeychainWrapper new];
    [keychain mySetObject:self.userName.text forKey:UserName];
    [keychain mySetObject:self.userPassword.text forKey:Password];
    [keychain mySetObject:[data valueForKey:@"token"] forKey:Token];
    
    //forword to next screen
    dispatch_async(dispatch_get_main_queue(), ^{
        [self stopActivityIndicator];
        [self nextPage];
    });
    
    
}


-(void)nextPage{

    
    [self dismissViewControllerAnimated:YES completion:nil];
    self.view.window.rootViewController =(UIViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"BicycleRentingVC"];
    
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
