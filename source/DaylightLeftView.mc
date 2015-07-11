using LocalTime;
using MathExtra;
using Toybox.System;
using Toybox.Time;
using Toybox.WatchUi;

class DaylightLeftView extends WatchUi.SimpleDataField {
    hidden var TEST_LAT_LNG = null; // [30.25, -97.75];
    hidden var TEST_NOW_OFFSET = null;
	
    hidden var BLANK_TIME = new Time.Duration(0);
    
	hidden var mToday = null;
	hidden var mSunset = null;
	hidden var mStartTime = null;

    function initialize() {
        label = "Daylight Left";
        mStartTime = LocalTime.now();
    }
    
    function compute(info) {
        var latLng = getLatLng(info); 
        // If GPS hasn't initialized yet  or we don't GPS capabilities
        if (latLng == null) {
            //System.println("Showing blank time because we don't have a location yet");
            return BLANK_TIME;
        }
        computeSunsetForToday(latLng);
        if (mSunset == null) {
            //System.println("Showing blank time because we there's no sunset in this location");
            return BLANK_TIME;
        }
        var now = getNow(); 
        if (now.greaterThan(mSunset)) {
            return BLANK_TIME;
        }
        return mSunset.subtract(now);
    }

    hidden function computeSunsetForToday(latLng) {
        var today = getToday();
        if (today == mToday) {
            return;
        }
        var clockTime = System.getClockTime();	
        mSunset = LocalTime.sunset(
            today, latLng[0], latLng[1], clockTime.timeZoneOffset,
            LocalTime.ZENITH_OFFICIAL);
        mToday = today;
    }
    
    hidden function getToday() {
        var today = LocalTime.today();
        if (TEST_NOW_OFFSET != null) {
            var offsetSecs = TEST_NOW_OFFSET + (LocalTime.now().value() - mStartTime.value()); 
            today = today.add(new Time.Duration(86400 * (offsetSecs / 86400)));
        } 
        return today;
    } 
       
    hidden function getNow() {
        var now = LocalTime.now();
        if (TEST_NOW_OFFSET != null) {
            now = now.add(new Time.Duration(TEST_NOW_OFFSET));
        }
        return now;
    }
    
    hidden function getLatLng(info) {
        if (TEST_LAT_LNG != null) {
            return TEST_LAT_LNG;
        } 
        var location = info.currentLocation;
        if (location != null) {        
            return location.toDegrees();
        }
        return null;
    }
}