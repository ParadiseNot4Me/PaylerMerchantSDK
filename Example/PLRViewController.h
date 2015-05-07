//
//  PLRViewController.h
//  PaylerMerchantSDK
//
//  Created by Иван Григорьев on 04.05.15.
//  Copyright (c) 2015 poloniumarts. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PLRPayment.h"

@interface PLRViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic, assign) PLRPayType payType;

@end

