import Toybox.Lang;

using Toybox.Activity;
using Toybox.Application;
using Toybox.Lang;
using Toybox.Position;
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

    private const TEST_LAT_LNG = [];
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

    private function getLocation(info as Activity.Info) as Position.Location? {
        if (self.TEST_LAT_LNG.size() > 0) {
            return new Position.Location({
                :latitude   => self.TEST_LAT_LNG[0],
                :longitude  => self.TEST_LAT_LNG[1],
                :format     => :degrees
            });
        }

        if (info.currentLocation != null) {
            return info.currentLocation;
        }

        return null;
    }

    // This may throw LocalTime.NoSunrise or LocalTime.NoSunset
    private function computeSunset(loc as Position.Location) as Time.Moment {
        // Compute today
        var today = Time.today();
        if (TEST_TODAY_OFFSET != 0) {
            today = today.add(new Time.Duration(TEST_TODAY_OFFSET * 86400));
        }

        var gToday = Time.Gregorian.info(today, Time.FORMAT_SHORT);
        var year = gToday.year;
        var month = gToday.month;
        var day = gToday.day;

        var deg = loc.toDegrees();
        var lat = deg[0];
        var lng = deg[1];

        DEBUGF("Lat/Lng is [$1$, $2$]", [lat, lng]);

        var timeZoneOffset = System.getClockTime().timeZoneOffset;

        DEBUGF("Timezone offset is $1$", [timeZoneOffset]);

        var zenith = Settings.getZenith();
        DEBUG("Using zenith " + zenith);

        var secondsAfterMidnight = LocalTime.sunset(year, month, day, loc, timeZoneOffset, zenith);

        return today.add(new Time.Duration(secondsAfterMidnight));
    }

    private function getCachedLocation() as Position.Location? {
        var latLngDeg = Application.getApp().getProperty(PROPERTY_LAT_LNG);
        if (latLngDeg == null) {
            return null;
        }

        DEBUGF("Using cached coordinates $1$", latLngDeg);
        return new Position.Location({
            :latitude   => latLngDeg[0],
            :longitude  => latLngDeg[1],
            :format     => :degrees
        });
    }

    private function setCachedLocation(loc as Position.Location) as Void {
        var latLngDeg = loc.toDegrees();
        Application.getApp().setProperty(PROPERTY_LAT_LNG, latLngDeg);
    }

    function compute(info as Activity.Info) as Lang.Numeric or Time.Duration or Lang.String or Null {
        var sunset = Application.getApp().mSunset;
        var usingGPSCache = false;

        if (sunset == null) {
            var loc = self.getLocation(info);

            if (loc == null) {
                usingGPSCache = true;
                loc = self.getCachedLocation();
            } else {
                DEBUGF("Using real coordinates $1$", loc.toDegrees());
                self.setCachedLocation(loc);
            }

            if (loc == null) {
                DEBUG("Unable to compute sunset without GPS");
                return WatchUi.loadResource(Rez.Strings.no_gps);
            }

            try {
                sunset = self.computeSunset(loc);
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
