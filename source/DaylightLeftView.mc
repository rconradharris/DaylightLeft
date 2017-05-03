using Toybox.Application;
using Toybox.Lang;
using Toybox.System;
using Toybox.Time;
using Toybox.WatchUi;

using LocalTime;
using MathExtra;

class DaylightLeftView extends WatchUi.SimpleDataField {
    enum {
        OK = 0,
        NO_SUNSET = -1,
        NO_GPS = -2
    }

    hidden const TEST_LAT_LNG = null;
    hidden const TEST_TODAY_OFFSET = null;
    hidden const TEST_NOW_OFFSET = null;

    //hidden const TEST_LAT_LNG = [30.25, -97.75];
    //hidden const TEST_TODAY_OFFSET = -1;
    //hidden const TEST_NOW_OFFSET = -6 * 3600;

    hidden var mSunset = null;
    hidden var mApp = Application.getApp();

    function initialize() {
        WatchUi.SimpleDataField.initialize();
        label = "Daylight Left";
    }

    function computeSunset(info) {
        // Retrieve the current latitude/longitude
        var latlng = null;
        if (info.currentLocation != null) {
            latlng = info.currentLocation.toDegrees();
        }
        if (TEST_LAT_LNG != null) {
            latlng = TEST_LAT_LNG;
        }

        // If GPS hasn't initialized yet  or we don't GPS capabilities
        if (latlng == null) {
            //System.println("Showing blank time because we don't have a location yet");
            return [NO_GPS, null];
        }

        // Compute today
        var today = Time.today();
        if (TEST_TODAY_OFFSET != null) {
            today = today.add(new Time.Duration(TEST_TODAY_OFFSET * 86400));
        }

        var gToday = Time.Gregorian.info(today, Time.FORMAT_SHORT);
        var year = gToday.year;
        var month = gToday.month;
        var day = gToday.day;

        // Compute sunset for today, if not already cached...
        var latitude = latlng[0];
        var longitude = latlng[1];

        //System.println(Lang.format("Lat/Lng is [$1$, $2$]", latlng));

        var timeZoneOffset = System.getClockTime().timeZoneOffset;

        //System.println(Lang.format("Timezone offset is $1$", [timeZoneOffset]));

        var secondsAfterMidnight = LocalTime.sunset(
            year, month, day, latitude, longitude, timeZoneOffset,
            LocalTime.ZENITH_OFFICIAL);

        if (secondsAfterMidnight == null) {
            return [NO_SUNSET, null];
        }

        //var ss = secondsAfterMidnight;
        //var mm = ss / 60;
        //ss %= 60;
        //var hh = mm / 60;
        //mm %= 60;
        //System.println(Lang.format("Sunset for $1$-$2$-$3$ is $4$:$5$:$6$",
        //     [year, month, day,
        //      hh.format("%02d"), mm.format("%02d"), ss.format("%02d")]));

        return [OK, today.add(new Time.Duration(secondsAfterMidnight))];
    }

    function compute(info) {
        var status = null;
        var sunset = null;

        if (mSunset == null) {
            var rv = computeSunset(info);
            status = rv[0];
            sunset = rv[1];
        } else {
            status = OK;
            sunset = mSunset;
        }

        if (status == NO_GPS) {
            //System.println("Unable to compute sunset without GPS");
            return "No GPS";
        } else if (status == NO_SUNSET) {
            //System.println("Sunset does not occur at this location");
            return "No Sunset";
        } else if (status < 0) {
            //System.println("Unknown error");
            return "Error";
        }

        mSunset = sunset;

        var now = Time.now();
        if (TEST_NOW_OFFSET != null) {
            now = now.add(new Time.Duration(TEST_NOW_OFFSET));
        }

        if (now.greaterThan(mSunset)) {
            //System.println("We're after sunset, so showing blank time...");
            return new Time.Duration(0);
        }

        return mSunset.subtract(now);
    }
}