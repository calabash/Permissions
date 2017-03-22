#import <Foundation/Foundation.h>

@interface RowDetails : NSObject

@property (assign, nonatomic) SEL rowTouchedSelector;
@property (assign, nonatomic) SEL privacyStatusSelector;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *identifier;

- (id)initWithRowTouchedSelector:(SEL)rowTouchedSelector
           privacyStatusSelector:(SEL)privacyStatusSelector
                           title:(NSString *)title
                      identifier:(NSString *)identifier;

@end

@interface RowDetailsFactory : NSObject

+ (instancetype) shared;

- (RowDetails *) detailsForRowAtIndexPath:(NSIndexPath *) path;
- (RowDetails *) detailsForIdentifier:(NSString *)identifier;
- (void) addDetails:(RowDetails *) details
  forRowAtIndexPath:(NSIndexPath *) path;

@end
