//
//  PLRCardInfo.m
//  PaylerMerchantSDK
//
//  Created by Иван Григорьев on 07.05.15.
//  Copyright (c) 2015 poloniumarts. All rights reserved.
//

#import "PLRCardInfo.h"

@interface PLRCardInfo ()

@property (nonatomic, readwrite, copy) NSString *cardNumber;

@property (nonatomic, readwrite, copy) NSString *cardHolder;

@property (nonatomic, readwrite, copy) NSString *expiredYear;

@property (nonatomic, readwrite, copy) NSString *expiredMonth;

@property (nonatomic, readwrite, copy) NSString *secureCode;

@end

@implementation PLRCardInfo

- (instancetype)initWithCardNumber:(NSString *)cardNumber cardHolder:(NSString *)cardHolder expiredYear:(NSString *)expiredYear
                      expiredMonth:(NSString *)expiredMonth secureCode:(NSString *)secureCode{
    self = [super init];
    if (self) {
        _cardNumber = cardNumber;
        _cardHolder = cardHolder;
        _expiredYear = expiredYear;
        _expiredMonth = expiredMonth;
        _secureCode = secureCode;
    }
    return  self;
}


- (NSDictionary *)dictionaryRepresentation {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    parameters[@"card_number"] = self.cardNumber;
    parameters[@"card_holder"] = self.cardHolder;
    parameters[@"expired_year"] = self.expiredYear;
    parameters[@"expired_month"] = self.expiredMonth;
    parameters[@"secure_code"] = self.secureCode;
    return [parameters copy];
}

@end