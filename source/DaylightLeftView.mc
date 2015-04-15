using MathExtra;
using SunInfo;
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


function getDurationHMString(duration) {
	var durationSecs = duration.value();
	var hms = secondsToHMS(durationSecs);
	
	var hours = hms[0];
	var hoursStr = hours.toString();
	
	var minutes = hms[1];
	var minutesStr = (minutes < 10) ? ('0' + minutes.toString()) : minutes.toString();
	return hoursStr + ":" + minutesStr;
}
	
	
class DaylightLeftView extends WatchUi.SimpleDataField {
	hidden var BLANK_TIME = "--:--";
	hidden var REFRESH_SECS = 15;
	hidden var counter = 0;
	hidden var cachedValue = null;
	
    //! Set the label of the data field here.
    function initialize() {
        label = "Daylight Left";
    }

    //! The given info object contains all the current workout
    //! information. Calculate a value and return it in this method.
    function compute(info) {
        counter += 1;
    	//System.println("counter = " + counter);
    	
    	// compute() is called once a second, but we only want compute values every REFRESH_SECS to save battery life
    	if (counter < REFRESH_SECS && cachedValue != null) {
    		return cachedValue;
    	}
    	
    	//System.println("Refreshing value...");
    	counter = 0;
    
        // See Activity.Info in the documentation for available information.
		var location = info.currentLocation;
		
		if (location == null) {
			return BLANK_TIME;
		} else {
			var latLng = location.toDegrees();
			var latitude = latLng[0];
			var longitude = latLng[1];
			//System.println("lat = " + latitude.toString() + " lng = " + longitude.toString());
			
			var today = Time.Gregorian.info(Time.today(), Time.FORMAT_SHORT);
			//System.println("year = " + today.year + " month = " + today.month + " day = " + today.day);
			
			var clockTime = System.getClockTime();
			var localOffset = clockTime.timeZoneOffset / 3600.0;
			//System.println("localOffset = " + localOffset);
			
			var duration = SunInfo.getDaylightLeftDuration(today.year, today.month, today.day, latitude, longitude, localOffset, SunInfo.ZENITH_OFFICIAL);
			if (duration == null) {
				return BLANK_TIME;
			}
			
			cachedValue = getDurationHMString(duration);
			return cachedValue;
		}
    }
}