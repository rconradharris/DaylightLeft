import Toybox.Lang;

using Toybox.Time;
using Toybox.Time.Gregorian;

module Utils {

    module Time {

        enum Format {
            FORMAT_ISO_8601,
        }

        function format(m as Time.Moment, format as Format) {
            switch (format) {
            case FORMAT_ISO_8601: return _format_iso8601(m);
            }

            return Consts.MISSING;
        }

        function _format_iso8601(m as Time.Moment) as String {
            var g = Time.Gregorian.info(m, Time.FORMAT_SHORT);

            return Lang.format("$1$-$2$-$3$ $4$:$5$:$6$", [
                g.year.format("%04d"),
                g.month.format("%02d"),
                g.day.format("%02d"),
                g.hour.format("%02d"),
                g.min.format("%02d"),
                g.sec.format("%02d"),
            ]);
        }

    }

}