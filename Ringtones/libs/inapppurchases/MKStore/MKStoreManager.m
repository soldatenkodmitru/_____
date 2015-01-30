//
//  MKStoreManager.m
//
//  Created by Mugunth Kumar on 17-Oct-09.
//  Copyright 2009 Mugunth Kumar. All rights reserved.
//  mugunthkumar.com
//

#import "MKStoreManager.h"


@implementation MKStoreManager

@synthesize purchasableObjects;
@synthesize storeObserver;
@synthesize delegate;

// all your features should be managed one and only by StoreManager
//static NSString *feature1Id = @"com.wordpress.indiedevelop.InAppPurchasesExample.f1";
/*static NSString *feature2Id = @"com.wordpress.indiedevelop.InAppPurchasesExample.f2";
static NSString *feature3Id = @"com.wordpress.indiedevelop.InAppPurchasesExample.f1";
static NSString *feature4Id = @"com.wordpress.indiedevelop.InAppPurchasesExample.f1";
static NSString *feature5Id = @"com.wordpress.indiedevelop.InAppPurchasesExample.f1";*/

BOOL feature1Purchased;
BOOL feature2Purchased;
BOOL feature3Purchased;
BOOL feature4Purchased;
BOOL feature5Purchased;

static MKStoreManager* _sharedStoreManager; // self

- (void)dealloc {
	
	[_sharedStoreManager release];
	[storeObserver release];
	[super dealloc];
}

+ (BOOL) feature1Purchased {
	
	return feature1Purchased;
}

+ (BOOL) feature2Purchased {
	
	return feature2Purchased;
}
+ (BOOL) feature3Purchased {
	
	return feature3Purchased;
}
+ (BOOL) feature4Purchased {
	
	return feature4Purchased;
}
+ (BOOL) feature5Purchased {
	
	return feature5Purchased;
}

+ (MKStoreManager*)sharedManager
{
	@synchronized(self) {
		
        if (_sharedStoreManager == nil) {
			
            [[self alloc] init]; // assignment not done here
			_sharedStoreManager.purchasableObjects = [[NSMutableArray alloc] init];			
			[_sharedStoreManager requestProductData];
			
			[MKStoreManager loadPurchases];
			_sharedStoreManager.storeObserver = [[MKStoreObserver alloc] init];
			[[SKPaymentQueue defaultQueue] addTransactionObserver:_sharedStoreManager.storeObserver];
        }
    }
    return _sharedStoreManager;
}


#pragma mark Singleton Methods

+ (id)allocWithZone:(NSZone *)zone

{	
    @synchronized(self) {
		
        if (_sharedStoreManager == nil) {
			
            _sharedStoreManager = [super allocWithZone:zone];			
            return _sharedStoreManager;  // assignment and return on first allocation
        }
    }
	
    return nil; //on subsequent allocation attempts return nil	
}


- (id)copyWithZone:(NSZone *)zone
{
    return self;	
}

- (id)retain
{	
    return self;	
}

- (unsigned)retainCount
{
    return UINT_MAX;  //denotes an object that cannot be released
}

- (void)release
{
    //do nothing
}

- (id)autorelease
{
    return self;	
}


- (void) requestProductData
{
	SKProductsRequest *request= [[SKProductsRequest alloc] initWithProductIdentifiers: 
								 [NSSet setWithObjects: feature1Id, feature2Id, feature3Id, nil]]; // add any other product here
	request.delegate = self;
	[request start];
}


- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
	[purchasableObjects addObjectsFromArray:response.products];
	// populate your UI Controls here
	for(int i=0;i<[purchasableObjects count];i++)
	{
		
		SKProduct *product = [purchasableObjects objectAtIndex:i];
		NSLog(@"Feature: %@, Cost: %f, ID: %@",[product localizedTitle],
			  [[product price] doubleValue], [product productIdentifier]);
	}
	
	[request autorelease];
}

- (void) buyFeature1
{
	[self buyFeature:feature1Id];
}
- (void) buyFeature2
{
	[self buyFeature:feature2Id];
}
- (void) buyFeature3
{
	[self buyFeature:feature3Id];
}


- (void) buyFeature:(NSString*) featureId
{
	if ([SKPaymentQueue canMakePayments])
	{
		SKPayment *payment = [SKPayment paymentWithProductIdentifier:featureId];
		[[SKPaymentQueue defaultQueue] addPayment:payment];
	}
	else
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"MyApp" message:@"You are not authorized to purchase from AppStore"
													   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alert show];
		[alert release];
	}
}


-(void)paymentCanceled
{
	if([delegate respondsToSelector:@selector(failed)])
		[delegate failed];
}

- (void) failedTransaction: (SKPaymentTransaction *)transaction
{
	if([delegate respondsToSelector:@selector(failed)])
		[delegate failed];
	
	NSString *messageToBeShown = [NSString stringWithFormat:@"Reason: %@, You can try: %@", [transaction.error localizedFailureReason], [transaction.error localizedRecoverySuggestion]];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unable to complete your purchase" message:messageToBeShown
												   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
	[alert show];
	[alert release];
}

-(void) provideContent: (NSString*) productIdentifier
{
	if([productIdentifier isEqualToString:feature1Id])
	{
		feature1Purchased = YES;
		if([delegate respondsToSelector:@selector(product1Purchased)])
			[delegate product1Purchased];
	} else if([productIdentifier isEqualToString:feature2Id])
	{
		feature2Purchased = YES;
		if([delegate respondsToSelector:@selector(product2Purchased)])
			[delegate product2Purchased];
	} else if([productIdentifier isEqualToString:feature3Id])
	{
		feature3Purchased = YES;
		if([delegate respondsToSelector:@selector(product3Purchased)])
			[delegate product3Purchased];
	}
	
	[MKStoreManager updatePurchases];
}


+(void) loadPurchases 
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];	
	feature1Purchased = [userDefaults boolForKey:feature1Id];
	feature2Purchased = [userDefaults boolForKey:feature2Id];
    feature3Purchased = [userDefaults boolForKey:feature3Id];

}


+(void) updatePurchases
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setBool:feature1Purchased forKey:feature1Id];
	[userDefaults setBool:feature2Purchased forKey:feature2Id];
    [userDefaults setBool:feature3Purchased forKey:feature3Id];

}
@end
