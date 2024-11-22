import Toybox.Lang;

using Toybox.Application;
using Toybox.Application.Properties as Properties;

module Settings {

    const SETTING_ZENITH = "zenith";

    var _cache as Dictionary<Application.PropertyKeyType, Application.PropertyValueType> = {};

    enum {
        ZENITH_OFFICIAL     = 0,
        ZENITH_CIVIL        = 1,
        ZENITH_NAUTICAL     = 2,
        ZENITH_ASTRONOMICAL = 3,
    }

    function getZenith() as Float {
        var zenith = self._getCachedProperty(SETTING_ZENITH);

        switch (zenith) {
        case ZENITH_CIVIL:          return LocalTime.ZENITH_CIVIL;
        case ZENITH_NAUTICAL:       return LocalTime.ZENITH_NAUTICAL;
        case ZENITH_ASTRONOMICAL:   return LocalTime.ZENITH_ASTRONOMICAL;
        }

        return LocalTime.ZENITH_OFFICIAL;
    }

    function _getCachedProperty(key as Application.PropertyKeyType) as Application.PropertyValueType {
        if (self._cache.hasKey(key)) {
            // Hit
            return self._cache[key];
        }
        // Miss
        var x = self._getProperty(key);
        self._cache[key] = x;
        return x;
    }

    function _getProperty(key as Application.PropertyKeyType) as Application.PropertyValueType {
        if (Properties has :getValue) {
            // CIQ >= 2.4
            return Properties.getValue(key);
        }

        // Old, deprecated method
        var app = Application.getApp();
        return app.getProperty(key);
    }

    function invalidateCache() as Void {
        self._cache = {};
    }


}