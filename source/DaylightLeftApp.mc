//using MathExtra;
using Toybox.Application as App;

class DaylightLeftApp extends App.AppBase {

    //! onStart() is called on application start up
    function onStart() {
        // NOTE: before building a production binary, be sure to comment out
        // all of the UnitTest code to keep the binary small
        //MathExtra.runTests();
    }

    //! onStop() is called when your application is exiting
    function onStop() {
    }

    //! Return the initial view of your application here
    function getInitialView() {
        return [ new DaylightLeftView() ];
    }

}