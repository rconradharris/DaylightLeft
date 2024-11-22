using Toybox.Math;
using Toybox.System;
using Toybox.Time;

using MathExtra;

module LocalTime {
    enum {
        NO_SUNRISE = -1,
        NO_SUNSET = -2
    }

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

    function sunrise(year, month, day, latitude, longitude, timeZoneOffset, zenith) {
        return sunEvent(
            :sunrise, year, month, day, latitude, longitude, timeZoneOffset, zenith);
    }

    function sunset(year, month, day, latitude, longitude, timeZoneOffset, zenith) {
        return sunEvent(
            :sunset, year, month, day, latitude, longitude, timeZoneOffset, zenith);
    }

    // Returns a Number of secs from midnight for sunrise or sunset (or null
    // if no sunrise or sunset at this location)
    //
    // Source http://williams.best.vwh.net/sunrise_sunset_algorithm.htm
    function sunEvent(event, year, month, day, latitude, longitude,
                             timeZoneOffset, zenith) {
        var localOffset = timeZoneOffset / 3600.0;

        //! 1. first calculate the day of the year
        var N1 = Math.floor(275 * month / 9);
        var N2 = Math.floor((month + 9) / 12);
        var N3 = (1 + Math.floor((year - 4 * Math.floor(year / 4) + 2) / 3));
        var N = N1 - (N2 * N3) + day - 30;
        //System.println("N = " + N);

        //! 2. convert the longitude to hour value and calculate an approximate time
        var lngHour = longitude / 15.0;
        var t = -1.0;
        if (event == :sunrise) {
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
        L = MathExtra.fmodPositive(L, 360);
        //System.println("L = " + L);

        //! 5a. calculate the Sun's right ascension
        var RA = MathExtra.atanD(0.91764 * MathExtra.tanD(L));
        //!NOTE: RA potentially needs to be adjusted into the range [0,360) by adding/subtracting 360
        RA = MathExtra.fmodPositive(RA, 360);
        //System.println("RA(5a) = " + RA);

        //! 5b. right ascension value needs to be in the same quadrant as L
        var Lquadrant  = Math.floor(L / 90) * 90.0;
        var RAquadrant = Math.floor(RA / 90) * 90.0;
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
            return NO_SUNSET;
        } else if (cosH < -1) {
            return NO_SUNRISE;
        }

        //! 7b. finish calculating H and convert into hours
        var H = -1.0;
        if (event == :sunrise) {
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
        UT = MathExtra.fmodPositive(UT, 24.0);
        //System.println("UT = " + UT);

        //! 10. convert UT value to local time zone of latitude/longitude
        var localT = UT + localOffset;
        localT = MathExtra.fmodPositive(localT, 24.0);
        //System.println("localT = " + localT);

        //! 11. Convert localT to seconds
        var localTS = localT * 3600;
        //System.println("localTS = " + localTS);

        return localTS.toNumber();
    }
}