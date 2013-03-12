//
//  IAPHelper.h
//
//  Original Created by Ray Wenderlich on 2/28/11.
//  Created by saturngod on 7/9/12.
//  Copyright 2011 Ray Wenderlich. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StoreKit/StoreKit.h"

#define kProductsLoadedNotification         @"ProductsLoaded"
#define kProductPurchasedNotification       @"ProductPurchased"
#define kProductPurchaseFailedNotification  @"ProductPurchaseFailed"

typedef void (^IAPRequestProductsResponseBlock)(SKProductsRequest *request, SKProductsResponse *response);

// if purchase is successful, error will be nil, and non-nil if an error occurs
typedef void (^IAPBuyProductCompletionBlock)(SKPaymentTransaction *transaction, NSError *error);

// if restore is successful, error will be nil, and non-nil if an error occurs
typedef void (^IAPRestoreProductsCompletionBlock)(SKPaymentQueue *payment, NSError *error);

@interface IAPHelper : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver>

@property (nonatomic,strong,readonly) NSSet *productIdentifiers;
@property (nonatomic,strong,readonly) SKProductsRequest *request;
@property (nonatomic,strong,readonly) NSArray *products;
@property (nonatomic,strong,readonly) NSMutableSet *purchasedProducts;

- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers;

- (void)requestProductsWithCompletion:(IAPRequestProductsResponseBlock)completion;

- (void)buyProduct:(SKProduct *)productIdentifier completion:(IAPBuyProductCompletionBlock)completion;

- (void)restoreProductsWithCompletion:(IAPRestoreProductsCompletionBlock)completion;

- (BOOL)isPurchasedProductsIdentifier:(NSString *)productID;

@end
