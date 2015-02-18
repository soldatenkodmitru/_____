#import <CoreData/CoreData.h>
 
@interface NSManagedObjectContext (SRFetchAsync)
 
- (void)sr_executeFetchRequest:(NSFetchRequest *)request completion:(void (^)(NSArray *objects, NSError *error))completion;
 
@end