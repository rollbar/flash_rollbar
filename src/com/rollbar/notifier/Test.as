package com.rollbar.notifier {
    import flash.display.Sprite;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;
    import flash.text.TextFormatAlign;
    import flash.events.*;

    import com.rollbar.notifier.Rollbar;

    public class Test extends Sprite {
        // change to your own access token
        public static const ACCESS_TOKEN:String = '2f5ce4c49aec41c2bba8c3c5c448f8b2';
        public static const ENV:String = 'production';

        protected var caughtButton:Sprite = new Sprite();
        protected var uncaughtButton:Sprite = new Sprite();

        public function Test() {
            trace('Building Rollbar test...');

            // Initialize the Rollbar notifier.
            Rollbar.init(this,  // pass this sprite as first param
                ACCESS_TOKEN,  // your rollbar project access token
                ENV,  // environment name - i.e. "production" or "development"
                function():Object {
                    return {user_id: "user123", name: "Cory Virok"}
                },  // user fn/id (optional).
                "/Users/coryvirok/Development/flash_rollbar",  // the path to the project root, 
                    // not including the final slash.
                    // Note: if the SWF/SWC is compiled with compiler.verbose-stacktraces=true
                    // or -debug, you'll want to have this path reflect the root path from the
                    // user who published the SWF/SWC file. Otherwise, you can set it to the
                    // source directory of your project, e.g. "src".
                "/Users/coryvirok/Development/flash_rollbar/src"  // the source code path
            );

            mouseEnabled = true;
            mouseChildren = true;

            // Draw some buttons.

            caughtButton.graphics.clear();
            caughtButton.graphics.beginFill(0xD4D4D4);
            caughtButton.graphics.drawRoundRect(0, 100, 200, 50, 20, 20);
            caughtButton.graphics.endFill();
            addChild(caughtButton);

            uncaughtButton.graphics.clear();
            uncaughtButton.graphics.beginFill(0xD4D4D4);
            uncaughtButton.graphics.drawRoundRect(0, 200, 200, 50, 20, 20);
            uncaughtButton.graphics.endFill();
            addChild(uncaughtButton);

            var format:TextFormat = new TextFormat();
            format.size = 20;

            var format2:TextFormat = new TextFormat();
            format2.size = 20;

            var caughtErrText:TextField = new TextField();
            caughtErrText.defaultTextFormat = format;
            caughtErrText.autoSize = TextFieldAutoSize.RIGHT;
            caughtErrText.text = 'Cause Error';
            caughtErrText.x = 10;
            caughtErrText.y = 105;
            caughtErrText.selectable = false;
            caughtButton.addChild(caughtErrText);

            var uncaughtErrText:TextField = new TextField();
            uncaughtErrText.defaultTextFormat = format2;
            uncaughtErrText.autoSize = TextFieldAutoSize.RIGHT;
            uncaughtErrText.text = 'Cause Uncaught Error';
            uncaughtErrText.x = 10;
            uncaughtErrText.y = 205;
            uncaughtErrText.selectable = false;
            uncaughtButton.addChild(uncaughtErrText);

            caughtButton.addEventListener(MouseEvent.MOUSE_DOWN, caughtMouseDownHandler);
            uncaughtButton.addEventListener(MouseEvent.MOUSE_DOWN, uncaughtMouseDownHandler);
        }

        private function caughtMouseDownHandler(event:MouseEvent):void {
            try {
                trace('causing error within try/catch');
                causeError();
            } catch (e:Error) {
                trace('caught error within try/catch');
                Rollbar.handleError(e);
            }
        }

        private function uncaughtMouseDownHandler(event:MouseEvent):void {
            trace('caught uncaught error');
            causeError();
        }

        private function causeError():void {
            throw new Error('dummy');
        }
    }
}
