#import <Foundation/Foundation.h>
#if __has_include("RCTBridgeModule.h")
#import "RCTBridgeModule.h"
#else
#import <React/RCTBridgeModule.h>
#endif
#import <EventKit/EventKit.h>

@interface RNCalendarUtil : NSObject <RCTBridgeModule>

@property (nonatomic, retain) EKEventStore* eventStore;

@end
