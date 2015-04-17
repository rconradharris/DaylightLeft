using UnitTest;
using Toybox.Math;

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

    // Returns a `Number` representing the modulo of two `Float` inputs.
    //
    // The builtin modulo operator % only works for integers. This function
    // provides the same functionality for Floats.
	function modFloat(x, y) {
        //return x - (floor(x / y) * y);
		if (x >= y) {
			x -= y;
		} else if (x < 0.0) {
			x += y;
		}
		return x;
	}

    // Start Tests (comment these out before building production version)
    class FloorTestCase extends TestCase {
        var testRegistry = {
            :testNegative   => "testNegative",
            :testPositive   => "testPositive",
            :testZero       => "testZero"
        };
        function testNegative() {
            var actual = floor(-1.1);
            UnitTest.Assert.areEqual({:expected => -2.0,
                                      :actual => actual});
        }
        function testPositive() {
            var actual = floor(1.1);
            UnitTest.Assert.areEqual({:expected => 1.0,
                                      :actual => actual});
        }
        function testZero() {
            var actual = floor(0.0);
            UnitTest.Assert.areEqual({:expected => 0.0,
                                      :actual => actual});
        }
    }
    function runTests() {
        new FloorTestCase().runTests();
    }
}