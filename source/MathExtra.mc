//using UnitTest;
using Toybox.Math;
using Toybox.System;

module MathExtra {
	// Returns a Float representing the floor of a number
    function floor(x) {
        var truncated = x.toNumber().toFloat();
        return (x < 0) ? truncated - 1: truncated;
	}
	
	//! Return sine where x is in degrees
	function sinD(x) {
		return Math.sin(Math.PI / 180 * x);
	}
	
	//! Return cosine where x is in degrees
	function cosD(x) {
		return Math.cos(Math.PI / 180 * x);
	}
	
	//! Return tangent where x is in degrees
	function tanD(x) {
		return Math.tan(Math.PI / 180 * x);
	}
	
	//! Return arcsine in degrees
	function asinD(x) {
		return (180 / Math.PI) * Math.asin(x);
	}
	
	//! Return arcosine in degrees
	function acosD(x) {
		return (180 / Math.PI) * Math.acos(x);
	}
	
	//! Return artangent in degrees
	function atanD(x) {
		return (180 / Math.PI) * Math.atan(x);
	}

    // Returns a `Number` representing the modulus of two `Float` inputs.
    //
    // The builtin modulo operator % only works for integers. This function
    // provides the same functionality for Floats.
	function fmod(dividend, divisor) {
        var n = (dividend / divisor).toNumber();
        return dividend - (n * divisor);
	}

    // Returns a `Number` representing the positive modulus of two `Float` inputs.
    //
    // For example fmod(-1, 24) is -1, but fmodPositive(-1, 24) is 23.
    function fmodPositive(dividend, divisor) {
        var val = fmod(dividend, divisor);
        if (val < 0) {
            val += divisor;
        }
        //System.println("dividend=" + dividend.toString() + " divisor=" + divisor.toString() + " val= " + val.toString());
        return val;
    }
    
    // Start Tests (comment these out before building production version)
    //class FloorTestCase extends TestCase {
    //    var testRegistry = {
    //        :testNegative   => "testNegative",
    //        :testPositive   => "testPositive",
    //        :testZero       => "testZero"
    //    };
    //    function testNegative() {
    //        var actual = floor(-1.1);
    //        UnitTest.Assert.areEqual({:expected => -2.0,
    //                                  :actual => actual});
    //    }
    //    function testPositive() {
    //        var actual = floor(1.1);
    //        UnitTest.Assert.areEqual({:expected => 1.0,
    //                                  :actual => actual});
    //    }
    //    function testZero() {
    //        var actual = floor(0.0);
    //        UnitTest.Assert.areEqual({:expected => 0.0,
    //                                  :actual => actual});
    //    }
    //}
    //class FmodTestCase extends TestCase {
    //    var testRegistry = {
    //        :testPositiveDividendPositiveDivisor   => "testPositiveDividendPositiveDivisor",
    //        :testNegativeDividendPositiveDivisor   => "testNegativeDividendPositiveDivisor",
    //        :testPositiveDividendNegativeDivisor   => "testPositiveDividendNegativeDivisor",
    //        :testNegativeDividendNegativeDivisor   => "testNegativeDividendNegativeDivisor"
    //    };
    //    function testPositiveDividendPositiveDivisor() {
    //        var actual = fmod(+5.1, +3.0);
    //        UnitTest.Assert.areEqual({:expected => 2.1,
    //                                  :actual => actual});
    //    }
    //    function testNegativeDividendPositiveDivisor() {
    //        var actual = fmod(-5.1, +3.0);
    //        UnitTest.Assert.areEqual({:expected => -2.1,
    //                                  :actual => actual});
    //    }
    //    function testPositiveDividendNegativeDivisor() {
    //        var actual = fmod(+5.1, -3.0);
    //        UnitTest.Assert.areEqual({:expected => 2.1,
    //                                  :actual => actual});
    //    }
    //    function testNegativeDividendNegativeDivisor() {
    //        var actual = fmod(-5.1, -3.0);
    //        UnitTest.Assert.areEqual({:expected => -2.1,
    //                                  :actual => actual});
    //    }
    //}
    //class FmodPositiveTestCase extends TestCase {
    //    var testRegistry = {
    //        :testPositiveDividendPositiveDivisor   => "testPositiveDividendPositiveDivisor",
    //        :testNegativeDividendPositiveDivisor   => "testNegativeDividendPositiveDivisor"
    //    };
    //    function testPositiveDividendPositiveDivisor() {
    //        var actual = fmodPositive(27.1, 24.0);
    //        UnitTest.Assert.areAlmostEqual({:expected => 3.1,
    //                                        :actual => actual});
    //    }
    //    function testNegativeDividendPositiveDivisor() {
    //        var actual = fmodPositive(-1.0, 24.0);
    //        UnitTest.Assert.areAlmostEqual({:expected => 23.0,
    //                                        :actual => actual});
    //    }
    //}
    //function runTests() {
    //    new FloorTestCase().runTests();
    //    new FmodTestCase().runTests();
    //    new FmodPositiveTestCase().runTests();
    //}
}