#import <Foundation/Foundation.h>

@interface RowDetails : NSObject

@property (assign, nonatomic) SEL selector;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *identifier;

- (id) initWithSelector:(SEL) selector
                  title:(NSString *) title
             identifier:(NSString *) identifier;

@end

@interface RowDetailsFactory : NSObject

+ (instancetype) shared;

- (RowDetails *) detailsForRowAtIndexPath:(NSIndexPath *) path;
- (void) addDetails:(RowDetails *) details
  forRowAtIndexPath:(NSIndexPath *) path;

@end
