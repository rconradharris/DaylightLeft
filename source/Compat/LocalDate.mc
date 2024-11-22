// Time.LocalMoment is CIQ >= 3.3.0
//
// The goal of DaylightLeft is to work with all possible devices, so we have to implement our own version
import Toybox.Lang;

using Toybox.System;
using Toybox.Time;

module Compat {

    module LocalDate {

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
        }

        function hereToday() as Date {
            var today = Time.today();
            var greg = Time.Gregorian.info(today, Time.FORMAT_SHORT);
            var timeZoneOffset = System.getClockTime().timeZoneOffset;

            return new Date({
                :year               => greg.year,
                :month              => greg.month,
                :day                => greg.day,
                :timeZoneOffset     => timeZoneOffset,
            });
        }

    }

}