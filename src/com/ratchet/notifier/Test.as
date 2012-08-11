package com.ratchet.notifier {
    import flash.display.Sprite;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;
    import flash.text.TextFormatAlign;
    import flash.events.*;

    import com.ratchet.notifier.RatchetNotifier;

    public class Test extends Sprite {
        // change to your own access token
        public static const ACCESS_TOKEN:String = '943224be7ef5455aabd577208abc58ed';
        public static const ENV:String = 'cory-dev';

        protected var caughtButton:Sprite = new Sprite();
        protected var uncaughtButton:Sprite = new Sprite();
        protected var notifier:RatchetNotifier;

        public function Test() {

            // Instantiate the notifier.
            // Params:
            //  access token
            //  the environment your code is running from, e.g. "production"
            //  the user's IP, (which you'll probably need to pass in via a
            //      flashvar or use ExternalInterface to grab it from a 
            //      javascript variable)
            //  the path to the application code root, not including the final slash
            //      Note: if the SWF/SWC is compiled with compiler.verbose-stacktraces=true
            //      or -debug, you'll want to have this path reflect the root path from the
            //      person who published the SWF/SWC file. Otherwise, you can set it to the
            //      source directory of your project, e.g. "src".
            notifier = new RatchetNotifier(ACCESS_TOKEN,
                                           ENV,
                                           "68.126.176.252",
                                           "/Users/coryvirok/Development/flash_ratchet/src");
            addChild(notifier);

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
                notifier.handleError(e);
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
