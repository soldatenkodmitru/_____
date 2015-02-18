#import "NSManagedObjectContext+SRFetchAsync.h"
 
@implementation NSManagedObjectContext (SRFetchAsync)
 
- (void)sr_executeFetchRequest:(NSFetchRequest *)request completion:(void (^)(NSArray *objects, NSError *error))completion {
  NSPersistentStoreCoordinator *coordinator = self.persistentStoreCoordinator;
  
    
 
  NSManagedObjectContext *backgroundContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
  [backgroundContext performBlock:^{
    backgroundContext.persistentStoreCoordinator = coordinator;
    
    // Fetch into shared persistent store in background thread
    NSError *error = nil;
    NSArray *fetchedObjects = [backgroundContext executeFetchRequest:request error:&error];
    
    [self performBlock:^{
      if (fetchedObjects) {
        // Collect object IDs
        NSMutableArray *mutObjectIds = [[NSMutableArray alloc] initWithCapacity:[fetchedObjects count]];
        for (NSManagedObject *obj in fetchedObjects) {
          [mutObjectIds addObject:obj.objectID];
        }
        
        // Fault in objects into current context by object ID as they are available in the shared persistent store
        NSMutableArray *mutObjects = [[NSMutableArray alloc] initWithCapacity:[mutObjectIds count]];
        for (NSManagedObjectID *objectID in mutObjectIds) {
          NSManagedObject *obj = [self objectWithID:objectID];
          [mutObjects addObject:obj];
        }
        
        if (completion) {
          NSArray *objects = [mutObjects copy];
          completion(objects, nil);
        }
      } else {
        if (completion) {
          completion(nil, error);
        }
      }
    }];
  }];
}
 
@end