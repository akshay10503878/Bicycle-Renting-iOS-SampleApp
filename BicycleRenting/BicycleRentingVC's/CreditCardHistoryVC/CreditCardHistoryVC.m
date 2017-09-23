//
//  CreditCardHistoryVC.m
//  BicycleRenting
//
//  Created by akshay bansal on 7/25/17.
//  Copyright © 2017 akshay bansal. All rights reserved.
//

#import "CreditCardHistoryVC.h"
#import "Constants.h"
#import "paymentDetails.h"
#import "KeychainWrapper.h"
#import "CreditCardHistoryCell.h"

@interface CreditCardHistoryVC ()
{
    NSMutableArray *paymentHistoryData;

}
@property (nonatomic, strong) UIView *overlayView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;


@end

@implementation CreditCardHistoryVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    paymentHistoryData=[[NSMutableArray alloc] init];
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    self.tableView.allowsSelection = NO;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 44.0;
    
    //[self getPaymentHistory];
    
    NSString *string=@"{\r\n    \"payments\": [{\r\n      \"updatedAt\": \"2016-12-23T19:32:59.144Z\",\r\n      \"createdAt\": \"2016-12-23T19:32:59.144Z\",\r\n      \"creditCard\": {\r\n        \"number\": \"4111111111111111\",\r\n        \"name\": \"adrianobragaalencar\",\r\n        \"cvv\": \"123\",\r\n        \"expiryMonth\": \"03\",\r\n        \"expiryYear\": \"2100\"\r\n      },\r\n      \"email\": \"adrianobragaalencar@gmail.com\",\r\n      \"placeId\": \"45c0b5209973fcec652817e16e20f1d0b4ecb602\"\r\n    }, \r\n    {\r\n      \"updatedAt\": \"2016-12-23T19:33:25.497Z\",\r\n      \"createdAt\": \"2016-12-23T19:33:25.497Z\",\r\n      \"creditCard\": {\r\n        \"number\": \"4111111111111111\",\r\n        \"name\": \"adrianobragaalencar\",\r\n        \"cvv\": \"123\",\r\n        \"expiryMonth\": \"12\",\r\n        \"expiryYear\": \"2020\"\r\n      },\r\n      \"email\": \"adrianobragaalencar@gmail.com\",\r\n      \"placeId\": \"45c0b5209973fcec652817e16e20f1d0b4ecb602\"\r\n    }]\r\n}";

    NSError *jsonError;
    NSData *objectData = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:objectData
                                                         options:NSJSONReadingMutableContainers
                                                           error:&jsonError];


    [self parsePaymentsHistory:json];
    
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


- (void)getPaymentHistory {
    
    //[self startActivityIndicator];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURL *url = [NSURL URLWithString:UserPaymentHistoryAPI];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    KeychainWrapper *keychain = [KeychainWrapper new];
    NSString *Authtoken = [keychain myObjectForKey:Token];
    [request addValue:Authtoken forHTTPHeaderField:@"Authorization"];
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
                    [self parsePaymentsHistory:jsonResponse];
                    
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

-(void)parsePaymentsHistory:(NSDictionary *)jsonResponse{

    NSArray *payments=[jsonResponse objectForKey:@"payments"];
    
    for (NSDictionary *obj in payments) {
        
        paymentDetails *pd=[[paymentDetails alloc] init];
        pd.updatedAt=[obj objectForKey:@"updatedAt"];
        pd.createdAt=[obj objectForKey:@"createdAt"];
        pd.email=[obj objectForKey:@"email"];
        pd.placeId=[obj objectForKey:@"placeId"];
        NSDictionary *creditCard=[obj objectForKey:@"creditCard"];
        pd.name=[creditCard objectForKey:@"name"];
        pd.number=[creditCard objectForKey:@"number"];
        pd.cvv=[creditCard objectForKey:@"cvv"];
        pd.expiryMonth=[creditCard objectForKey:@"expiryMonth"];
        pd.expiryyear=[creditCard objectForKey:@"expiryYear"];
        
        [paymentHistoryData addObject:pd];
    }
    

}
- (IBAction)Back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}



-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    
    return [[UIView alloc] initWithFrame:CGRectZero];;
}



#pragma mark - Table view data source
 - (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
      return 1;
 }


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
       return [paymentHistoryData count];
 }

 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
     
     CreditCardHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CreditCardHistoryCell" forIndexPath:indexPath];
 
     if (cell==nil) {
          cell =[[CreditCardHistoryCell alloc] init];
     }
     
     paymentDetails *detail=[paymentHistoryData objectAtIndex:indexPath.row];
     [cell.creditCardNumber setText:detail.number];
     [cell.name setText:detail.name];
     [cell.expiryDate setText:[NSString stringWithFormat:@"%@/%@",detail.expiryMonth,detail.expiryyear]];
     [cell.cvv setText:detail.cvv];
     [cell.placeID setText:detail.placeId];
     
     if (indexPath.row%2==0) {
         [cell setBackgroundColor:[UIColor colorWithRed:224/255.0f green:247/255.0f blue:250/255.0f alpha:1]];
     }
     else
     {
         [cell setBackgroundColor:[UIColor colorWithRed:128/255.0f green:222/255.0f blue:234/255.0f alpha:1]];
     }

 
 return cell;
 }
 


 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

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
