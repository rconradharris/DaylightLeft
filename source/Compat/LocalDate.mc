// Time.LocalMoment is CIQ >= 3.3.0
//
// The goal of DaylightLeft is to work with all possible devices, so we have to implement our own version
import Toybox.Lang;

using Toybox.System;
using Toybox.Time;

using Utils;

module Compat {

    module LocalDate {

        const DEBUG_MODE = false;

        function DEBUG(msg as String) as Void {
            if (self.DEBUG_MODE) {
                PRINT(msg);
            }
        }

        function DEBUGF(format as String, params as Array) as Void {
            if (self.DEBUG_MODE) {
                PRINTF(format, params);
            }
        }

        class Date {

            public var year as Number;
            public var month as Number;
            public var day as Number;
            public var timeZoneOffset as Number;

            function initialize(options as { :year as Number, :month as Number, :day as Number, :timeZoneOffset as Number }) {
                self.year = options[:year];
                self.month = options[:month];
                self.day = options[:day];
                self.timeZoneOffset = options[:timeZoneOffset];
            }

            // Returns a Moment representing midnight for this 'LocalDate'
            function midnight() as Time.Moment {
                // The docs indicate that these values will be interpreted as
                // UTC. Since we're passing in midnight local time, this means
                // that we'll get a result will be offset by our timeZoneOffset.
                // To correct for that, we need to subtract that from the
                // resulting time.
                var utcMidnight = Time.Gregorian.moment({
                    :year       => self.year,
                    :month      => self.month,
                    :day        => self.day,
                    :hours      => 0,
                    :minutes    => 0,
                    :seconds    => 0,
                });

                var localMidnight = utcMidnight.subtract(new Time.Duration(self.timeZoneOffset));

                DEBUGF("LocalDate: localMidnight: $1$", [Utils.Time.iso8601(localMidnight)]);
                return localMidnight;
            }
        }

        // But gone tomorrow...
        function hereToday() as Date {
            var today = Time.today();
            var g = Time.Gregorian.info(today, Time.FORMAT_SHORT);
            var timeZoneOffset = System.getClockTime().timeZoneOffset;

            return new Date({
                :year               => g.year,
                :month              => g.month,
                :day                => g.day,
                :timeZoneOffset     => timeZoneOffset,
            });
        }

    }

}