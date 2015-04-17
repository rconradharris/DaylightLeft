using MathExtra;
using Toybox.Math;
using Toybox.System;
using Toybox.Time;

module LocalTime {

    // These values used to determine the definition of sunrise and sunset
    //
    // Official is when the sun actually crosses the horizon
    // Civil is when there is still enough light out to do stuff (technical term)
    // Nautical means sailors can still see the horizon to navigate
    // Astronomical means that the sky is fully dark
    var ZENITH_OFFICIAL = 90.8333333333;
    var ZENITH_CIVIL = 96.0;
    var ZENITH_NAUTICAL = 102.0;
    var ZENITH_ASTRONOMICAL = 108.0;

    // Return a `Moment`representing now relative to the local time
    function now() {
        var offsetSeconds = System.getClockTime().timeZoneOffset;
        var offsetDuration = new Time.Duration(offsetSeconds);
        return Time.now().add(offsetDuration);
    }

    // Return a `Moment` representing the start of the current local day
    function today() {
        // Time.today() claims to do this based on your GPS, but appears to
        // actually be using UTC
        var utcToday = Time.today();

        if (utcToday.greaterThan(now())) {
            var oneDayBackwards = new Time.Duration(-Time.Gregorian.SECONDS_PER_DAY);
            // We're still in the previous day locally, so use the previous day
            return utcToday.add(oneDayBackwards);
        } else {
            // We're in the same day as UTC so we can use its today value
            return utcToday;
        }
    }

    // Return a `Moment` representing sunrise for the current day
    //
    // NOTE: This will return `null` if there's no sunrise at this particular
    // location
    function sunrise(latitude, longitude, timeZoneOffset, zenith) {
        return sunriseOrSunsetMoment(
            :sunrise, latitude, longitude, timeZoneOffset, zenith);
    }

    // Return a `Moment` representing sunset for the current day
    //
    // NOTE: This will return `null` if there's no sunset at this particular
    // location
    function sunset(latitude, longitude, timeZoneOffset, zenith) {
        return sunriseOrSunsetMoment(
            :sunset, latitude, longitude, timeZoneOffset, zenith);
    }

    // Return whether there is daylight out right now
    function isDaylightOut(sunrise, sunset) {
        if (sunset == null) {
            return true;
        } else if (sunrise == null) {
            return false;
        } else {
            var midnight = today();
            var t = now().subtract(midnight).value();
            var sunriseSeconds = sunrise.subtract(midnight).value();
            var sunsetSeconds = sunset.subtract(midnight).value();
            //System.println("sunriseSeconds = " + sunriseSeconds + " t = " + t + " sunsetSeconds = " + sunsetSeconds);

            return (sunriseSeconds < t ) && (t < sunsetSeconds);
        }
    }

    hidden function sunriseOrSunsetMoment(mode, latitude, longitude,
                                          timeZoneOffset, zenith) {
        var thisDay = today();
        var gToday = Time.Gregorian.info(thisDay, Time.FORMAT_SHORT);

        var secondsAfterMidnight = sunriseOrSunset(
            mode, gToday.year, gToday.month, gToday.day,
            latitude, longitude, timeZoneOffset, zenith);

        if (secondsAfterMidnight == null) {
            return null;
        }

        var duration = new Time.Duration(secondsAfterMidnight);
        return thisDay.add(duration);
    }

    // Returns number of secs from midnight for sunrise or sunset (or null if
    // no sunrise or sunset at this location)
    //
    // Source http://williams.best.vwh.net/sunrise_sunset_algorithm.htm
    hidden function sunriseOrSunset(mode, year, month, day,
                                   latitude, longitude, timeZoneOffset,
                                   zenith) {
        var localOffset = timeZoneOffset / 3600.0;

        //! 1. first calculate the day of the year
        var N1 = MathExtra.floor(275 * month / 9);
        var N2 = MathExtra.floor((month + 9) / 12);
        var N3 = (1 + MathExtra.floor((year - 4 * MathExtra.floor(year / 4) + 2) / 3));
        var N = N1 - (N2 * N3) + day - 30;
        //System.println("N = " + N);

        //! 2. convert the longitude to hour value and calculate an approximate time
        var lngHour = longitude / 15.0;
        var t = -1.0;
        if (mode == :sunrise) {
            t = N + ((6.0 - lngHour) / 24.0);
        } else {
            t = N + ((18.0 - lngHour) / 24.0);
        }
        //System.println("t = " + t);

        //! 3. calculate the Sun's mean anomaly
        var M = (0.9856 * t) - 3.289;
        //System.println("M = " + M);

        //! 4. calculate the Sun's true longitude
        var L = M + (1.916 * MathExtra.sinD(M)) + (0.020 * MathExtra.sinD(2 * M)) + 282.634;
        //!NOTE: L potentially needs to be adjusted into the range [0,360) by adding/subtracting 360
        L = MathExtra.mod360(L);
        //System.println("L = " + L);

        //! 5a. calculate the Sun's right ascension
        var RA = MathExtra.atanD(0.91764 * MathExtra.tanD(L));
        //!NOTE: RA potentially needs to be adjusted into the range [0,360) by adding/subtracting 360
        RA = MathExtra.mod360(RA);
        //System.println("RA(5a) = " + RA);

        //! 5b. right ascension value needs to be in the same quadrant as L
        var Lquadrant  = MathExtra.floor(L / 90) * 90.0;
        var RAquadrant = MathExtra.floor(RA / 90) * 90.0;
        RA = RA + (Lquadrant - RAquadrant);
        //System.println("RA(5b) = " + RA);

        //! 5c. right ascension value needs to be converted into hours
        RA = RA / 15.0;
        //System.println("RA(5c) = " + RA);

        //!6. calculate the Sun's declination
        var sinDec = 0.39782 * MathExtra.sinD(L);
        var cosDec = MathExtra.cosD(MathExtra.asinD(sinDec));
        //System.println("sinDec = " + sinDec + " cosDec = " + cosDec);

        //! 7a. calculate the Sun's local hour angle
        var cosH = (MathExtra.cosD(zenith) - (sinDec * MathExtra.sinD(latitude))) / (cosDec * MathExtra.cosD(latitude));
        //System.println("cosH = " + cosH);
        if (cosH >  1) {
            return null;
        } else if (cosH < -1) {
            return null;
        }

        //! 7b. finish calculating H and convert into hours
        var H = -1.0;
        if (mode == :sunrise) {
            H = 360 - MathExtra.acosD(cosH);
        } else {
            H = MathExtra.acosD(cosH);
        }
        H = H / 15;
        //System.println("H = " + H);

        //! 8. calculate local mean time of rising/setting
        var T = H + RA - (0.06571 * t) - 6.622;
        //System.println("T = " + T);

        //! 9. adjust back to UTC
        var UT = T - lngHour;
        //!NOTE: UT potentially needs to be adjusted into the range [0,24) by adding/subtracting 24
        UT = MathExtra.modFloat(UT, 24.0);
        //System.println("UT = " + UT);

        //! 10. convert UT value to local time zone of latitude/longitude
        var localT = UT + localOffset;
        localT = MathExtra.modFloat(localT, 24.0);
        //System.println("localT = " + localT);

        //! 11. Convert localT to seconds
        var localTS = (localT * 3600).toNumber();
        //System.println("localTS = " + localTS);

        return localTS;
    }
}