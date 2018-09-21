'use strict';

import {
    NativeModules,
    PermissionsAndroid,
} from 'react-native';

const { RNCalendarUtil } = NativeModules;

export default {
    async authorizationStatus() {
        return PermissionsAndroid.check(PermissionsAndroid.PERMISSIONS.READ_CALENDAR)
            .then(isAuthorized => {
console.log('authorizationStatus: ' + isAuthorized);
                if (isAuthorized) {
                    return PermissionsAndroid.check(PermissionsAndroid.PERMISSIONS.WRITE_CALENDAR);
                } else{
                    return isAuthorized;
                }
            })
    },

    async authorizeEventStore() {
        return PermissionsAndroid.requestMultiple([
            PermissionsAndroid.PERMISSIONS.READ_CALENDAR,
            PermissionsAndroid.PERMISSIONS.WRITE_CALENDAR,
        ]).then(result => {
console.log('authorizeEventStore: ' + JSON.stringify(result));
            return (result[PermissionsAndroid.PERMISSIONS.READ_CALENDAR] === PermissionsAndroid.RESULTS.GRANTED
                    && result[PermissionsAndroid.PERMISSIONS.WRITE_CALENDAR] === PermissionsAndroid.RESULTS.GRANTED);
        })
    },

    async listCalendars() {
        return RNCalendarUtil.listCalendars();
    },

    async createCalendar(name) {
        return RNCalendarUtil.createCalendar(name);
    },

    async deleteCalendar(name) {
        return RNCalendarUtil.deleteCalendar(name);
    },

    getCalendarOptions() {
        return {
            firstReminderMinutes: 60,
            secondReminderMinutes: null,
            recurrence: null, // options are: 'daily', 'weekly', 'monthly', 'yearly'
            recurrenceInterval: 1, // only used when recurrence is set
            recurrenceWeekstart: "MO",
            recurrenceByDay: null,
            recurrenceByMonthDay: null,
            recurrenceEndDate: null,
            recurrenceCount: null,
            allday: null,
            calendarId: null,
            url: null
        };
    },

    async createEvent(title, location, notes, startTimeMS, endTimeMS) {
        return createEventWithOptions(title, location, notes, startTimeMS, endTimeMS, getCalendarOptions());
    },

    async createEventWithOptions(title, location, notes, startTimeMS, endTimeMS, options) {
        return RNCalendarUtil.createEventWithOptions(title, location, notes, startTimeMS, endTimeMS, options);
    }
}
