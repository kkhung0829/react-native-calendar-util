
package com.reactlibrary;

import android.Manifest;
import android.app.Activity;
import android.content.SharedPreferences;
import android.content.pm.PackageManager;
import android.os.Build;
import android.support.v4.app.ActivityCompat;
import android.support.v4.content.ContextCompat;
import android.util.Log;

import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.ReadableMap;
import com.reactlibrary.accessor.AbstractCalendarAccessor;
import com.reactlibrary.accessor.CalendarProviderAccessor;
import com.reactlibrary.accessor.LegacyCalendarAccessor;

import org.json.JSONArray;
import org.json.JSONException;

import java.util.HashMap;

import javax.annotation.RegEx;

public class RNCalendarUtilModule extends ReactContextBaseJavaModule {

  private static int PERMISSION_REQUEST_CODE = 37;
  private final ReactApplicationContext reactContext;
  private static final String RNC_PREFS = "REACT_NATIVE_CALENDAR_PREFERENCES";
  private static final HashMap<Integer, Promise> permissionsPromises = new HashMap<>();

  private static final String LOG_TAG = AbstractCalendarAccessor.LOG_TAG;

  public RNCalendarUtilModule(ReactApplicationContext reactContext) {
    super(reactContext);
    this.reactContext = reactContext;
  }

  @Override
  public String getName() {
    return "RNCalendarUtil";
  }

  private boolean haveCalendarReadWritePermissions() {
    int writePermission = ContextCompat.checkSelfPermission(reactContext, Manifest.permission.WRITE_CALENDAR);
    int readPermission = ContextCompat.checkSelfPermission(reactContext, Manifest.permission.READ_CALENDAR);

    return writePermission == PackageManager.PERMISSION_GRANTED &&
            readPermission == PackageManager.PERMISSION_GRANTED;
  }
  //endregion

  //region React Native Methods
  @ReactMethod
  public void listCalendars(final Promise promise) {
    if (this.haveCalendarReadWritePermissions()) {
      try {
        Thread thread = new Thread(new Runnable() {
          @Override
          public void run() {
            try {
              JSONArray activeCalendars = getCalendarAccessor().getActiveCalendars();
              if (activeCalendars == null) {
                activeCalendars = new JSONArray();
              }
              promise.resolve(RNJson.convertJsonToArray(activeCalendars));
            } catch (JSONException e) {
              promise.reject("calendar request error", e.getMessage());
            }
          }
        });
        thread.start();
      } catch (Exception e) {
        promise.reject("calendar request error", e.getMessage());
      }
    } else {
      promise.reject("list calendars error", "you don't have permissions to list calendars");
    }
  }

  @ReactMethod
  public void createCalendar(final String name, final Promise promise) {
    if (this.haveCalendarReadWritePermissions()) {
      try {
        Thread thread = new Thread(new Runnable() {
          @Override
          public void run() {
            String calendarId = getCalendarAccessor().createCalendar(name, null);
            promise.resolve(calendarId);
          }
        });
        thread.start();
      } catch (Exception e) {
        promise.reject("calendar request error", e.getMessage());
      }
    } else {
      promise.reject("create calendar error", "you don't have permissions to create calendar");
    }
  }

  @ReactMethod
  public void deleteCalendar(final String name, final Promise promise) {
    if (this.haveCalendarReadWritePermissions()) {
      try {
        Thread thread = new Thread(new Runnable() {
          @Override
          public void run() {
            getCalendarAccessor().deleteCalendar(name);
            promise.resolve(true);
          }
        });
        thread.start();
      } catch (Exception e) {
        promise.reject("calendar request error", e.getMessage());
      }
    } else {
      promise.reject("delete calendar error", "you don't have permissions to delete calendar");
    }
  }

  @ReactMethod
  public void createEventWithOptions(
          final String title,
          final String location,
          final String notes,
          final double startTimeMS,
          final double endTimeMS,
          final ReadableMap options,
          final Promise promise) {
    if (this.haveCalendarReadWritePermissions()) {
      try {
        Thread thread = new Thread(new Runnable() {
          @Override
          public void run() {
            final String eventId = getCalendarAccessor().createEvent(
                    null,
                    title,
                    (long)startTimeMS,
                    (long)endTimeMS,
                    notes,
                    location,
                    options.hasKey("firstReminderMinutes") && !options.isNull("firstReminderMinutes") ? (long)options.getDouble("firstReminderMinutes") : -1,
                    options.hasKey("secondReminderMinutes") && !options.isNull("secondReminderMinutes") ? (long)options.getDouble("secondReminderMinutes") : -1,
                    options.getString("recurrence"),
                    options.hasKey("recurrenceInterval") && !options.isNull("recurrenceInterval") ? options.getInt("recurrenceInterval") : -1,
                    options.getString("recurrenceWeekstart"),
                    options.getString("recurrenceByDay"),
                    options.getString("recurrenceByMonthDay"),
                    options.hasKey("recurrenceEndTime") && !options.isNull("recurrenceEndTime") ? (long)options.getDouble("recurrenceEndTime") : -1,
                    options.hasKey("recurrenceCount") && !options.isNull("recurrenceCount") ? (long)options.getDouble("recurrenceCount") : -1,
                    options.getString("allday"),
                    options.hasKey("calendarId") && !options.isNull("calendarId") ? Integer.parseInt(options.getString("calendarId")) : 1,
                    options.getString("url"));
            if (eventId != null) {
              promise.resolve(eventId);
            } else {
              promise.reject("create event error", "unknown error");
            }
          }
        });
        thread.start();
      } catch (Exception e) {
        promise.reject("calendar request error", e.getMessage());
      }
    } else {
      promise.reject("create event error", "you don't have permissions to create event");
    }
  }
  //endregion

  private AbstractCalendarAccessor calendarAccessor;

  private AbstractCalendarAccessor getCalendarAccessor() {
    if (this.calendarAccessor == null) {
      // Note: currently LegacyCalendarAccessor is never used, see the TO-DO at the top of this class
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.ICE_CREAM_SANDWICH) {
        Log.d(LOG_TAG, "Initializing calendar plugin");
        this.calendarAccessor = new CalendarProviderAccessor(this.reactContext);
      } else {
        Log.d(LOG_TAG, "Initializing legacy calendar plugin");
        this.calendarAccessor = new LegacyCalendarAccessor(this.reactContext, this.getCurrentActivity());
      }
    }
    return this.calendarAccessor;
  }
}