#if __has_include(<React/RCTBridgeModule.h>)
  #import <React/RCTBridgeModule.h>
#else
  #import "RCTBridgeModule.h"
#endif
#import <React/RCTEventDispatcher.h>

@interface RNCalendarUtil : NSObject <RCTBridgeModule>
@end
