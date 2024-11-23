import Toybox.Lang;

using Toybox.Application;
using Toybox.Application.Storage;

module Compat {

    module PropStore {

        const DEBUG_MODE = false;

        function get(key as Application.PropertyKeyType) as Application.PropertyValueType {
            if (Storage has :getValue) {
                DEBUGF("PropStore.get [new method]: key=$1$", [key]);
                return Storage.getValue(key);
            }

            DEBUGF("PropStore.get [old method]: key=$1$", [key]);
            var app = Application.getApp();
            return app.getProperty(key);
        }

        function set(key as Application.PropertyKeyType, value as Application.PropertyValueType) as Void {
            if (Storage has :setValue) {
                DEBUGF("PropStore.set [new method]: key=$1$", [key]);
                Storage.setValue(key, value);
                return;
            }

            DEBUGF("PropStore.set [old method]: key=$1$", [key]);
            var app = Application.getApp();
            app.setProperty(key, value);
        }

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


    }


}