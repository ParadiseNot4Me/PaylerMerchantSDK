//
//  PaylerMerchantApiClient.m
//  PaylerMerchantSDK
//
//  Created by Иван Григорьев on 07.05.15.
//  Copyright (c) 2015 poloniumarts. All rights reserved.
//


#import "PaylerMerchantAPIClient.h"
#import "PLRPayment.h"
#import "PLRCardInfo.h"
#import "PLRError.h"

static NSString *const kRecurrentTemplateKey = @"recurrent_template_id";

@interface PaylerMerchantAPIClient ()

@property (nonatomic, copy) NSString *merchantKey;

@end

@implementation PaylerMerchantAPIClient

+ (instancetype)clientWithMerchantKey:(NSString *)merchantKey {
    return [[self alloc] initWithHost:@"secure" merchantKey:merchantKey];
}

+ (instancetype)testClientWithMerchantKey:(NSString *)merchantKey {
    return [[self alloc] initWithHost:@"sandbox" merchantKey:merchantKey];
}


- (instancetype)initWithHost:(NSString *)host merchantKey:(NSString *)merchantKey {
    if (!merchantKey.length) [NSException raise:NSInvalidArgumentException format:@"Required parameters omitted"];
    
    self = [super initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://%@.payler.com/mapi", host]]];
    if (self) {
        _merchantKey = [merchantKey copy];
    }
    return self;
}

- (NSMutableURLRequest *)requestWithPath:(NSString *)path parameters:(NSDictionary *)parameters {
    return [self.requestSerializer requestWithMethod:@"POST"
                                           URLString:[[NSURL URLWithString:path relativeToURL:self.baseURL] absoluteString]
                                          parameters:parameters
                                               error:nil];
}

#pragma mark - Error handling

+ (NSError *)errorFromRequestOperation:(AFHTTPRequestOperation *)operation {
    NSParameterAssert(operation);
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    PaylerErrorCode errorCode = [[operation.responseObject valueForKeyPath:@"error.code"] integerValue];
    userInfo[NSLocalizedDescriptionKey] = PaylerErrorDescriptionFromCode(errorCode);
    if (operation.error) userInfo[NSUnderlyingErrorKey] = operation.error;
    return [NSError errorWithDomain:PaylerErrorDomain code:errorCode userInfo:userInfo];
}

+ (NSError *)invalidParametersError {
    return [NSError errorWithDomain:PaylerErrorDomain
                               code:PaylerErrorInvalidParams
                           userInfo:@{NSLocalizedDescriptionKey: PaylerErrorDescriptionFromCode(PaylerErrorInvalidParams)}];
}

@end

@implementation PaylerMerchantAPIClient (Payments)

- (void)payPayment:(PLRPayment *)payment withCardInfo:(PLRCardInfo *)cardInfo completion:(PLRCompletionBlock)completion{
    [self payPayment:payment withCardInfo:cardInfo createRecurrentTemplate:NO completion:completion];
}

- (void)payPayment:(PLRPayment *)payment withCardInfo:(PLRCardInfo *)cardInfo createRecurrentTemplate:(BOOL)recurrent completion:(PLRCompletionBlock)completion {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithDictionary:[self parametersWithPayment:payment cardInfo:cardInfo includeAmount:YES]];
    if (recurrent) parameters[@"recurrent"] = @"true";
    [self enqueuePaymentRequest:[self requestWithPath:@"Pay" parameters:parameters] completion:completion];
}

- (void)pay3DSPayment:(PLRPayment *)payment completion:(PLRCompletionBlock)completion {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithDictionary:@{@"PaRes": payment.pares,
                                                                                        @"MD": payment.md
                                                                                        }];
    [self enqueuePaymentRequest:[self requestWithPath:@"Pay3DS" parameters:parameters] completion:completion];
};

- (void)blockPayment:(PLRPayment *)payment withCardInfo:(PLRCardInfo *)cardInfo completion:(PLRCompletionBlock)completion {
    [self blockPayment:payment withCardInfo:cardInfo createRecurrentTemplate:NO completion:completion];
}

- (void)blockPayment:(PLRPayment *)payment withCardInfo:(PLRCardInfo *)cardInfo createRecurrentTemplate:(BOOL)recurrent completion:(PLRCompletionBlock)completion {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithDictionary:[self parametersWithPayment:payment cardInfo:cardInfo includeAmount:YES]];
    if (recurrent) parameters[@"recurrent"] = @"true";
    [self enqueuePaymentRequest:[self requestWithPath:@"Block" parameters:parameters] completion:completion];
}

- (void)block3DSPayment:(PLRPayment *)payment completion:(PLRCompletionBlock)completion {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithDictionary:@{@"PaRes": payment.pares,
                                                                                        @"MD": payment.md
                                                                                        }];
    [self enqueuePaymentRequest:[self requestWithPath:@"Block3DS" parameters:parameters] completion:completion];
};

- (void)chargePayment:(PLRPayment *)payment completion:(PLRCompletionBlock)completion {
    [self enqueuePaymentRequest:[self paymentRequestWithPath:@"Charge" payment:payment] completion:completion];
}

- (void)retrievePayment:(PLRPayment *)payment completion:(PLRCompletionBlock)completion {
    [self enqueuePaymentRequest:[self paymentRequestWithPath:@"Retrieve" payment:payment] completion:completion];
}

- (void)refundPayment:(PLRPayment *)payment completion:(PLRCompletionBlock)completion {
    [self enqueuePaymentRequest:[self paymentRequestWithPath:@"Refund" payment:payment] completion:completion];
}

- (void)fetchStatusForPaymentWithId:(NSString *)paymentId completion:(PLRCompletionBlock)completion {
    NSParameterAssert(paymentId);
    
    PLRPayment *payment = [[PLRPayment alloc] initWithId:paymentId amount:0];
    [self enqueuePaymentRequest:[self requestWithPath:@"GetStatus" parameters:[self parametersWithPayment:payment  includeAmount:NO]] completion:completion];
}

#pragma mark - Private methods

- (void)enqueuePaymentRequest:(NSURLRequest *)request
                   completion:(PLRCompletionBlock)completion {
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (completion) {
            if ([self isPaymentInfoValid:responseObject]) {
                completion([self.class paymentFromJSON:responseObject], nil);
            } else {
                completion(nil, [self.class invalidParametersError]);
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (completion) {
            completion(nil, [self.class errorFromRequestOperation:operation]);
        }
    }];
    
    [self.operationQueue addOperation:operation];
}

- (NSMutableURLRequest *)paymentRequestWithPath:(NSString *)path payment:(PLRPayment *)payment {
    NSParameterAssert(payment);
    
    return [self requestWithPath:path parameters:[self parametersWithPayment:payment  includeAmount:YES]];
}

- (NSDictionary *)parametersWithPayment:(PLRPayment *)payment includeAmount:(BOOL)includeAmount {
    return [self parametersWithPayment:payment cardInfo:nil includeAmount:includeAmount];
}

- (NSDictionary *)parametersWithPayment:(PLRPayment *)payment cardInfo:(PLRCardInfo*)cardInfo includeAmount:(BOOL)includeAmount {
    NSParameterAssert(payment);
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithDictionary:@{@"key": self.merchantKey, @"order_id": payment.paymentId}];
    
    if (cardInfo) {
        [parameters addEntriesFromDictionary:[cardInfo dictionaryRepresentation]];
    }
    
    if (includeAmount) {
        parameters[@"amount"] = @(payment.amount);
    }
    
    return [parameters copy];
}

- (BOOL)isPaymentInfoValid:(NSDictionary *)paymentInfo {
    NSAssert([paymentInfo isKindOfClass:[NSDictionary class]], @"Invalid argument type");
    
    return [paymentInfo[@"order_id"] length] && (paymentInfo[@"amount"] || paymentInfo[@"new_amount"]);
}

+ (PLRPayment *)paymentFromJSON:(NSDictionary *)JSONPayment {
    NSInteger amount = [(JSONPayment[@"amount"] ?: JSONPayment[@"new_amount"]) integerValue];
    PLRPayment *payment = [[PLRPayment alloc] initWithId:JSONPayment[@"order_id"] amount:amount status:JSONPayment[@"status"]];
    if (JSONPayment[kRecurrentTemplateKey]) {
        payment.recurrentTemplateId = JSONPayment[kRecurrentTemplateKey];
    }
    
    payment.authType = JSONPayment[@"auth_type"];
    
    if ([JSONPayment[@"auth_type"] intValue]) {
        payment.acs_url = JSONPayment[@"acs_url"];
        payment.md = JSONPayment[@"md"];
        payment.pareq = JSONPayment[@"pareq"];
    }
    
    return payment;
}

@end

@implementation PaylerMerchantAPIClient (RecurrentPayments)

- (void)repeatPayment:(PLRPayment *)payment completion:(PLRCompletionBlock)completion {
    NSParameterAssert(payment);
    NSParameterAssert(payment.recurrentTemplateId);
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithDictionary:[self parametersWithPayment:payment includeAmount:YES]];
    parameters[kRecurrentTemplateKey] = payment.recurrentTemplateId;
    [self enqueuePaymentRequest:[self requestWithPath:@"RepeatPay" parameters:[parameters copy]] completion:completion];
}

- (void)fetchTemplateWithId:(NSString *)recurrentTemplateId completion:(PLRPaymentTemplateBlock)completion {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithDictionary:@{@"key": self.merchantKey}];
    if (recurrentTemplateId) {
        parameters[kRecurrentTemplateKey] = recurrentTemplateId;
    }
    
    [self enqueuePaymentTemplateRequest:[self requestWithPath:@"GetTemplate" parameters:[parameters copy]] completion:completion];
}

- (void)activateTemplateWithId:(NSString *)recurrentTemplateId active:(BOOL)active completion:(PLRPaymentTemplateBlock)completion {
    NSParameterAssert(recurrentTemplateId);
    
    NSDictionary *parameters = @{@"key": self.merchantKey, kRecurrentTemplateKey: recurrentTemplateId, @"active": active ? @"true": @"false"};
    [self enqueuePaymentTemplateRequest:[self requestWithPath:@"ActivateTemplate" parameters:parameters] completion:completion];
}

- (void)enqueuePaymentTemplateRequest:(NSURLRequest *)request
                           completion:(PLRPaymentTemplateBlock)completion {
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (completion) {
            NSArray *responseArray = responseObject[@"templates"];
            if (responseArray) {
                NSMutableArray *templates = [[NSMutableArray alloc] init];
                for (NSDictionary *templateDict in responseArray) {
                    PLRPaymentTemplate *template = [self.class paymentTemplateFromJSON:templateDict];
                    if (template) {
                        [templates addObject:template];
                    }
                }
                completion([templates copy], nil);
                return;
            } else if ([responseObject isKindOfClass:[NSDictionary class]]) {
                PLRPaymentTemplate *template = [self.class paymentTemplateFromJSON:responseObject];
                if (template) {
                    completion(template, nil);
                }
                return;
            }
            
            completion(nil, [self.class invalidParametersError]);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (completion) {
            completion(nil, [self.class errorFromRequestOperation:operation]);
        }
    }];
    
    [self.operationQueue addOperation:operation];
}

+ (PLRPaymentTemplate *)paymentTemplateFromJSON:(NSDictionary *)JSONTemplate {
    if (!JSONTemplate[kRecurrentTemplateKey]) {
        return nil;
    }
    
    PLRPaymentTemplate *template = [[PLRPaymentTemplate alloc] initWithTemplateId:JSONTemplate[kRecurrentTemplateKey]];
    template.cardHolder = JSONTemplate[@"card_holder"];
    template.cardNumber = JSONTemplate[@"card_number"];
    template.expiry = JSONTemplate[@"expiry"];
    template.active = [JSONTemplate[@"active"] boolValue];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    template.creationDate = [dateFormatter dateFromString:JSONTemplate[@"created"]];
    
    return template;
}

@end





