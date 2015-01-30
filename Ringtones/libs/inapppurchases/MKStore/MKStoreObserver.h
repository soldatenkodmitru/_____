//
//  MKStoreObserver.m
//
//  Created by Mugunth Kumar on 17-Oct-09.
//  Copyright 2009 Mugunth Kumar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import "InAppPurches.h"

@protocol MKStoreObserverDelegate;

@interface MKStoreObserver : NSObject<SKPaymentTransactionObserver> {

	
}
@property (nonatomic,strong) id<MKStoreObserverDelegate> delegate;

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions;


@end

@protocol MKStoreObserverDelegate <NSObject>

@optional
- (void) failedTransaction: (SKPaymentTransaction *)transaction;
- (void) completeTransaction: (SKPaymentTransaction *)transaction;
- (void) restoreTransaction: (SKPaymentTransaction *)transaction;

@end