#import "RowDetails.h"

@interface RowDetails ()

@end

@implementation RowDetails

- (id) initWithSelector:(SEL) selector
                  title:(NSString *) title
             identifier:(NSString *) identifier {
  self = [super init];
  if (self) {
    self.selector = selector;
    self.title = title;
    self.identifier = identifier;
  }
  return self;
}

@end

@interface RowDetailsFactory ()

@property (strong, nonatomic) NSMutableDictionary *dictionary;

- (instancetype) init_private;
- (NSString *) keyForIndexPath:(NSIndexPath *) path;

@end

@implementation RowDetailsFactory

- (instancetype) init {
  @throw [NSException exceptionWithName:@"Cannot call init"
                                 reason:@"This is a singleton class"
                               userInfo:nil];
}

- (instancetype) init_private {
  self = [super init];
  if (self) {
    self.dictionary = [NSMutableDictionary dictionary];
  }
  return self;
}

+ (instancetype) shared {
  static RowDetailsFactory *shared = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    shared = [[RowDetailsFactory alloc] init_private];
  });
  return shared;
}

- (NSString *) keyForIndexPath:(NSIndexPath *) path {
  return [NSString stringWithFormat:@"%@ %@",
          @(path.row), @(path.section)];
}

- (RowDetails *) detailsForRowAtIndexPath:(NSIndexPath *) path {
  NSString *key = [self keyForIndexPath:path];
  return [self.dictionary objectForKey:key];
}

- (void) addDetails:(RowDetails *) details
  forRowAtIndexPath:(NSIndexPath *) path {
  NSString *key = [self keyForIndexPath:path];
  [self.dictionary setObject:details forKey:key];
}

@end
