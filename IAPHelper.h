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

typedef void (^requestProductsResponseBlock)(SKProductsRequest *request, SKProductsResponse *response);
typedef void (^buyProductCompleteResponseBlock)(SKPaymentTransaction *transcation);
typedef void (^buyProductFailResponseBlock)(SKPaymentTransaction *transcation);
typedef void (^resoreProductsCompleteResponseBlock) (SKPaymentQueue *payment);
typedef void (^resoreProductsFailResponseBlock) (SKPaymentQueue *payment, NSError *error);

@interface IAPHelper : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver>

@property (nonatomic,strong,readonly) NSSet *productIdentifiers;
@property (nonatomic,strong,readonly) SKProductsRequest *request;
@property (nonatomic,strong,readonly) NSArray *products;
@property (nonatomic,strong,readonly) NSMutableSet *purchasedProducts;

- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers;
- (void)requestProductsWithCompletion:(requestProductsResponseBlock)completion;
- (void)buyProduct:(SKProduct *)productIdentifier onCompletion:(buyProductCompleteResponseBlock)completion OnFail:(buyProductFailResponseBlock)fail;
- (void)restoreProductsWithCompletion:(resoreProductsCompleteResponseBlock)completion OnFail:(resoreProductsFailResponseBlock)fail;
- (BOOL)isPurchasedProductsIdentifier:(NSString*)productID;

@end
