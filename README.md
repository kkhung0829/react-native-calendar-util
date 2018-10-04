# React Native Calendar Util

A React Native module to help access and save events to iOS and Android calendars.

## Table of contents
- [**Getting started**](#getting-started)
  - [Install](#step-1---install)
  - [Link the library](#step-2---link-the-library)
  - [OS specific setup](#step-3---os-specific-setup)
- [**API methods**](#api)
  - [authorizationStatus](#authorizationstatus)
  - [authorizeEventStore](#authorizeeventstore)
  - [listCalendars](#listcalendars)
  - [createCalendar](#createcalendar)
  - [deleteCalendar](#deletecalendar)
  - [getCalendarOptions](#getcalendaroptions)
  - [createEvent](#createevent)
  - [createEventWithOptions](#createeventwithoptions)

## Getting started
This package assumes that you already have a React Native project or are familiar with React Native. If not, checkout the official documentation for more details about getting started with [React Native](https://facebook.github.io/react-native/docs/getting-started.html).
<br/>

The following is **required** for the package to work properly.

### Step 1. - Install
Install the `react-native-calendar-util` library with native code.

```
npm install --save kkhung0829/react-native-calendar-util
```

### Step 2. - Link the library
Since this package contains native code, you will need to include the code as a library. The React Native documentation on ["Linking Libraries"](https://facebook.github.io/react-native/docs/linking-libraries-ios.html) also provides some details for this process.

+ **Automatic linking**
```
react-native link
```

+ **Manual linking**<br/>
Sometimes "automatic linking" is not sufficient or is not properly including the library. Fortunately, the React Native docs on ["Manual Linking"](https://facebook.github.io/react-native/docs/linking-libraries-ios.html#manual-linking) serves a helpful guide (with pictures) in the process.

### Step 3. - iOS setup
Setting up privacy usage descriptions may also be require depending on which iOS version is supported. This involves updating the Property List, Info.plist, with the corresponding key for the EKEventStore api. [Info.plist reference](https://developer.apple.com/library/content/documentation/General/Reference/InfoPlistKeyReference/Articles/CocoaKeys.html)

For updating the Info.plist key/value via XCode, add a Privacy - Calendars Usage Description key with a usage description as the value. Resulting change to Info.plist should look something like:

```
<key>NSCalendarsUsageDescription</key>
<string>This app requires access to the calendar</string>
```

> Note that for iOS react-native link will not automatically add the required privacy usage description to your Info.plist file, you'll need to do that manually.

<br/>

## API
The following API allows for interacting with both iOS and Android device calendars. See the full list of available [event fields](#event-fields).


```javascript
import RNCalendarUtil from 'react-native-calendar-util';
```

<br/>

### authorizationStatus
Get calendar authorization status.

```javascript
RNCalendarUtil.authorizationStatus()
```

Returns: **Promise** 
- fulfilled: Boolean
- rejected: Error

<br/>

### authorizeEventStore
Request calendar authorization. Authorization must be granted before accessing calendar events.

> Android note: This is only necessary for targeted SDK of 23 and higher.

```javascript
RNCalendarUtil.authorizeEventStore()
```

Returns: **Promise** 
 - fulfilled: Boolean
 - rejected: Error

<br/>

### listCalendars
List all the calendars on the device.

```javascript
RNCalendarUtil.listCalendars()
```

Returns: **Promise** 
 - fulfilled: Array - A list of known calendars on the device
 - rejected: Error

<br/>

### createCalendar
Create calendars on the device.

```javascript
RNCalendarUtil.createCalendar(name)
```

Returns: **Promise** 
 - fulfilled: The new calendar id
 - rejected: Error

<br/>

### deleteCalendar
Delete calendars on the device.

```javascript
RNCalendarUtil.deleteCalendar(name)
```

Returns: **Promise** 
 - fulfilled: Nothing
 - rejected: Error

<br/>

### getCalendarOptions
Returns the default calendar options.

```javascript
RNCalendarUtil.getCalendarOptions()
```

Returns: An object with the default calendar options
<br/>

### createEvent
Create an event.

```javascript
RNCalendarUtil.createEvent(title, location, notes, startTimeMS, endTimeMS)
```

Arguments: 
 - title: The event title
 - location: The event location
 - notes: The event notes
 - startTimeMS: The event start date in numeric value (date.getTime())
 - endTimeMS: The event end date in numeric value (date.getTime())

Returns: **Promise** 
 - fulfilled: The new event id.
 - rejected: Error

<br/>

### createEventWithOptions
Create an event.

```javascript
RNCalendarUtil.createEventWithOptions(title, location, notes, startTimeMS, endTimeMS, options)
```

Arguments: 
 - title: The event title
 - location: The event location
 - notes: The event notes
 - startTimeMS: The event start date in numeric value (date.getTime())
 - endTimeMS: The event end date in numeric value (date.getTime())
 - options: Additional options obtained by getCalendarOptions().

Returns: **Promise** 
 - fulfilled: The new event id.
 - rejected: Error
<br/>
