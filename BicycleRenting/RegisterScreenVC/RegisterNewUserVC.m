//
//  RegisterNewUserVC.m
//  BicycleRenting
//
//  Created by akshay bansal on 7/24/17.
//  Copyright © 2017 akshay bansal. All rights reserved.
//

#import "RegisterNewUserVC.h"
#import "KeychainWrapper.h"

@interface RegisterNewUserVC ()

@property (nonatomic, strong) UIView *overlayView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@end

@implementation RegisterNewUserVC

- (void)viewDidLoad {
    [super viewDidLoad];
    /*--adding tap gesture to dismiss keyboard --*/
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

- (IBAction)Register:(id)sender {
    //[self startActivityIndicator];
    //[self RegisterforUser:self.userName.text withPassword:self.userPassword.text];
    [self nextPage];
    
}



-(void)RegisterforUser:(NSString *)user withPassword:(NSString*)password
{
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURL *url = [NSURL URLWithString:UserRegisterationAPI];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    NSString *postBody = [NSString stringWithFormat:@"{ \"email\": \"%@\",\"password\": \"%@\"}",user,password];
    [request setHTTPBody:[postBody dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPMethod:@"PUT"];
    
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
                    
                    // [self.delegate DownLoadCompletedWithData:jsonResponse];
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


- (IBAction)previousVC:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}



@end
