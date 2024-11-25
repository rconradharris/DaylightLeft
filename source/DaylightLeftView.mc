import Toybox.Lang;

using Toybox.Activity;
using Toybox.Application;
using Toybox.Lang;
using Toybox.Position;
using Toybox.System;
using Toybox.Time;
using Toybox.WatchUi;

using Compat.LocalDate;
using Sun;
using MathExtra;


class NoGPS extends Exception {

    function initialize(msg as String) {
        Exception.initialize();
        self.mMessage = msg;
    }

}


class DaylightLeftView extends WatchUi.SimpleDataField {

    private const DEBUG_MODE = false;

    enum {
        PROPERTY_LAT_LNG = 0
    }

    private const TEST_LAT_LNG = [];
    //private const TEST_LAT_LNG = [30.25, -97.75];      // Austin, TX
    //private const TEST_LAT_LNG = [90.0, 0];            // North Pole
    //private const TEST_LAT_LNG = [-90.0, 0];           // South Pole

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

    // This may throw Sun.NoSunrise or Sun.NoSunset
    private function computeSunset(loc as Position.Location, midnight as Time.Moment) as Time.Moment {
        var date = LocalDate.fromMoment(midnight);
        var zenith = Settings.getZenith();

        var secsAfterMidnight = Sun.setsAt(date, loc, zenith);
        var sunset = midnight.add(new Time.Duration(secsAfterMidnight));

        var sunsetStr = Utils.Time.format(sunset, Utils.Time.FORMAT_ISO_8601);

        DEBUGF("computeSunset(date=$1$, loc=$2$, zenith=$3$) -> $4$", [
            date.toString(),
            loc.toDegrees(),
            zenith,
            sunsetStr,
        ]);

        return sunset;
    }

    private function getCachedLocation() as Position.Location? {
        var latLngDeg = Compat.PropStore.get(PROPERTY_LAT_LNG) as [Double, Double]?;
        if (latLngDeg == null) {
            return null;
        }

        return new Position.Location({
            :latitude   => latLngDeg[0],
            :longitude  => latLngDeg[1],
            :format     => :degrees
        });
    }

    private function setCachedLocation(loc as Position.Location) as Void {
        var latLngDeg = loc.toDegrees();
        Compat.PropStore.set(PROPERTY_LAT_LNG, latLngDeg);
    }

    // To avoid unnecessary computation, we cache the sunset computation
    //
    // Throws NoGPS, NoSunrise and NoSunset
    private function getCachedSunset(info as Activity.Info, midnight as Time.Moment) as Time.Moment {
        var app = Application.getApp();

        var sunset = app.getCachedSunset();
        if (sunset != null) {
            return sunset;
        }

        var loc = self.getLocation(info);

        var gpsFix = false;

        if (loc == null) {
            // Location information may not be immediately available. In this
            // case, we still want to show a reasonable value, so we cache the
            // last known location and use that until we get a real GPS fix
            loc = self.getCachedLocation();
            DEBUGF("Using cached coordinates $1$", [loc.toDegrees()]);
        } else {
            DEBUGF("Using GPS coordinates $1$", [loc.toDegrees()]);
            gpsFix = true;
            self.setCachedLocation(loc);
        }

        if (loc == null) {
            throw new NoGPS("unable to get location from GPS or cache");
        }

        sunset = self.computeSunset(loc, midnight);

        // We only want to cache the sunset if we're using current GPS
        // coordinates, not cached a cached location. This is because we want to
        // keep polling for real coordinates in case they weren't immediately
        // available
        if (gpsFix) {
            app.setCachedSunset(sunset);
        }

        return sunset;
    }

    function compute(info as Activity.Info) as Lang.Numeric or Time.Duration or Lang.String or Null {
        var sunset;

        var midnight = Time.today();

        try {
            sunset = self.getCachedSunset(info, midnight);
        } catch (ex instanceof NoGPS) {
            DEBUG("Unable to compute sunset without GPS");
            return WatchUi.loadResource(Rez.Strings.no_gps);
        } catch (ex instanceof Sun.NoSunrise) {
            DEBUG("Sunrise does not occur at this location");
            return WatchUi.loadResource(Rez.Strings.no_sunrise);
        } catch (ex instanceof Sun.NoSunset) {
            DEBUG("Sunset does not occur at this location");
            return WatchUi.loadResource(Rez.Strings.no_sunset);
        }

        var now = Time.now();
        if (TEST_NOW_OFFSET != 0) {
            now = now.add(new Time.Duration(TEST_NOW_OFFSET));
        }

        if (now.greaterThan(sunset)) {
            DEBUG("We're after sunset, so showing blank time...");
            return new Time.Duration(0);
        }

        var daylightLeft = sunset.subtract(now);

        return daylightLeft;
    }
}
