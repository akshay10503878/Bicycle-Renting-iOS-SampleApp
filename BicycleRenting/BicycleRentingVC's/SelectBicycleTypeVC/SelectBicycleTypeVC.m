//
//  SelectBicycleTypeVC.m
//  BicycleRenting
//
//  Created by akshay bansal on 7/25/17.
//  Copyright © 2017 akshay bansal. All rights reserved.
//

#import "SelectBicycleTypeVC.h"
#import "PaymentVC.h"

@interface SelectBicycleTypeVC ()
{
    NSInteger payableAmount;
}

@end

@implementation SelectBicycleTypeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.place.text=self.location.name;
    [self.bicycleType addTarget:self action:@selector(action:) forControlEvents:UIControlEventValueChanged];

}
- (void)action:(id)sender{

    switch (self.bicycleType.selectedSegmentIndex) {
        case 0:
            payableAmount=20;
            break;
            
        case 1:
            payableAmount=40;
            break;
            
        case 2:
            payableAmount=60;
            break;
            
        default:
            break;
    }
    
    [self.payButton setTitle:[NSString stringWithFormat:@"  PAY  $%ld  ",(long)payableAmount] forState:UIControlStateNormal];

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)Back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)pay:(id)sender {
    PaymentVC *vc =(PaymentVC *)[self.storyboard instantiateViewControllerWithIdentifier:@"PaymentVC"];
    vc.location= self.location;
    vc.payableAmount=payableAmount;
    [self presentViewController:vc animated:YES completion:nil];
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
