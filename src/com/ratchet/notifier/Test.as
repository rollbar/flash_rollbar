package com.ratchet.notifier {
    import flash.display.Sprite;
    import flash.text.TextField;
    import flash.text.TextFormat;
    import flash.text.TextFormatAlign;
    import flash.events.*;

    import com.ratchet.notifier.RatchetNotifier;

    public class Test extends Sprite {
        // change to your own access token
        public static const ACCESS_TOKEN:String = '943224be7ef5455aabd577208abc58ed';
        public static const ENV:String = 'cory-dev';

        protected var button:Sprite = new Sprite();
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

            button.graphics.clear();
            button.graphics.beginFill(0xD4D4D4);
            button.graphics.drawRoundRect(0, 100, 200, 50, 20, 20);
            button.graphics.endFill();
            addChild(button);

            var format:TextFormat = new TextFormat();
            format.size = 20;

            var errTxt:TextField = new TextField();
            errTxt.defaultTextFormat = format;
            errTxt.text = 'Cause Error';
            errTxt.x = 10;
            errTxt.y = 105;
            errTxt.selectable = false;
            button.addChild(errTxt);

            button.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
        }

        private function mouseDownHandler(event:MouseEvent):void {
            uselessIndirection();
        }

        private function uselessIndirection():void {
            try {
                throw new Error('dummy');
            } catch (e:Error) {
                notifier.handleError(e);
            }
        }
    }
}
