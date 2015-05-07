//
//  PLRCardInfo.h
//  PaylerMerchantSDK
//
//  Created by Иван Григорьев on 07.05.15.
//  Copyright (c) 2015 poloniumarts. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PLRCardInfo : NSObject

@property (nonatomic, readonly, copy) NSString *cardNumber;

@property (nonatomic, readonly, copy) NSString *cardHolder;

@property (nonatomic, readonly, copy) NSString *expiredYear;

@property (nonatomic, readonly, copy) NSString *expiredMonth;

@property (nonatomic, readonly, copy) NSString *secureCode;

- (NSDictionary *)dictionaryRepresentation;

- (instancetype)initWithCardNumber:(NSString *)cardNumber cardHolder:(NSString *)cardHolder expiredYear:(NSString *)expiredYear
                      expiredMonth:(NSString *)expiredMonth secureCode:(NSString *)secureCode;

- (id)init __attribute__((unavailable("Must use initWithCardNumber:cardHolder:expiredYear:expiredMonth:secureCode: instead.")));
+ (id)new __attribute__((unavailable("Must use initWithCardNumber:cardHolder:expiredYear:expiredMonth:secureCode: instead.")));


@end