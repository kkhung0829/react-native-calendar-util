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

### Step 3. - OS specific setup

- [**iOS specific instructions**](https://github.com/wmcmahan/react-native-calendar-events/wiki/iOS-setup)<br/> iOS specific requirements, such as mandatory privacy usage descriptions and including the `EventKit.framework`.

- [**Android specific instructions**](https://github.com/wmcmahan/react-native-calendar-events/wiki/Android-setup)<br/> Android specific requirements, such as mandatory application permissions.

<br/>

## API
The following API allows for interacting with both iOS and Android device calendars. See the full list of available [event fields](#event-fields).


```javascript
import RNCalendarEvents from 'react-native-calendar-events';
```

<br/>

### authorizationStatus
Get calendar authorization status.

```javascript
RNCalendarEvents.authorizationStatus()
```

Returns: **Promise** 
- fulfilled: String - `denied`, `restricted`, `authorized` or `undetermined`
- rejected: Error

<br/>

### authorizeEventStore
Request calendar authorization. Authorization must be granted before accessing calendar events.

> Android note: This is only necessary for targeted SDK of 23 and higher.

```javascript
RNCalendarEvents.authorizeEventStore()
```

Returns: **Promise** 
 - fulfilled: String - `denied`, `restricted`, `authorized` or `undetermined`
 - rejected: Error

<br/>

### listCalendars
List all the calendars on the device.

```javascript
RNCalendarEvents.listCalendars()
```

Returns: **Promise** 
 - fulfilled: Array - A list of known calendars on the device
 - rejected: Error

<br/>

### createCalendar
Create calendars on the device.

```javascript
RNCalendarEvents.createCalendar(name)
```

Returns: **Promise** 
 - fulfilled: The new calendar id
 - rejected: Error

<br/>

### deleteCalendar
Delete calendars on the device.

```javascript
RNCalendarEvents.deleteCalendar(name)
```

Returns: **Promise** 
 - fulfilled: Nothing
 - rejected: Error

<br/>

### getCalendarOptions
Returns the default calendar options.

```javascript
RNCalendarEvents.getCalendarOptions()
```

Returns: An object with the default calendar options
<br/>

### createEvent
Create an event.

```javascript
RNCalendarEvents.createEvent(title, location, notes, startTimeMS, endTimeMS)
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
RNCalendarEvents.createEventWithOptions(title, location, notes, startTimeMS, endTimeMS, options)
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
