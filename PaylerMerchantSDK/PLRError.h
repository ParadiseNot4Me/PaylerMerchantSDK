//
//  PLRError.h
//  PaylerMerchantSDK
//
//  Created by Иван Григорьев on 07.05.15.
//  Copyright (c) 2015 poloniumarts. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const PaylerErrorDomain;

typedef NS_ENUM (NSUInteger, PaylerErrorCode) {
    PaylerErrorNone,
    PaylerErrorInvalidAmount,
    PaylerErrorBalanceExceeded,
    PaylerErrorDuplicateOrderId,
    PaylerErrorIssuerDeclinedOperation,
    PaylerErrorLimitExceded,
    PaylerErrorAFDeclined,
    PaylerErrorInvalidOrderState,
    PaylerErrorMerchantDeclined,
    PaylerErrorOrderNotFound,
    PaylerErrorProcessingError,
    PaylerErrorPartialRetrieveNotAllowed,
    PaylerErrorRefundNotAllowed,
    PaylerErrorGateDeclined,
    PaylerErrorInvalidCardInfo,
    PaylerErrorInvalidCardPan,
    PaylerErrorInvalidCardholder,
    PaylerErrorInvalidPayInfo,
    PaylerErrorAPINotAllowed,
    PaylerErrorAccessDenied,
    PaylerErrorInvalidParams,
    PaylerErrorSessionTimeout,
    PaylerErrorMerchantNotFound,
    PaylerErrorUnexpectedError
};

extern NSString* PaylerErrorDescriptionFromCode(PaylerErrorCode errorCode);


