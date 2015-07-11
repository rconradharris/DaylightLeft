//using Toybox.System;
//
//// FIXME: Inheritance appears to be broken in Monkey C. I can't inherit from a
//// class that's defined within a module, like UnitTest.TestCase. (I don't know
//// why it works for built-in classes). To work around this, TestCase is a global :(
//
//class TestCase {
//    hidden var mTestFailureCount = 0;
//    hidden var mTestCount = 0;
//
//    // Test Registery
//    //
//    // Any tests you create need to be registered here so that the test
//    // runner can find them.
//    //
//    // The key is a Symbol that matches the name of the test function and
//    // the value is a string that matches the name. The duplication is
//    // required because Monkey C does not provide a way from going back
//    // and forth from Strings to Symbols (unlike Ruby).
//    var testRegistry = {
//        //:testSomething => "testSomething"
//    };
//
//    function setUp() {
//        // Override with your setUp code
//    }
//
//    function tearDown() {
//        // Override with your tearDown code
//    }
//
//    hidden function runTest(testId, testName) {
//        UnitTest.Assert.resetFailures();
//        mTestCount += 1;
//        System.println("=== Running test: " + testName + " ===");
//        setUp();
//        try {
//            method(testId).invoke();
//        } finally {
//            tearDown();
//        }
//        if (UnitTest.Assert.anyFailures()) {
//            System.println("=== [FAILURE] " + testName + " ===");
//            mTestFailureCount += 1;
//        } else {
//            System.println("=== [OK] " + testName + " ===");
//        }
//    }
//
//    function runTests() {
//        var testIds = testRegistry.keys();
//        for(var i = 0; i < testRegistry.size(); i += 1)  {
//            var testId = testIds[i];
//            var testName = testRegistry[testId];
//            runTest(testId, testName);
//        }
//        if (mTestFailureCount > 0) {
//            System.println(mTestFailureCount + " failures detected");
//        } else {
//            System.println(mTestCount + " tests succeeded");
//        }
//    }
//}
//
module UnitTest {
//    module Assert {
//        // Exception handling doesn't work at the moment so assertions won't
//        // throw AssertionError objects, instead they'll set a global failure
//        // flag. This means that for now, tests do not stop at the first
//        // assertion failure either.
//
//        hidden var mAssertionFailures = false;
//        function resetFailures() {
//            mAssertionFailures = false;
//        }
//        function anyFailures() {
//            return mAssertionFailures;
//        }
//        hidden function handleFailure(expected, actual, message) {
//            var msg = "Assertion Error: [expected=" + expected + " actual=" + actual + "]";
//            if (message) {
//                msg += ": " + message;
//            }
//            System.println(msg);
//            mAssertionFailures = true;
//        }
//        // Assert that two values are equal
//        //
//        // Options hash:
//        //      expected - expected value
//        //      actual - actual value
//        //      message - optional message to include
//        function areEqual(options) {
//            var expected = options[:expected];
//            var actual = options[:actual];
//            if (expected != actual) {
//                handleFailure(expected, actual, options[:message]);
//            }
//        }
//        
//        
//        // Assert that two values are almost equal
//        //
//        // Options hash:
//        //      expected - expected value
//        //      actual - actual value
//        //      message - optional message to include
//        //      delta - difference allowed (default: +/- 0.00001)
//        function areAlmostEqual(options) {
//            var expected = options[:expected];
//            var actual = options[:actual];
//            var delta = options[:delta];
//            if (delta == null) {
//                delta = 0.00001;
//            }
//            
//            var actualDelta = (expected - actual).abs();
//            
//            if (actualDelta > delta.abs()) {
//                handleFailure(expected, actual, options[:message]);
//            }
//        }
//    }
}