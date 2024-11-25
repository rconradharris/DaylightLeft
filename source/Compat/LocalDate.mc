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

            function toString() as String {
                return Lang.format("$1$-$2$-$3$,tz=$4$", [
                    self.year.format("%04d"),
                    self.month.format("%02d"),
                    self.day.format("%02d"),
                    self.timeZoneOffset,
                ]);
            }

        }

        function fromMoment(m as Time.Moment) as Date {
            // `Gregorian.info` converts to local time; however
            // `Gregorian.moment` expects time to be UTC
            //
            // What this means is that LocalDate and Moments don't roundtrip
            // neatly between each other, i.e. assume midnight=Time.today() and
            // your timezone != UTC, then
            // Gregorian.moment(localDate.fromMoment(midnight)) != midnight.
            var g = Time.Gregorian.info(m, Time.FORMAT_SHORT);
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