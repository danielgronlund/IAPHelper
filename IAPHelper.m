//
//  IAPHelper.m
//
//  Original Created by Ray Wenderlich on 2/28/11.
//  Created by saturngod on 7/9/12.
//  Copyright 2011 Ray Wenderlich. All rights reserved.
//

#import "IAPHelper.h"

@interface IAPHelper()

@property (nonatomic,strong) NSSet *productIdentifiers;
@property (nonatomic,strong) SKProductsRequest *request;
@property (nonatomic,strong) NSArray *products;
@property (nonatomic,strong) NSMutableSet *purchasedProducts;

@property (nonatomic,copy) IAPRequestProductsResponseBlock requestProductsBlock;
@property (nonatomic,copy) IAPBuyProductCompletionBlock buyProductCompleteBlock;
@property (nonatomic,copy) IAPRestoreProductsCompletionBlock restoreCompletedBlock;

@end

@implementation IAPHelper

- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers {
    if ((self = [super init])) {
        _productIdentifiers = productIdentifiers;

        // Check for previously purchased products
        NSMutableSet *purchasedProducts = [NSMutableSet set];
        for (NSString *productIdentifier in _productIdentifiers) {
            BOOL productPurchased = [[NSUserDefaults standardUserDefaults] boolForKey:productIdentifier];
            if (productPurchased) {
                [purchasedProducts addObject:productIdentifier];
                NSLog(@"Previously purchased: %@", productIdentifier);
            }
            NSLog(@"Not purchased: %@", productIdentifier);
        }
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        self.purchasedProducts = purchasedProducts;
    }
    return self;
}

- (BOOL)isPurchasedProductsIdentifier:(NSString *)productID {
    return [[NSUserDefaults standardUserDefaults] boolForKey:productID];
}

- (void)requestProductsWithCompletion:(IAPRequestProductsResponseBlock)completion {
    self.request = [[SKProductsRequest alloc] initWithProductIdentifiers:_productIdentifiers];
    _request.delegate = self;
    self.requestProductsBlock = completion;
    [_request start];
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    NSLog(@"Received products results...");
    self.products = response.products;
    self.request = nil;

    if (_requestProductsBlock) {
        _requestProductsBlock(request,response);
    }
}

- (void)recordTransaction:(SKPaymentTransaction *)transaction {
    // TODO: Record the transaction on the server side...
}

- (void)provideContent:(NSString *)productIdentifier {
    NSLog(@"Toggling flag for: %@", productIdentifier);
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:productIdentifier];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [_purchasedProducts addObject:productIdentifier];
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    NSLog(@"completeTransaction...");

    [self recordTransaction:transaction];
    [self provideContent:transaction.payment.productIdentifier];

    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];

    if(_buyProductCompleteBlock) {
        _buyProductCompleteBlock(transaction, nil);
    }
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
    NSLog(@"restoreTransaction...");

    [self recordTransaction:transaction];
    [self provideContent:transaction.originalTransaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];

    if (_buyProductCompleteBlock) {
        _buyProductCompleteBlock(transaction, nil);
    }
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction {
    if (transaction.error.code != SKErrorPaymentCancelled) {
        NSLog(@"Transaction error: %@ %d", transaction.error.localizedDescription, transaction.error.code);
    }

    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    if(_buyProductCompleteBlock) {
        _buyProductCompleteBlock(transaction, transaction.error);
    }
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
            default:
                break;
        }
    }
}

- (void)buyProduct:(SKProduct *)productIdentifier completion:(IAPBuyProductCompletionBlock)completion {
    _buyProductCompleteBlock = completion;
    self.restoreCompletedBlock = nil;
    SKPayment *payment = [SKPayment paymentWithProduct:productIdentifier];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (void)restoreProductsWithCompletion:(IAPRestoreProductsCompletionBlock)completion {
    self.buyProductCompleteBlock = nil;
    self.restoreCompletedBlock = completion;
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error {
    NSLog(@"Transaction error: %@ %d", error.localizedDescription,error.code);
    if (_restoreCompletedBlock) {
        _restoreCompletedBlock(queue, error);
    }
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue {
    if (_restoreCompletedBlock) {
        _restoreCompletedBlock(queue,nil);
    }
}

@end
