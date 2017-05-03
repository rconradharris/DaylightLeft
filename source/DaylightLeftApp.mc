using Toybox.Application;

class DaylightLeftApp extends Application.AppBase {

    function initialize() {
        Application.AppBase.initialize();
    }

    function onStart(state) {
        Application.AppBase.onStart(state);
    }

    function onStop(state) {
        Application.AppBase.onStop(state);
    }

    function getInitialView() {
        return [ new DaylightLeftView() ];
    }
}