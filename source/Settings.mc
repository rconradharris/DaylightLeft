import Toybox.Lang;

using Toybox.Application;
using Toybox.Application.Properties as Properties;

module Settings {

    const DEBUG_MODE = false;

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
        case ZENITH_CIVIL:          return Sun.ZENITH_CIVIL;
        case ZENITH_NAUTICAL:       return Sun.ZENITH_NAUTICAL;
        case ZENITH_ASTRONOMICAL:   return Sun.ZENITH_ASTRONOMICAL;
        }

        return Sun.ZENITH_OFFICIAL;
    }

    function _getCachedProperty(key as Application.PropertyKeyType) as Application.PropertyValueType {
        if (self._cache.hasKey(key)) {
            // Hit
            DEBUGF("settings: cache hit key=$1$", [key]);
            return self._cache[key];
        }
        // Miss
        DEBUGF("settings: cache miss key=$1$", [key]);
        var x = self._getProperty(key);
        self._cache[key] = x;
        return x;
    }

    function _getProperty(key as Application.PropertyKeyType) as Application.PropertyValueType {
        if (Properties has :getValue) {
            // CIQ >= 2.4
            DEBUGF("settings: prop get new method key=$1$", [key]);
            return Properties.getValue(key);
        }

        // Old, deprecated method
        DEBUGF("settings: prop get old method key=$1$", [key]);
        var app = Application.getApp();
        return app.getProperty(key);
    }

    function invalidateCache() as Void {
        DEBUG("settings: invalidating cache");
        self._cache = {};
    }

    function DEBUG(msg as String) as Void {
        if (self.DEBUG_MODE) {
            PRINT(msg);
        }
    }

    function DEBUGF(format as String, params as Array) as Void {
        if (self.DEBUG_MODE) {
            PRINTF(format, params);
        }
    }

}