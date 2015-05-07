//
//  PLRViewController.m
//  PaylerMerchantSDK
//
//  Created by Иван Григорьев on 04.05.15.
//  Copyright (c) 2015 poloniumarts. All rights reserved.
//

#import "PLRViewController.h"
#import "SVProgressHUD.h"
#import "PLRWebView.h"
#import "PaylerMerchantApiClient.h"
#import "PLRCardInfo.h"


@interface PLRViewController ()
@property (weak, nonatomic) IBOutlet UITextField *cardNumberTextField;
@property (weak, nonatomic) IBOutlet UITextField *cardHolderTextField;
@property (weak, nonatomic) IBOutlet UITextField *cardExpirationDateTextField;
@property (weak, nonatomic) IBOutlet UITextField *cardCVVTextField;
@property (weak, nonatomic) IBOutlet UITextField *orderAmountTextField;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet PLRWebView *webView;
@property (weak, nonatomic) IBOutlet UIButton *payButton;
@property (weak, nonatomic) IBOutlet UIButton *refundButton;
@property (weak, nonatomic) IBOutlet UIButton *chargeButton;

@property (nonatomic, strong) PaylerMerchantAPIClient *client;
@property (nonatomic, strong) PLRPayment *payment;

@end

@implementation PLRViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.payType == PLRPayTypeOneStep) {
        self.title = @"Одностадийный платеж";
    } else if (self.payType == PLRPayTypeTwoStep) {
        self.title = @"Двухстадийный платеж";
    }
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
}

#pragma mark - Actions

- (IBAction)payButtonPressed:(id)sender {
    
    NSString *paymentId = [NSString stringWithFormat:@"SDK_iOS_%@", [[NSUUID UUID] UUIDString]];
    NSArray *orderAmountComponents = [self.orderAmountTextField.text componentsSeparatedByString:@"."];
    NSUInteger orderAmount = [orderAmountComponents count] == 1 ? orderAmount = [orderAmountComponents[0] intValue]*100 : [orderAmountComponents[0] intValue]*100 + [orderAmountComponents[1] intValue];
    PLRPayment *payment = [[PLRPayment alloc] initWithId:paymentId amount:orderAmount];
    NSArray *cardDateComponents = [self.cardExpirationDateTextField.text componentsSeparatedByString:@"/"];
    NSString *cardNumber = [self.cardNumberTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    PLRCardInfo *cardInfo = [[PLRCardInfo alloc] initWithCardNumber:cardNumber cardHolder:self.cardHolderTextField.text expiredYear:cardDateComponents[1] expiredMonth:cardDateComponents[0] secureCode:self.cardCVVTextField.text];
    self.payment = payment;
    #warning Здесь нужно указать ваши параметры.
    self.client = [PaylerMerchantAPIClient testClientWithMerchantKey:@"TestMerchantBM"];
    
    if (self.payType == PLRPayTypeOneStep) {
        [SVProgressHUD showWithStatus:@"Списание средств"];
        [self.client payPayment:payment withCardInfo:cardInfo completion:^(PLRPayment *payment, NSError *error) {
            if (!error) {
                self.refundButton.hidden = NO;
                if (payment.authType) {
                    self.webView.hidden = NO;
                    [SVProgressHUD showSuccessWithStatus:@"3DS"];
                    
                    [self.webView auth3dsForPayment:payment withCompletion:^(PLRPayment *payment, NSError *error) {
                        self.webView.hidden = YES;
                        [SVProgressHUD showWithStatus:@"Списание средств"];
                        [self.client pay3DSPayment:payment completion:^(PLRPayment *payment, NSError *error) {
                            if (!error) {
                                [self clearTextField];
                                [SVProgressHUD showSuccessWithStatus:@"Средства успешно списаны"];
                                
                            }
                        }];
                    }];
                } else {
                    [self clearTextField];
                    [SVProgressHUD showSuccessWithStatus:@"Средства успешно списаны"];
                }
                
            } else {
                [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@", [[error.userInfo objectForKey:NSUnderlyingErrorKey] localizedDescription]]];
            }
        }];
    } else if (self.payType == PLRPayTypeTwoStep) {
        [SVProgressHUD showWithStatus:@"Блокировка средств"];
        [self.client blockPayment:payment withCardInfo:cardInfo completion:^(PLRPayment *payment, NSError *error) {
            if (!error) {
                self.refundButton.hidden = NO;
                self.chargeButton.hidden = NO;
                if (payment.authType) {
                    self.webView.hidden = NO;
                    [SVProgressHUD showSuccessWithStatus:@"3DS"];
                    
                    [self.webView auth3dsForPayment:payment withCompletion:^(PLRPayment *payment, NSError *error) {
                        self.webView.hidden = YES;
                        [SVProgressHUD showWithStatus:@"Блокировка средств"];
                        [self.client block3DSPayment:payment completion:^(PLRPayment *payment, NSError *error) {
                            if (!error) {
                                [self clearTextField];
                                [SVProgressHUD showSuccessWithStatus:@"Средства успешно заблокированы"];
                            }
                        }];
                    }];
                } else {
                    [self clearTextField];
                    [SVProgressHUD showSuccessWithStatus:@"Средства успешно заблокированы"];
                }
                
            } else {
                [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@", [[error.userInfo objectForKey:NSUnderlyingErrorKey] localizedDescription]]];
            }

        }];
    }
}
- (IBAction)refundButtonPressed:(id)sender {
    
    if (self.payType == PLRPayTypeOneStep) {
        [SVProgressHUD showWithStatus:@"Возврат средств"];
        [self.client refundPayment:self.payment completion:^(PLRPayment *payment, NSError *error) {
            if (!error) {
                [SVProgressHUD showSuccessWithStatus:@"Средства успешно возвращены"];
                [self hideButtons];
            }
        }];
    } else if (self.payType == PLRPayTypeTwoStep) {
        [SVProgressHUD showWithStatus:@"Разблокирование средств"];
        [self.client retrievePayment:self.payment completion:^(PLRPayment *payment, NSError *error) {
            if (!error) {
                [SVProgressHUD showSuccessWithStatus:@"Средства успешно разблокированы"];
                [self hideButtons];
            }
        }];
    }
    
}

- (IBAction)chargeButtonPressed:(id)sender {
    [SVProgressHUD showWithStatus:@"Списание средств"];
    [self.client chargePayment:self.payment completion:^(PLRPayment *payment, NSError *error) {
        if(!error){
            [SVProgressHUD showSuccessWithStatus:@"Средства успешно списаны"];
            [self hideButtons];
        }
    }];
}

- (void)clearTextField {
    self.cardNumberTextField.text = @"";
    self.cardHolderTextField.text = @"";
    self.cardCVVTextField.text = @"";
    self.cardExpirationDateTextField.text = @"";
    self.orderAmountTextField.text = @"";
}

- (void) hideButtons {
    self.chargeButton.hidden = YES;
    self.payButton.hidden = NO;
    self.refundButton.hidden = YES;
}

#pragma mark - UITextFieldDelegate implementation

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField isEqual:self.cardNumberTextField]) {
        if (textField.text.length == 19) {
            [self.cardHolderTextField becomeFirstResponder];
            return YES;
        } else {
            [SVProgressHUD showErrorWithStatus:@"Введите корректный номер карты"];
            return NO;
        }
    }
    
    if ([textField isEqual:self.cardHolderTextField]) {
        [self.cardExpirationDateTextField becomeFirstResponder];
        return YES;
    }
    
    if ([textField isEqual:self.cardExpirationDateTextField]) {
        if (textField.text.length < 5) {
            [SVProgressHUD showErrorWithStatus:@"Введите 4 цифры даты окончания действия карты в формате MM/YY"];
            return NO;
        }
        
        NSArray *dateComponents = [textField.text componentsSeparatedByString:@"/"];
        if(dateComponents.count == 2) {
            NSDate *date = [NSDate date];
            NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
            NSDateComponents *components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit) fromDate:date];
            NSInteger currentMonth = [components month];
            NSInteger currentYear = [[[NSString stringWithFormat:@"%ld",(long)[components year]] substringFromIndex:2] integerValue];
            
            if([dateComponents[1] intValue] < currentYear) {
                [SVProgressHUD showErrorWithStatus:@"Карта недействительна."];
                return NO;
            }
            
            if (([dateComponents[0] intValue] > 12)) {
                [SVProgressHUD showErrorWithStatus:@"Карта недействительна."];
                return NO;
            }
            
            if([dateComponents[0] integerValue] < currentMonth && [dateComponents[1] intValue] <= currentYear) {
                [SVProgressHUD showErrorWithStatus:@"Карта недействительна."];
                return NO;
            }
        }
        
        [self.cardCVVTextField becomeFirstResponder];
        return YES;
    }
    
    if ([textField isEqual:self.cardCVVTextField]) {
        if (textField.text.length == 0) {
            [SVProgressHUD showErrorWithStatus:@"Введите CVV код"];
            return NO;
        }
        [self.orderAmountTextField becomeFirstResponder];
        return YES;
    }
    
    [self.scrollView setContentOffset:CGPointMake(0,0) animated:YES];
    [textField resignFirstResponder];
    return YES;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (range.length > 0 && [string length] == 0) {
        return YES;
    }
    
    if ([textField isEqual:self.cardNumberTextField]) {
        if (textField.text.length >= 19) {
            return NO;
        }
        
        NSString *addChar = [[string componentsSeparatedByCharactersInSet:
                              [[NSCharacterSet decimalDigitCharacterSet] invertedSet]]
                             componentsJoinedByString:@""];
        switch (textField.text.length) {
            case 3:
            case 8:
            case 13:
                textField.text = [textField.text stringByAppendingString:addChar];
                textField.text = [textField.text stringByAppendingString:@" "];
                break;
            default:
                textField.text = [textField.text stringByAppendingString:addChar];
                break;
        }
        return NO;
    }
    
    if ([textField isEqual:self.cardExpirationDateTextField]) {
        if (textField.text.length >= 5) {
            return NO;
        }
        
        NSString *addChar = [[string componentsSeparatedByCharactersInSet:
                              [[NSCharacterSet decimalDigitCharacterSet] invertedSet]]
                             componentsJoinedByString:@""];
        
        switch (textField.text.length) {
            case 1:
                textField.text = [textField.text stringByAppendingString:addChar];
                textField.text = [textField.text stringByAppendingString:@"/"];
                break;
            default:
                textField.text = [textField.text stringByAppendingString:addChar];
                break;
        }
        
        return NO;
    }
    
    if ([textField isEqual:self.cardCVVTextField]) {
        NSString *addChar = [[string componentsSeparatedByCharactersInSet:
                              [[NSCharacterSet decimalDigitCharacterSet] invertedSet]]
                             componentsJoinedByString:@""];
        textField.text = [textField.text stringByAppendingString:addChar];
        return NO;
    }
    
    if ([textField isEqual:self.orderAmountTextField]) {
        NSString *addChar = [[string componentsSeparatedByCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789."] invertedSet]] componentsJoinedByString:@""];
        textField.text = [textField.text stringByAppendingString:addChar];
        return NO;
    }
    
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if ([textField isEqual:self.cardExpirationDateTextField] || [textField isEqual:self.cardCVVTextField] || [textField isEqual:self.orderAmountTextField]) {
        [self.scrollView setContentOffset:CGPointMake(0,textField.center.y-140) animated:YES];
    } else {
         [self.scrollView setContentOffset:CGPointMake(0,0) animated:YES];
    }
    
    
}

@end
