using Toybox.Lang;
using Toybox.System;
using Toybox.Time;
using Toybox.WatchUi;

using LocalTime;
using MathExtra;

class DaylightLeftView extends WatchUi.SimpleDataField {
    hidden const TEST_LAT_LNG = null;
    hidden const TEST_TODAY_OFFSET = null;
    hidden const TEST_NOW_OFFSET = null;

    //hidden const TEST_LAT_LNG = [30.25, -97.75];
    //hidden const TEST_TODAY_OFFSET = -1;
    //hidden const TEST_NOW_OFFSET = -6 * 3600;

    hidden var BLANK_TIME = new Time.Duration(0);

    hidden var mSunset = null;
    hidden var mNoSunsetHere = false;

    function initialize() {
        WatchUi.SimpleDataField.initialize();
        label = "Daylight Left";
    }

    function compute(info) {
        var latlng = null;

        // If we already determined that sunset doesn't occur in this
        // location, then short-circuit
        if (mNoSunsetHere) {
            //System.println("Short circuiting because this location doesnt have a sunset");
            return BLANK_TIME;
        }

        // Retrieve the current latitude/longitude
        if (info.currentLocation != null) {
            latlng = info.currentLocation.toDegrees();
        }
        if (TEST_LAT_LNG != null) {
            latlng = TEST_LAT_LNG;
        }

        // If GPS hasn't initialized yet  or we don't GPS capabilities
        if (latlng == null) {
            //System.println("Showing blank time because we don't have a location yet");
            return BLANK_TIME;
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
        if (mSunset == null) {
            var latitude = latlng[0];
            var longitude = latlng[1];

            //System.println(Lang.format("Lat/Lng is [$1$, $2$]", latlng));

            var timeZoneOffset = System.getClockTime().timeZoneOffset;

            //System.println(Lang.format("Timezone offset is $1$", [timeZoneOffset]));

            var secondsAfterMidnight = LocalTime.sunset(
                year, month, day, latitude, longitude, timeZoneOffset,
                LocalTime.ZENITH_OFFICIAL);

            if (secondsAfterMidnight != null) {
                //var ss = secondsAfterMidnight;
                //var mm = ss / 60;
                //ss %= 60;
                //var hh = mm / 60;
                //mm %= 60;
                //System.println(Lang.format("Sunset for $1$-$2$-$3$ is $4$:$5$:$6$",
                //     [year, month, day,
                //      hh.format("%02d"), mm.format("%02d"), ss.format("%02d")]));

                mSunset = today.add(new Time.Duration(secondsAfterMidnight));
            }
        }

        if (mSunset == null) {
            //System.println("Sunset does not occur at this location");
            mNoSunsetHere = true;
            return BLANK_TIME;
        }

        var now = Time.now();
        if (TEST_NOW_OFFSET != null) {
            now = now.add(new Time.Duration(TEST_NOW_OFFSET));
        }

        if (now.greaterThan(mSunset)) {
            //System.println("We're after sunset, so showing blank time...");
            return BLANK_TIME;
        }

        return mSunset.subtract(now);
    }
}