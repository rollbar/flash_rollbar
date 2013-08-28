package com.rollbar.notifier {

    import flash.display.DisplayObjectContainer;
    import flash.events.ErrorEvent;

    import com.rollbar.notifier.RollbarNotifier;

    /**
     * Static wrapper around a RollbarNotifier singleton.
     *
     * Use this unless you have some specific reason to use RollbarNotifer directly.
     */
    public final class Rollbar {

        private static var notifier:RollbarNotifier = null;

        /**
         * Initialize the Rollbar notifier. Constructs a RollbarNotifier instance and adds it to the stage,
         * which will trigger final initialization.
         * All arguments after 'stage' are passed to RollbarNotifier's constructor.
         *
         * @param stage The stage
         * @param accessToken Rollbar project access token
         * @param environment Environment name (i.e. "development", "production")
         * @param person Person identifier string or object or function which returns an object.
         * @param rootPath Path to the application code root, not including the final slash.
         * @param srcPath Path to the source code root, not including the final slash.
         * @param codeBranch Code branch name, e.g. "master"
         * @param serverData Object containing server information, will be passed along with error reports
         * @param maxItemCount Max number of items to report per load.
         */
        public static function init(parent:DisplayObjectContainer,
            accessToken:String, environment:String, person:* = null,
            rootPath:String = null, srcPath:String = null,
            codeBranch:String = null, serverData:Object = null,
            maxItemCount:int = 5, endpointUrl:String = null):void {

            if (notifier !== null) {
                trace("WARNING: Rollbar.init() called more than once. Subsequent calls ignored.");
                return;
            }
            
            notifier = new RollbarNotifier(accessToken, environment, person, rootPath, srcPath,
                    codeBranch, serverData, maxItemCount, endpointUrl);
            parent.addChild(notifier);
        }
        
        public static function handleError(err:Error, extraData:Object = null):void {
            if (notifier === null) {
                trace("WARNING: Rollbar.handleError() called before init(). Call ignored.");
                return;
            }
            notifier.handleError(err, extraData);
        }

        public static function handleErrorEvent(event:ErrorEvent):void {
            if (notifier === null) {
                trace("WARNING: Rollbar.handleErrorEvent() called before init(). Call ignored.");
                return;
            }
            notifier.handleErrorEvent(event);
        }

        public static function handleOtherEvent(event:*):void {
            if (notifier === null) {
                trace("WARNING: Rollbar.handleOtherEvent() called before init(). Call ignored.");
                return;
            }
            notifier.handleOtherEvent(event);
        }
        
    }
}
