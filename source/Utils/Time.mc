import Toybox.Lang;

using Toybox.Time;
using Toybox.Time.Gregorian;

module Utils {

    module Time {

        function iso8601(m as Time.Moment) as String {
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