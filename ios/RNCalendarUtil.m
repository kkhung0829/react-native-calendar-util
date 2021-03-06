
#import "RNCalendarUtil.h"
#import <React/RCTConvert.h>
#import <React/RCTUtils.h>
#import <EventKit/EventKit.h>

@interface RNCalendarUtil ()
@property (nonatomic, retain) EKEventStore *eventStore;
@end

@implementation RNCalendarUtil

- (NSString *)hexStringFromColor:(UIColor *)color {
    const CGFloat *components = CGColorGetComponents(color.CGColor);
    
    CGFloat r = components[0];
    CGFloat g = components[1];
    CGFloat b = components[2];
    
    return [NSString stringWithFormat:@"#%02lX%02lX%02lX",
            lroundf(r * 255),
            lroundf(g * 255),
            lroundf(b * 255)];
}

@synthesize bridge = _bridge;

RCT_EXPORT_MODULE()

#pragma mark Event Store Initialize

+ (BOOL)requiresMainQueueSetup
{
    return NO;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        // [self initEventStoreWithCalendarCapabilities];
        _eventStore = [[EKEventStore alloc] init];
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

#pragma mark Helper Functions

- (EKCalendar*) findEKCalendar: (NSString *)calendarName {
  NSArray<EKCalendar *> *calendars = [self.eventStore calendarsForEntityType:EKEntityTypeEvent];
  if (calendars != nil && calendars.count > 0) {
    for (EKCalendar *thisCalendar in calendars) {
      NSLog(@"Calendar: %@", thisCalendar.title);
      if ([thisCalendar.title isEqualToString:calendarName]) {
        return thisCalendar;
      }
      if ([thisCalendar.calendarIdentifier isEqualToString:calendarName]) {
        return thisCalendar;
      }
    }
  }
  NSLog(@"No match found for calendar with name: %@", calendarName);
  return nil;
}

// Assumes input like "#00FF00" (#RRGGBB)
- (UIColor*) colorFromHexString:(NSString*) hexString {
  unsigned rgbValue = 0;
  NSScanner *scanner = [NSScanner scannerWithString:hexString];
  [scanner setScanLocation:1]; // bypass '#' character
  [scanner scanHexInt:&rgbValue];
  return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16) / 255.0 green:((rgbValue & 0xFF00) >> 8) / 255.0 blue:(rgbValue & 0xFF) / 255.0 alpha:1.0];
}

- (EKSource*) findEKSource {
  // if iCloud is on, it hides the local calendars, so check for iCloud first
  for (EKSource *source in self.eventStore.sources) {
    if (source.sourceType == EKSourceTypeCalDAV && [source.title isEqualToString:@"iCloud"]) {
      return source;
    }
  }

  // ok, not found.. so it's a local calendar
  for (EKSource *source in self.eventStore.sources) {
    if (source.sourceType == EKSourceTypeLocal) {
      return source;
    }
  }
  return nil;
}

- (EKRecurrenceFrequency) toEKRecurrenceFrequency:(NSString*) recurrence {
    if ([recurrence isEqualToString:@"daily"]) {
        return EKRecurrenceFrequencyDaily;
    } else if ([recurrence isEqualToString:@"weekly"]) {
        return EKRecurrenceFrequencyWeekly;
    } else if ([recurrence isEqualToString:@"monthly"]) {
        return EKRecurrenceFrequencyMonthly;
    } else if ([recurrence isEqualToString:@"yearly"]) {
        return EKRecurrenceFrequencyYearly;
    }
    // default to daily, so invoke this method only when recurrence is set
    return EKRecurrenceFrequencyDaily;
}

#pragma mark Event Store Authorization

- (BOOL)isCalendarAccessGranted
{
    EKAuthorizationStatus status = [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];

    return status == EKAuthorizationStatusAuthorized;
}

#pragma mark Availability
- (NSMutableArray *)calendarSupportedAvailabilitiesFromMask:(EKCalendarEventAvailabilityMask)types
{
    NSMutableArray *availabilitiesStrings = [[NSMutableArray alloc] init];
    
    if(types & EKCalendarEventAvailabilityBusy) [availabilitiesStrings addObject:@"busy"];
    if(types & EKCalendarEventAvailabilityFree) [availabilitiesStrings addObject:@"free"];
    if(types & EKCalendarEventAvailabilityTentative) [availabilitiesStrings addObject:@"tentative"];
    if(types & EKCalendarEventAvailabilityUnavailable) [availabilitiesStrings addObject:@"unavailable"];
    
    return availabilitiesStrings;
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
                                            @"allowedAvailabilities": [strongSelf calendarSupportedAvailabilitiesFromMask:calendar.supportedEventAvailabilities],
                                            @"color": [strongSelf hexStringFromColor:[UIColor colorWithCGColor:calendar.CGColor]]
                                            }];
            }
            resolve(eventCalendars);
        }
    });
}

RCT_EXPORT_METHOD(createCalendar:(NSString *)calendarName resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    if (![self isCalendarAccessGranted]) {
        reject(@"error", @"unauthorized to access calendar", nil);
        return;
    }

    __weak RNCalendarUtil *weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        RNCalendarUtil *strongSelf = weakSelf;
        EKCalendar *cal = [strongSelf findEKCalendar:calendarName];

        if (cal == nil) {
            cal = [EKCalendar calendarForEntityType:EKEntityTypeEvent eventStore:strongSelf.eventStore];
            cal.title = calendarName;
            cal.source = [strongSelf findEKSource];

            // if the user did not allow permission to access the calendar, the error Object will be filled
            NSError* error;
            [strongSelf.eventStore saveCalendar:cal commit:YES error:&error];
            if (error == nil) {
                resolve(cal.calendarIdentifier);
            } else {
                NSLog(@"Error in createCalendar: %@", error.localizedDescription);
                reject(@"error", @"Calendar could not be created", error);
            }
        } else {
            // ok, it already exists
            resolve(cal.calendarIdentifier);
        }
    });
}

RCT_EXPORT_METHOD(deleteCalendar:(NSString *)calendarName resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    if (![self isCalendarAccessGranted]) {
        reject(@"error", @"unauthorized to access calendar", nil);
        return;
    }

    __weak RNCalendarUtil *weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        RNCalendarUtil *strongSelf = weakSelf;
        EKCalendar *thisCalendar = [strongSelf findEKCalendar:calendarName];

        if (thisCalendar == nil) {
            resolve(@(YES));
        } else {
            NSError *error;
            [strongSelf.eventStore removeCalendar:thisCalendar commit:YES error:&error];
            if (error == nil) {
                resolve(@(YES));
            } else {
                NSLog(@"Error in deleteCalendar: %@", error.localizedDescription);
                reject(@"error", @"Calendar could not be deleted", error);
            }
        }
    });
}

RCT_EXPORT_METHOD(createEventWithOptions:(NSString *)title
    location: (NSString *)location
    notes: (NSString *)notes
    startTimeMS: (nonnull NSNumber *)startTimeMS
    endTimeMS: (nonnull NSNumber *)endTimeMS
    options: (NSDictionary *) options
    resolver:(RCTPromiseResolveBlock)resolve
    rejecter:(RCTPromiseRejectBlock)reject)
{
    if (![self isCalendarAccessGranted]) {
        reject(@"error", @"unauthorized to access calendar", nil);
        return;
    }

    NSNumber* firstReminderMinutes = options[@"firstReminderMinutes"] != [NSNull null] ? [RCTConvert NSNumber:options[@"firstReminderMinutes"]] : nil;
    NSNumber* secondReminderMinutes = options[@"secondReminderMinutes"] != [NSNull null] ? [RCTConvert NSNumber:options[@"secondReminderMinutes"]] : nil;
    NSString* recurrence = options[@"recurrence"] != [NSNull null] ? [RCTConvert NSString:options[@"recurrence"]] : nil;
    NSString* recurrenceEndTime = options[@"recurrenceEndTime"] != [NSNull null] ? [RCTConvert NSString:options[@"recurrenceEndTime"]] : nil;
    NSNumber* recurrenceIntervalAmount = options[@"recurrenceInterval"] != [NSNull null] ? [RCTConvert NSNumber:options[@"recurrenceInterval"]] : nil;
    NSString* calendarId = options[@"calendarId"] != [NSNull null] ? [RCTConvert NSString:options[@"calendarId"]] : nil;
    NSString* url = options[@"url"] != [NSNull null] ? [RCTConvert NSString:options[@"url"]] : nil;

    __weak RNCalendarUtil *weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        RNCalendarUtil *strongSelf = weakSelf;
        EKEvent *myEvent = [EKEvent eventWithEventStore: strongSelf.eventStore];
        if (url) {
            NSURL* myUrl = [NSURL URLWithString:url];
            myEvent.URL = myUrl;
        }

        NSTimeInterval _startInterval = [startTimeMS doubleValue] / 1000; // strip millis
        NSDate *myStartDate = [NSDate dateWithTimeIntervalSince1970:_startInterval];

        NSTimeInterval _endInterval = [endTimeMS doubleValue] / 1000; // strip millis

        myEvent.title = title;
        myEvent.location = location;
        myEvent.notes = notes;
        myEvent.startDate = myStartDate;

        int duration = _endInterval - _startInterval;
        int moduloDay = duration % (60*60*24);
        if (moduloDay == 0) {
            myEvent.allDay = YES;
            myEvent.endDate = [NSDate dateWithTimeIntervalSince1970:_endInterval-1];
        } else {
            myEvent.endDate = [NSDate dateWithTimeIntervalSince1970:_endInterval];
        }

        EKCalendar* calendar = nil;
        if (calendarId) {
            calendar = [strongSelf findEKCalendar:calendarId];
        }
        if (!calendar) {
            calendar = strongSelf.eventStore.defaultCalendarForNewEvents;
            if (calendar == nil) {
                reject(@"error", @"No default calendar found", nil);
                return;
            }
        }
        myEvent.calendar = calendar;

        if (firstReminderMinutes) {
            EKAlarm *reminder = [EKAlarm alarmWithRelativeOffset:-1*firstReminderMinutes.intValue*60];
            [myEvent addAlarm:reminder];
        }

        if (secondReminderMinutes) {
            EKAlarm *reminder = [EKAlarm alarmWithRelativeOffset:-1*secondReminderMinutes.intValue*60];
            [myEvent addAlarm:reminder];
        }

        if (recurrence) {
            EKRecurrenceRule *rule = [[EKRecurrenceRule alloc]
                                        initRecurrenceWithFrequency: [strongSelf toEKRecurrenceFrequency:recurrence]
                                        interval: recurrenceIntervalAmount.integerValue
                                        end: nil];
            if (recurrenceEndTime != nil) {
                NSTimeInterval _recurrenceEndTimeInterval = [recurrenceEndTime doubleValue] / 1000; // strip millis
                NSDate *myRecurrenceEndDate = [NSDate dateWithTimeIntervalSince1970:_recurrenceEndTimeInterval];
                EKRecurrenceEnd *end = [EKRecurrenceEnd recurrenceEndWithEndDate:myRecurrenceEndDate];
                rule.recurrenceEnd = end;
            }
            [myEvent addRecurrenceRule:rule];
        }

        NSError *error = nil;
        [strongSelf.eventStore saveEvent:myEvent span:EKSpanThisEvent error:&error];

        if (error) {
            reject(@"error", @"Fail to save event", error);
        } else {
            resolve(myEvent.calendarItemIdentifier);
        }
    });
}
@end
  
