using LocalTime;
using MathExtra;
using Toybox.System;
using Toybox.Time;
using Toybox.WatchUi;

class DaylightLeftView extends WatchUi.SimpleDataField {
    // Show value even at night, for testing...
    var FORCE_SHOW = false;
    
    // Testing override for Local.now() 
    //var NOW = LocalTime.now().add(new Time.Duration(-3600 * 4));
    var NOW = null;
	
    var BLANK_TIME = new Time.Duration(0);
    
	hidden var mValuesComputed = false;
	hidden var mSunrise = null;
	hidden var mSunset = null;

    //! Set the label of the data field here.
    function initialize() {
        label = "Daylight Left";
    }
    
    function computeOneTime(location) {
		var latLng = location.toDegrees();
		var latitude = latLng[0];
		var longitude = latLng[1];
		
        var clockTime = System.getClockTime();	
		
        mSunrise = LocalTime.sunrise(
            latitude, longitude, clockTime.timeZoneOffset,
            LocalTime.ZENITH_OFFICIAL);
        mSunset = LocalTime.sunset(
            latitude, longitude, clockTime.timeZoneOffset,
            LocalTime.ZENITH_OFFICIAL);
        //System.println("mSunrise = " + mSunrise.value() + " mSunset = " + mSunset.value());

        mValuesComputed = true;
    }
    
    function compute(info) {
        // See Activity.Info in the documentation for available information.
        var location = info.currentLocation;

        // If GPS hasn't initialized yet  or we don't GPS capabilities
        if (location == null) {
            //System.println("Showing blank time because we don't have a location yet");
            return BLANK_TIME;
        }

        if (!mValuesComputed) {
            computeOneTime(location);
        }

        // No sunset this day (are we in the arctic?)
        if (mSunrise == null) {
            //System.println("Showing blank time because we there's no sunrise in this location");
            return BLANK_TIME;
        } else if (mSunset == null) {
            //System.println("Showing blank time because we there's no sunset in this location");
            return BLANK_TIME;
        }
        
        var now = (NOW == null) ? LocalTime.now() : NOW;

        var isDaylightOut = LocalTime.isDaylightOut({
            :sunrise => mSunrise,
            :sunset => mSunset,
            :now => now});
        //System.println("isDaylightOut = " + isDaylightOut);

        if (isDaylightOut || FORCE_SHOW) {
            return mSunset.subtract(now);
        }

        //System.println("Showing blank time because it's not currently daylight out");
        return BLANK_TIME;
    }
}