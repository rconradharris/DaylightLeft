using MathExtra;
using Toybox.Math;
using Toybox.System;
using Toybox.Time;

module SunInfo {	
	var ZENITH_OFFICIAL = 90.8333333333;
	var ZENITH_CIVIL = 96.0;
	var ZENITH_NAUTICAL = 102.0;
	var ZENITH_ASTRONOMICAL = 108.0;
	
	// Returns number of secs from start of day for Sunrise or Sunset (or null if no sunrise or sunset at this location)
	// Source http://williams.best.vwh.net/sunrise_sunset_algorithm.htm
	function getSunriseOrSunsetSecs(mode, year, month, day, latitude, longitude, localOffset, zenith) {
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
		} else if (mode == :sunset) {
			t = N + ((18.0 - lngHour) / 24.0);
		} else {
			System.println("ERROR: bad mode");
			// TODO: throw exception
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
		} else if (mode == :sunset) {
			H = MathExtra.acosD(cosH);
		} else {
			System.println("ERROR: bad mode");
			// TODO: throw exception
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
		var localTS = MathExtra.floor(localT * 3600);
		//System.println("localTS = " + localTS);
		return localTS;
	}
	
	// Returns duration of Daylight left as a Duration object or null if there is no sunset
	function getDaylightLeftDuration(year, month, day, latitude, longitude, localOffset, zenith) {	
		var nowSecs = Time.now().value();
		var todaySecs = Time.today().value();
		
		var utcSecsSinceMidnight = nowSecs - todaySecs;
		
		var localSecsSinceMidnight = utcSecsSinceMidnight + (localOffset * 3600);
		
		var localSecsUntilSunset = SunInfo.getSunriseOrSunsetSecs(:sunset, year, month, day, latitude, longitude, localOffset, zenith);
		
		// If we're in the Artic and there isn't a sunset today...
		if (localSecsUntilSunset == null) {
			return null;
		}
		
		var deltaSecsUntilSunset = localSecsUntilSunset - localSecsSinceMidnight;
		
		return new Time.Duration(deltaSecsUntilSunset);
	}
	
}