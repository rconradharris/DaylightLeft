using LocalTime;
using MathExtra;
using Toybox.System;
using Toybox.Time;
using Toybox.WatchUi;

class DaylightLeftView extends WatchUi.SimpleDataField {
    var FORCE_SHOW = false;      // Show value even at night, for testing...
    var BLANK_TIME = new Time.Duration(0);
	
	hidden var valuesComputed = false;
	hidden var sunrise = null;
	hidden var sunset = null;

    //! Set the label of the data field here.
    function initialize() {
        label = "Daylight Left";
    }
    
    function computeOneTime(location) {
		var latLng = location.toDegrees();
		var latitude = latLng[0];
		var longitude = latLng[1];
		
        var clockTime = System.getClockTime();	
		
        sunrise = LocalTime.sunrise(
            latitude, longitude, clockTime.timeZoneOffset,
            LocalTime.ZENITH_OFFICIAL);
        sunset = LocalTime.sunset(
            latitude, longitude, clockTime.timeZoneOffset,
            LocalTime.ZENITH_OFFICIAL);
        //System.println("sunrise = " + sunrise.value() + " sunset = " + sunset.value());

        valuesComputed = true;
    }
    
    function compute(info) {
        // See Activity.Info in the documentation for available information.
        var location = info.currentLocation;

        // If GPS hasn't initialized yet  or we don't GPS capabilities
        if (location == null) {
            return BLANK_TIME;
        }

        if (!valuesComputed) {
            computeOneTime(location);
        }

        // No sunset this day (are we in the arctic?)
        if (sunset == null) {
            return BLANK_TIME;
        }

        var isDaylightOut = LocalTime.isDaylightOut(sunrise, sunset);
        //System.println("isDaylightOut = " + isDaylightOut);

        if (isDaylightOut || FORCE_SHOW) {
            return sunset.subtract(LocalTime.now());
        }

        return BLANK_TIME;
    }
}