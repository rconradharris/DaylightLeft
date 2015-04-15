using Toybox.Math;

module MathExtra {
	//! No floor() method on Float!
	function floor(x) {
		return x.toNumber();
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
	
	
	//! Return a float X modulo an integer y
	//! NOTE: this is needed because modulo is not supported for Float types
	function modFloat(x, y) {
		if (x >= y) {
			x -= y;
		} else if (x < 0.0) {
			x += y;
		}
		return x;
	}
	
	//! Return an angle modulo 360
	//! NOTE: this is needed because modulo is not supported for Float types
	function mod360(x) {
		if (x >= 360.0) {
			x -= 360.0;
		} else if (x < 0.0) {
			x += 360.0;
		}
		return x;
	}
}