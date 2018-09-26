
#import "RNCalendarUtil.h"
#import <EventKit/EventKit.h>

@implementation RNCalendarUtil
@synthesize eventStore;

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}
RCT_EXPORT_MODULE()

#pragma mark Event Store Initialize

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initEventStoreWithCalendarCapabilities];
    }
    return self;
}

- (void) initEventStoreWithCalendarCapabilities {
  __block BOOL accessGranted = NO;
  EKEventStore* eventStoreCandidate = [[EKEventStore alloc] init];
  if([eventStoreCandidate respondsToSelector:@selector(requestAccessToEntityType:completion:)]) {
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    [eventStoreCandidate requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
      accessGranted = granted;
      dispatch_semaphore_signal(sema);
    }];
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
  } else { // we're on iOS 5 or older
    accessGranted = YES;
  }

  if (accessGranted) {
    self.eventStore = eventStoreCandidate;
  }
}

#pragma mark Event Store Authorization

- (BOOL)isCalendarAccessGranted
{
    EKAuthorizationStatus status = [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];

    return status == EKAuthorizationStatusAuthorized;
}

#pragma mark RCT Exports

RCT_EXPORT_METHOD(authorizationStatus:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    BOOL isAuthorized;
    EKAuthorizationStatus authStatus = [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];

    switch (authStatus) {
        case EKAuthorizationStatusAuthorized:
            isAuthorized = YES;
            break;
        case EKAuthorizationStatusDenied:
        case EKAuthorizationStatusRestricted:
        default:
            isAuthorized = NO;
            break;
    }

    resolve(@(isAuthorized));
}


RCT_EXPORT_METHOD(authorizeEventStore:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    [self.eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        if (!error) {
            resolve(@(granted));
        } else {
            reject(@"error", @"authorization request error", error);
        }
    }];
}

RCT_EXPORT_METHOD(listCalendars:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    if (![self isCalendarAccessGranted]) {
        reject(@"error", @"unauthorized to access calendar", nil);
        return;
    }

    __weak RNCalendarUtil *weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        RNCalendarUtil *strongSelf = weakSelf;
        NSArray* calendars = [strongSelf.eventStore calendarsForEntityType:EKEntityTypeEvent];

        if (!calendars) {
            reject(@"error", @"error finding calendars", nil);
        } else {
            NSMutableArray *eventCalendars = [[NSMutableArray alloc] init];
            for (EKCalendar *calendar in calendars) {
                [eventCalendars addObject:@{
                                            @"id": calendar.calendarIdentifier,
                                            @"name": calendar.title ? calendar.title : @"",
                                            @"allowsModifications": @(calendar.allowsContentModifications),
                                            @"source": calendar.source && calendar.source.title ? calendar.source.title : @"",
                                            @"allowedAvailabilities": [self calendarSupportedAvailabilitiesFromMask:calendar.supportedEventAvailabilities],
                                            @"color": [self hexStringFromColor:[UIColor colorWithCGColor:calendar.CGColor]]
                                            }];
            }
            resolve(eventCalendars);
        }
    });
}

@end
  