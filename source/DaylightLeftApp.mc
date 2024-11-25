import Toybox.Lang;

using Toybox.Application;
using Toybox.Time;

class DaylightLeftApp extends Application.AppBase {

    private var mSunset as Time.Moment? = null;

    function initialize() {
        Application.AppBase.initialize();
        self.mSunset = null;
    }

    function onStart(state) {
        Application.AppBase.onStart(state);
    }

    function onStop(state) {
        Application.AppBase.onStop(state);
    }

    function onSettingsChanged() {
        // Recompute sunset if settings changed...
        self.mSunset = null;

        Settings.invalidateCache();
    }

    function setCachedSunset(m as Time.Moment) as Void {
        self.mSunset = m;
    }

    function getCachedSunset() as Time.Moment? {
        return self.mSunset;
    }

    function getInitialView() {
        return [ new DaylightLeftView() ];
    }
}