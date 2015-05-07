//
//  PaylerMerchantApiClient.h
//  PaylerMerchantSDK
//
//  Created by Иван Григорьев on 07.05.15.
//  Copyright (c) 2015 poloniumarts. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFHTTPRequestOperationManager.h>

@class PLRPayment, PLRCardInfo;

typedef void (^PLRCompletionBlock)(PLRPayment *payment, NSError *error);
typedef void (^PLRPaymentTemplateBlock)(id object, NSError *error);

@interface PaylerMerchantAPIClient : AFHTTPRequestOperationManager

/**
 *  Инициализирует и возвращает объект класса PaylerMerchantAPIClient с соответствующими параметрами боевого доступа.
 *  @param merchantKey      Идентификатор Продавца. Не должен быть nil.
 */
+ (instancetype)clientWithMerchantKey:(NSString *)merchantKey;

/**
 *  Инициализирует и возвращает объект класса PaylerMerchantAPIClient с соответствующими параметрами тестового доступа.
 *  @param merchantKey      Идентификатор Продавца для тестового доступа. Не должен быть nil.
 */
+ (instancetype)testClientWithMerchantKey:(NSString *)merchantKey;

- (id)init __attribute__((unavailable("Must use clientWithMerchantKey: or testClientWithMerchantKey: instead.")));
+ (id)new __attribute__((unavailable("Must use clientWithMerchantKey: or testClientWithMerchantKey: instead.")));

@end

/**
 *   Если запрос выполнился успешно, то параметр payment в блоке содержит информацию о платеже, а error равен nil. Если запрос выполнился неудачно, то payment равен nil, а error содержит информацию об ошибке.
 */
@interface PaylerMerchantAPIClient (Payments)



- (void)payPayment:(PLRPayment *)payment withCardInfo:(PLRCardInfo *)cardInfo completion:(PLRCompletionBlock)completion;
- (void)payPayment:(PLRPayment *)payment withCardInfo:(PLRCardInfo *)cardInfo createRecurrentTemplate:(BOOL)recurrent completion:(PLRCompletionBlock)completion;
- (void)pay3DSPayment:(PLRPayment *)payment completion:(PLRCompletionBlock)completion;

- (void)blockPayment:(PLRPayment *)payment withCardInfo:(PLRCardInfo *)cardInfo completion:(PLRCompletionBlock)completion;
- (void)blockPayment:(PLRPayment *)payment withCardInfo:(PLRCardInfo *)cardInfo createRecurrentTemplate:(BOOL)recurrent completion:(PLRCompletionBlock)completion;
- (void)block3DSPayment:(PLRPayment *)payment completion:(PLRCompletionBlock)completion;

/**
 *  Запрос списания средств, заблокированных на карте Пользователя в рамках двухстадийного платежа. Статус платежа должен быть Authorized.
 *
 *  @param payment    Объект класса PLRPayment. Не должен быть nil.
 *  @param completion Блок выполняется после завершения запроса. В поле amount параметра payment приходит списанная сумма в копейках.
 */
- (void)chargePayment:(PLRPayment *)payment completion:(PLRCompletionBlock)completion;

/**
 *  Запрос полной или частичной отмены блокировки средств, заблокированных на карте Пользователя в рамках двухстадийного платежа. Статус платежа должен быть Authorized.
 *
 *  @param payment    Объект класса PLRPayment. Не должен быть nil.
 *  @param completion Блок выполняется после завершения запроса. В поле amount параметра payment приходит новая величина суммы платежа в копейках.
 */
- (void)retrievePayment:(PLRPayment *)payment completion:(PLRCompletionBlock)completion;

/**
 *  Запрос полного или частичного возврата средств на карту Пользователя, списанных в ходе одностадийного или двухстадийного платежей. Статус платежа должен быть Charged.
 *
 *  @param payment    Объект класса PLRPayment. Не должен быть nil.
 *  @param completion Блок выполняется после завершения запроса. В поле amount параметра payment приходит остаток списанной суммы в копейках.
 */
- (void)refundPayment:(PLRPayment *)payment completion:(PLRCompletionBlock)completion;

/**
 *  Запрос получения статуса платежа.
 *
 *  @param paymentId  Идентификатор заказа в системе Продавца.
 *  @param completion Блок выполняется после завершения запроса. В поле status параметра payment приходит текущий статус платежа.
 */
- (void)fetchStatusForPaymentWithId:(NSString *)paymentId completion:(PLRCompletionBlock)completion;



@end
