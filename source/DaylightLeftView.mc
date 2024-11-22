import Toybox.Lang;

using Toybox.Activity;
using Toybox.Application;
using Toybox.Lang;
using Toybox.System;
using Toybox.Time;
using Toybox.WatchUi;

using LocalTime;
using MathExtra;

class DaylightLeftView extends WatchUi.SimpleDataField {

    private const DEBUG_MODE = true;

    enum {
        PROPERTY_LAT_LNG = 0
    }

    private const TEST_LAT_LNG = null;
    //private const TEST_LAT_LNG = [30.25, -97.75];      // Austin, TX
    //private const TEST_LAT_LNG = [90.0, 0];            // North Pole
    //private const TEST_LAT_LNG = [-90.0, 0];           // South Pole

    private const TEST_TODAY_OFFSET as Number = 0;
    //private const TEST_TODAY_OFFSET = -1;

    private const TEST_NOW_OFFSET as Number = 0;
    //private const TEST_NOW_OFFSET = -6 * 3600;

    function initialize() {
        WatchUi.SimpleDataField.initialize();
       label = WatchUi.loadResource(Rez.Strings.label);
    }

    private function DEBUG(msg as String) as Void {
        if (self.DEBUG_MODE) {
            PRINT(msg);
        }
    }

    private function DEBUGF(format as String, params as Array) as Void {
        if (self.DEBUG_MODE) {
            PRINTF(format, params);
        }
    }

    private function getLatLng(info) {
        var latlng = null;
        if (TEST_LAT_LNG != null) {
            // 1. Test data
            latlng = TEST_LAT_LNG;
        } else if (info.currentLocation != null) {
            // 2. Real GPS coords
            latlng = info.currentLocation.toDegrees();
        }
        return latlng;
    }

    // This may throw LocalTime.NoSunrise or LocalTime.NoSunset
    private function computeSunset(latlng) as Time.Moment {
        // Compute today
        var today = Time.today();
        if (TEST_TODAY_OFFSET != 0) {
            today = today.add(new Time.Duration(TEST_TODAY_OFFSET * 86400));
        }

        var gToday = Time.Gregorian.info(today, Time.FORMAT_SHORT);
        var year = gToday.year;
        var month = gToday.month;
        var day = gToday.day;

        DEBUGF("Lat/Lng is [$1$, $2$]", latlng);

        var timeZoneOffset = System.getClockTime().timeZoneOffset;

        DEBUGF("Timezone offset is $1$", [timeZoneOffset]);

        var zenith = Settings.getZenith();
        DEBUG("Using zenith " + zenith);

        var secondsAfterMidnight = LocalTime.sunset(
            year, month, day, latlng[0], latlng[1], timeZoneOffset, zenith);

        return today.add(new Time.Duration(secondsAfterMidnight));
    }

    function compute(info as Activity.Info) as Lang.Numeric or Time.Duration or Lang.String or Null {
        var sunset = Application.getApp().mSunset;
        var usingGPSCache = false;

        if (sunset == null) {

            var latlng = getLatLng(info);

            if (latlng == null) {
                usingGPSCache = true;
                latlng = Application.getApp().getProperty(PROPERTY_LAT_LNG);
                DEBUG("Using cached coordinates " + latlng);
            } else {
                DEBUG("Using real coordinates " + latlng);
                Application.getApp().setProperty(PROPERTY_LAT_LNG, latlng);
            }

            if (latlng == null) {
                DEBUG("Unable to compute sunset without GPS");
                return WatchUi.loadResource(Rez.Strings.no_gps);
            }

            try {
                sunset = self.computeSunset(latlng);
            } catch (ex instanceof LocalTime.NoSunrise) {
                DEBUG("Sunrise does not occur at this location");
                return WatchUi.loadResource(Rez.Strings.no_sunrise);
            } catch (ex instanceof LocalTime.NoSunset) {
                DEBUG("Sunset does not occur at this location");
                return WatchUi.loadResource(Rez.Strings.no_sunset);
            }

            // We only want to cache the sunset if we're using current GPS
            // coordinates, not cached. This is because we want to keep polling
            // for real coordinates in case they weren't immediately available
            if (!usingGPSCache) {
                var app = Application.getApp();
                app.mSunset = sunset;
            }
        }

        var now = Time.now();
        if (TEST_NOW_OFFSET != 0) {
            now = now.add(new Time.Duration(TEST_NOW_OFFSET));
        }

        if (now.greaterThan(sunset)) {
            DEBUG("We're after sunset, so showing blank time...");
            return new Time.Duration(0);
        }

        return sunset.subtract(now);
    }
}
