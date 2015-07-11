using Toybox.Application as App;

class DaylightLeftApp extends App.AppBase {
    function onStart() {
        // NOTE: before building a production binary, be sure to comment out
        // all of the UnitTest code to keep the binary small
        //MathExtra.runTests();
    }

    function onStop() {
    }

    function getInitialView() {
        return [ new DaylightLeftView() ];
    }

}