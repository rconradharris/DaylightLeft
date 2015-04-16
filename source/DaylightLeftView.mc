using LocalTime;
using MathExtra;
using Toybox.System;
using Toybox.Time;
using Toybox.WatchUi;

	
function secondsToHMS(totalSeconds) {
	totalSeconds = MathExtra.floor(totalSeconds);
	var minutes = totalSeconds / 60;
	totalSeconds = totalSeconds % 60;
	var hours = minutes / 60;
	minutes = minutes % 60;
	return [hours, minutes, totalSeconds];
}


function getHMSStringFromSeconds(totalSeconds) {
	var hms = secondsToHMS(totalSeconds);
	
	var hours = hms[0];
	var hoursStr = hours.toString();
	
	var minutes = hms[1].abs();
	var minutesStr = (minutes < 10) ? ('0' + minutes.toString()) : minutes.toString();
	return hoursStr + ":" + minutesStr;
}
	
	
class DaylightLeftView extends WatchUi.SimpleDataField {
	var BLANK_TIME = "--:--";
	var computedSunriseAndSunset = false;
	var today = null;
	var sunriseSecs = null;
	var sunsetSecs = null;
	
	
    //! Set the label of the data field here.
    function initialize() {
        label = "Daylight Left";
    }
    
    function computeAndStoreSunriseAndSunset(location) {
		var latLng = location.toDegrees();
		var latitude = latLng[0];
		var longitude = latLng[1];
		//System.println("lat = " + latitude.toString() + " lng = " + longitude.toString());
		
		today = Time.today();
		var gToday = Time.Gregorian.info(today, Time.FORMAT_SHORT);
		//System.println("year = " + gToday.year + " month = " + gToday.month + " day = " + gToday.day);
		
		var clockTime = System.getClockTime();
		var localOffset = clockTime.timeZoneOffset / 3600.0;
		//System.println("localOffset = " + localOffset);
		
		var riseAndSet = SunInfo.getSunriseAndSunsetSecs(gToday.year, gToday.month, gToday.day, latitude, longitude, localOffset, SunInfo.ZENITH_OFFICIAL);
		
		sunriseSecs = riseAndSet[0];
		sunsetSecs = riseAndSet[1];
		//System.println("sunriseSecs = " + sunriseSecs + " sunsetSecs = " + sunsetSecs);
		computedSunriseAndSunset = true;
    }
    
    // Return the number of seconds until midnight local time
    function getSecsUntilMidnight() {
		var nowSecs = Time.now().value();
		//System.println("nowSecs" + nowSecs);
		
		var todaySecs = Time.today().value();
		//System.println("todaySecs" + todaySecs);

		var clockTime = System.getClockTime();
		//System.println("timeZoneOffset" + clockTime.timeZoneOffset);

		var secsUntilMidnight = nowSecs - todaySecs + clockTime.timeZoneOffset;
		//System.println("secsUntilMidnight = " + secsUntilMidnight);
		
		return secsUntilMidnight;
	}

    //! The given info object contains all the current workout
    //! information. Calculate a value and return it in this method.
    function compute(info) {    	
        // See Activity.Info in the documentation for available information.
		var location = info.currentLocation;
		
		if ((location != null) && (computedSunriseAndSunset != true)) {
			computeAndStoreSunriseAndSunset(location);
		}
		
		if (sunsetSecs == null) {
			return BLANK_TIME;
		}
	
        var localNow = LocalTime.now();
		//System.println("localNow" + localNow);
		
        var localSecondsSinceMidnight = LocalTime.secondsSinceMidnight();
        //System.println("localSecondsSinceMidnight" + localSecondsSinceMidnight);	

		var latLng = location.toDegrees();
		var latitude = latLng[0];
		var longitude = latLng[1];
        var clockTime = System.getClockTime();	
		
        var sunrise = LocalTime.sunrise(
            latitude, longitude, clockTime.timeZoneOffset,
            LocalTime.ZENITH_OFFICIAL);
        System.println("sunrise" + sunrise);	

		
		//var nowSecs = Time.now().value();
		//System.println("nowSecs" + nowSecs);
		//var todaySecs = Time.today().value();
		//System.println("todaySecs" + todaySecs);
		//var deltaSecs = nowSecs - todaySecs;
		//System.println("deltaSecs" + deltaSecs);

		//var secsUntilMidnight = getSecsUntilMidnight();
		//var deltaSunsetSecs = sunsetSecs - secsUntilMidnight;
		//System.println("deltaSunsetSecs = " + deltaSunsetSecs);
		//return getHMSStringFromSeconds(deltaSunsetSecs);
		return BLANK_TIME;
    }
}