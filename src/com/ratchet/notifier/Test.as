package com.ratchet.notifier {
    import flash.display.Sprite;
    import flash.text.TextField;
    import flash.events.*;

    import com.ratchet.notifier.RatchetNotifier;

    public class Test extends Sprite {
        // change to your own access token
        public static const ACCESS_TOKEN:String = '943224be7ef5455aabd577208abc58ed';
        public static const ENV:String = 'cory-dev';

        protected var button:Sprite = new Sprite();
        protected var notifier:RatchetNotifier;

        public function Test() {

            notifier = new RatchetNotifier(ACCESS_TOKEN, ENV);
            addChild(notifier);

            var helloTxt:TextField = new TextField();
            helloTxt.text = 'Hello World';
            addChild(helloTxt);

            var errTxt:TextField = new TextField();
            button.graphics.clear();
            button.graphics.beginFill(0xD4D4D4);
            button.graphics.drawRoundRect(0, 0, 80, 25, 10, 10);
            button.graphics.endFill();
            errTxt.text = 'Cause Error';
            errTxt.x = 10;
            errTxt.y = 5;
            errTxt.selectable = false;
            button.addChild(errTxt);

            addChild(button);

            button.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
        }

        private function mouseDownHandler(event:MouseEvent):void {
            try {
                throw new Error('dummy');
            } catch (e:Error) {
                notifier.handleError(e);
            }
        }
    }
}
