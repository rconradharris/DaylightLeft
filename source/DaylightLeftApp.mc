using Toybox.Application;

class DaylightLeftApp extends Application.AppBase {
    var mSunset = null;

    function initialize() {
        Application.AppBase.initialize();
    }

    function onStart(state) {
        Application.AppBase.onStart(state);
    }

    function onStop(state) {
        Application.AppBase.onStop(state);
    }

    function onSettingsChanged() {
        // Recompute sunset if settings changed...
        mSunset = null;
        Settings.invalidateCache();
    }

    function getInitialView() {
        return [ new DaylightLeftView() ];
    }
}