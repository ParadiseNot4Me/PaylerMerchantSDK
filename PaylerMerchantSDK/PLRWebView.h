//
//  PLRWebView.h
//  PaylerMerchantSDK
//
//  Created by Иван Григорьев on 07.05.15.
//  Copyright (c) 2015 poloniumarts. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PLRPayment.h"
#import "PaylerMerchantAPIClient.h"

@interface PLRWebView : UIWebView

- (void)auth3dsForPayment:(PLRPayment *)payment withCompletion:(PLRCompletionBlock)completion;

@end