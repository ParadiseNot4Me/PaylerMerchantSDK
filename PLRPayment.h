//
//  PLRPayment.h
//  PaylerMerchantSDK
//
//  Created by Иван Григорьев on 07.05.15.
//  Copyright (c) 2015 poloniumarts. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, PLRPayType) {
    PLRPayTypeOneStep, // одностадийный платеж
    PLRPayTypeTwoStep  // двухстадийный платеж
};

typedef NS_ENUM(NSUInteger, PLRPaymentStatus) {
    PLRPaymentStatusUnknown,
    PLRPaymentStatusCreated, // Платеж зарегистрирован в шлюзе, но его обработка в процессинге не начата.
    PLRPaymentStatusPreAuthorized3DS, // Пользователь начал аутентификацию по протоколу 3-D Secure, на этом операции по платежу завершились.
    PLRPaymentStatusPreAuthorizedAF, // Пользователь начал аутентификацию с помощью антифрод-сервиса, на этом операции по платежу завершились.
    PLRPaymentStatusAuthorized, // Средства заблокированы, но не списаны (двухстадийный платеж).
    PLRPaymentStatusRetrieved, // Средства на карте частично разблокированы
    PLRPaymentStatusReversed, // Средства на карте были заблокированы и разблокированы (двухстадийный платеж).
    PLRPaymentStatusCharged, // Денежные средства списаны с карты Пользователя, платёж завершен успешно.
    PLRPaymentStatusRefunded, // Успешно произведен полный или частичный возврат денежных средств на карту Пользователя
    PLRPaymentStatusRejected, // Операция по платежу отклонена
    PLRPaymentStatusError // Последняя операция по платежу завершена с ошибкой
};

/**
 *  В классе инкапсулирована информация о платеже.
 */
@interface PLRPayment : NSObject

/**
 *  Идентификатор оплачиваемого заказа в системе Продавца. Должен быть уникальным для каждого платежа(сессии). Допускаются только печатные ASCII-символы, максимальное количество 100.
 */
@property (nonatomic, readonly, copy) NSString *paymentId;

/**
 *  Сумма платежа в копейках.
 */
@property (nonatomic, readonly, assign) NSUInteger amount;

/**
 *  Статус платежа.
 */
@property (nonatomic, readonly, assign) PLRPaymentStatus status;

/**
 *  Если не nil, то это шаблон рекуррентных платежей, по которому был выполнен данный платеж.
 */
@property (nonatomic, strong) NSString *recurrentTemplateId;

@property (nonatomic, assign) BOOL authType;

@property (nonatomic, copy) NSString *acs_url;

@property (nonatomic, copy) NSString *md;

@property (nonatomic, copy) NSString *pareq;

@property (nonatomic, copy) NSString *pares;


/**
 *  Словарь, содержащий параметры, использумые в запросах к API.
 */
- (NSDictionary *)dictionaryRepresentation;

//  Следующие методы инициализируют и возвращают объект класса PLRPayment. Параметр paymentId не должен быть nil.
- (instancetype)initWithId:(NSString *)paymentId amount:(NSUInteger)amount;
- (instancetype)initWithId:(NSString *)paymentId amount:(NSUInteger)amount status:(NSString *)status NS_DESIGNATED_INITIALIZER;

- (id)init __attribute__((unavailable("Must use initWithId:amount: instead.")));
+ (id)new __attribute__((unavailable("Must use initWithId:amount: instead.")));

@end


