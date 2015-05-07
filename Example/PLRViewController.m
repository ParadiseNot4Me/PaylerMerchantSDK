//
//  PLRViewController.m
//  PaylerMerchantSDK
//
//  Created by Иван Григорьев on 04.05.15.
//  Copyright (c) 2015 poloniumarts. All rights reserved.
//

#import "PLRViewController.h"
#import "SVProgressHUD.h"

@interface PLRViewController ()
@property (weak, nonatomic) IBOutlet UITextField *cardNumberTextField;
@property (weak, nonatomic) IBOutlet UITextField *cardHolderTextField;
@property (weak, nonatomic) IBOutlet UITextField *cardExpirationDateTextField;
@property (weak, nonatomic) IBOutlet UITextField *cardCVVTextField;
@property (weak, nonatomic) IBOutlet UITextField *orderAmountTextField;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation PLRViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
}


#pragma mark - Actions

- (IBAction)payButtonPressed:(id)sender {
    
}
- (IBAction)refundButtonPressed:(id)sender {
    
}

- (IBAction)chargeButtonPressed:(id)sender {
    
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
