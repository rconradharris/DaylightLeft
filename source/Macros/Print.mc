import Toybox.Lang;

using Toybox.Lang;
using Toybox.System;

function PRINT(msg as String) as Void {
    System.println(msg);
}

function PRINTF(format as String, params as Array) as Void {
    var msg = Lang.format(format, params);
    System.println(msg);
}