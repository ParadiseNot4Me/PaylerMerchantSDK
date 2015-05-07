//
//  PLRTableViewController.m
//  PaylerMerchantSDK
//
//  Created by Иван Григорьев on 04.05.15.
//  Copyright (c) 2015 poloniumarts. All rights reserved.
//

#import "PLRTableViewController.h"
#import "PLRViewController.h"

static NSString *const OneStepSegueIdentifier = @"OneStepSegue";
static NSString *const TwoStepSegueIdentifier = @"TwoStepSegue";

@implementation PLRTableViewController

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    PLRViewController *controller = segue.destinationViewController;
    if ([segue.identifier isEqualToString:OneStepSegueIdentifier]) {
        controller.payType = PLRPayTypeOneStep;
    } else if ([segue.identifier isEqualToString:TwoStepSegueIdentifier]) {
        controller.payType = PLRPayTypeTwoStep;
    }
}

@end
