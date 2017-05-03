using Toybox.Math;
using Toybox.System;

module MathExtra {
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
}