using Toybox.Application;
using Toybox.Lang;
using Toybox.System;
using Toybox.Time;
using Toybox.WatchUi;

using LocalTime;
using MathExtra;

class DaylightLeftView extends WatchUi.SimpleDataField {
    enum {
        PROPERTY_LAT_LNG = 0
    }

    hidden const TEST_LAT_LNG = null;
    //hidden const TEST_LAT_LNG = [30.25, -97.75];      // Austin, TX
    //hidden const TEST_LAT_LNG = [90.0, 0];            // North Pole
    //hidden const TEST_LAT_LNG = [-90.0, 0];           // South Pole

    hidden const TEST_TODAY_OFFSET = null;
    //hidden const TEST_TODAY_OFFSET = -1;

    hidden const TEST_NOW_OFFSET = null;
    //hidden const TEST_NOW_OFFSET = -6 * 3600;

    hidden var mSunset = null;

    function initialize() {
        WatchUi.SimpleDataField.initialize();
        label = WatchUi.loadResource(Rez.Strings.label);
    }

    hidden function getLatLng(info) {
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

    hidden function computeSunset(latlng) {
        // Compute today
        var today = Time.today();
        if (TEST_TODAY_OFFSET != null) {
            today = today.add(new Time.Duration(TEST_TODAY_OFFSET * 86400));
        }

        var gToday = Time.Gregorian.info(today, Time.FORMAT_SHORT);
        var year = gToday.year;
        var month = gToday.month;
        var day = gToday.day;

        //System.println(Lang.format("Lat/Lng is [$1$, $2$]", latlng));

        var timeZoneOffset = System.getClockTime().timeZoneOffset;

        //System.println(Lang.format("Timezone offset is $1$", [timeZoneOffset]));

        var secondsAfterMidnight = LocalTime.sunset(
            year, month, day, latlng[0], latlng[1], timeZoneOffset,
            LocalTime.ZENITH_OFFICIAL);

        if (secondsAfterMidnight < 0) {
            // Negative numbrers represent exceptional cases
            return secondsAfterMidnight;
        }

        //var ss = secondsAfterMidnight;
        //var mm = ss / 60;
        //ss %= 60;
        //var hh = mm / 60;
        //mm %= 60;
        //System.println(Lang.format("Sunset for $1$-$2$-$3$ is $4$:$5$:$6$",
        //     [year, month, day,
        //      hh.format("%02d"), mm.format("%02d"), ss.format("%02d")]));

        return today.add(new Time.Duration(secondsAfterMidnight));
    }

    function compute(info) {
        var sunset;
        var usingGPSCache = false;

        if (mSunset == null) {

            var latlng = getLatLng(info);

            if (latlng == null) {
                usingGPSCache = true;
                latlng = Application.getApp().getProperty(PROPERTY_LAT_LNG);
                //System.println("Using cached coordinates " + latlng);
            } else {
                //System.println("Using real coordinates " + latlng);
                Application.getApp().setProperty(PROPERTY_LAT_LNG, latlng);
            }

            if (latlng == null) {
                //System.println("Unable to compute sunset without GPS");
                return WatchUi.loadResource(Rez.Strings.no_gps);
            }

            sunset = computeSunset(latlng);

            // We only want to cache the sunset if we're using current GPS
            // coordinates, not cached. This is because we want to keep polling
            // for real coordinates in case they weren't immediately available
            if (!usingGPSCache) {
                mSunset = sunset;
            }
        } else {
            sunset = mSunset;
        }

        if (sunset == LocalTime.NO_SUNSET) {
            //System.println("Sunset does not occur at this location");
            return WatchUi.loadResource(Rez.Strings.no_sunset);
        }  else if (sunset == LocalTime.NO_SUNRISE) {
            //System.println("Sunrise does not occur at this location");
            return WatchUi.loadResource(Rez.Strings.no_sunrise);
        }

        var now = Time.now();
        if (TEST_NOW_OFFSET != null) {
            now = now.add(new Time.Duration(TEST_NOW_OFFSET));
        }

        if (now.greaterThan(sunset)) {
            //System.println("We're after sunset, so showing blank time...");
            return new Time.Duration(0);
        }

        return sunset.subtract(now);
    }
}
