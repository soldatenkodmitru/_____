//
//  StoreManager.h
//  MKSync
//
//  Created by Mugunth Kumar on 17-Oct-09.
//  Copyright 2009 MK Inc. All rights reserved.
//  mugunthkumar.com

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import "MKStoreObserver.h"

@protocol MKStoreKitDelegate <NSObject>
@optional
- (void)product1Purchased;
- (void)product2Purchased;
- (void)product3Purchased;
- (void)product4Purchased;
- (void)product5Purchased;
- (void)failed;
@end

@interface MKStoreManager : NSObject<SKProductsRequestDelegate> {

	NSMutableArray *purchasableObjects;
	MKStoreObserver *storeObserver;	

	id<MKStoreKitDelegate> delegate;
}

@property (nonatomic, retain) id<MKStoreKitDelegate> delegate;
@property (nonatomic, retain) NSMutableArray *purchasableObjects;
@property (nonatomic, retain) MKStoreObserver *storeObserver;

- (void) requestProductData;

- (void) buyFeature1;
- (void) buyFeature2;
- (void) buyFeature3;
- (void) buyFeature4;
- (void) buyFeature5;

// do not call this directly. This is like a private method
- (void) buyFeature:(NSString*) featureId;

-(void)paymentCanceled;

- (void) failedTransaction: (SKPaymentTransaction *)transaction;
-(void) provideContent: (NSString*) productIdentifier;

+ (MKStoreManager*)sharedManager;

+ (BOOL) feature1Purchased;
+ (BOOL) feature2Purchased;
+ (BOOL) feature3Purchased;
+ (BOOL) feature4Purchased;
+ (BOOL) feature5Purchased;

+(void) loadPurchases;
+(void) updatePurchases;

@end
