# Daylight Left

![Daylight Left on a Forerunner 955](https://github.com/rconradharris/DaylightLeft/blob/master/assets/images/Forerunner955.jpeg)

Daylight Left is a data field for Garmin watches and bike computers that shows
how much light is left in the day.

You might use it to figure out if you should cut an activity short to, for
example, return to your car.

Daylight Left is available in the Garmin [ConnectIQ
Store](https://apps.garmin.com/en-US/apps/0a593392-4ea8-4963-9b9f-2c464338e87b)

## Settings

![Settings on Phone](https://github.com/rconradharris/DaylightLeft/blob/master/assets/images/Settings%20GIF/Frames/Settings.jpeg)

By default, Daylight Left will use sunset as its reference point. However, in
practice, there's plenty of usable daylight left immediately after sunset.

To account for that, Daylight Left includes a setting, togglable from the
ConnectIQ app on your phone, that allow you to use 'Twilight' and 'Dark' as
reference points. These settings map to "civil" and "astronomical" sunsets,
which interestingly, have precise definitions based on how far below the
horizon the sun is.

## Technical Details

Daylight Left is written in "Monkey C" for the
[ConnectIQ](https://developer.garmin.com/connect-iq/overview/) platform.

It uses an algorithm published by the National Almanac Office of the United
States Naval Observatory sourced from
[here](https://web.archive.org/web/20160315083337/http://williams.best.vwh.net/sunrise_sunset_algorithm.htm)

## License

[MIT](https://opensource.org/license/mit)
