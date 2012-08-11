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

            notifier = new RatchetNotifier(ACCESS_TOKEN, ENV);
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
