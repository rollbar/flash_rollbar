package com.rollbar.tests {
    import flash.display.Sprite;

    import flash.events.Event;
    import flash.events.ErrorEvent;
    import flash.events.EventDispatcher;
    import flash.events.HTTPStatusEvent;
    import flash.events.IOErrorEvent;
    import flash.events.IEventDispatcher;
    import flash.events.SecurityErrorEvent;
    import flash.events.UncaughtErrorEvent;
    
    import org.flexunit.Assert;
    import org.flexunit.async.Async;
    
    import com.rollbar.tests.ErrorCausingConstructorClass;
    import com.rollbar.stacktrace.StackTrace;
    import com.rollbar.stacktrace.StackTraceParser;
    
    public class StackTraceParserTest {
        [BeforeClass]
        public static function runBeforeClass():void {
        } 
        
        [Before]
        public function before():void {
        }
        
        [After]  
        public function runAfterEveryTest():void {
        }
        
        [Test]  
        public function testNormalFrame():void {
            try {
                causeError();
            } catch (e:Error) {
                var frames:Array = getFrames(e);
                var lastFrame:Object = frames[frames.length - 1];
                
                Assert.assertTrue(lastFrame.filename.indexOf('StackTraceParserTest.as') != -1);
                Assert.assertTrue(lastFrame.method == 'causeError()');
            }
        }
        
        [Test]
        public function testConstructorFrame():void {
            try {
                new ErrorCausingConstructorClass();
            } catch (e:Error) {
                var frames:Array = getFrames(e);
                var lastFrame:Object = frames[frames.length - 1];
                
                Assert.assertTrue(lastFrame.filename.indexOf('ErrorCausingConstructorClass.as') != -1);
                Assert.assertTrue(lastFrame.method == 'ErrorCausingConstructorClass()');
            }
        }
        
        [Test]  
        public function testAnonymousFrame():void {
            var func:Function = function():void {
                try {
                    causeError();
                } catch (e:Error) {
                    var frames:Array = getFrames(e);
                    var lastFrame:Object = frames[frames.length - 1];
                    
                    Assert.assertTrue(lastFrame.filename.indexOf('StackTraceParserTest.as') != -1);
                    Assert.assertTrue(lastFrame.method == 'causeError()');
                }
            }
            
            func();
        }
        
        protected function causeError():void {
            throw new Error('dummy');
        }
        
        protected function getFrames(error:Error):Array {
            var stackTraceString:String = error.getStackTrace();
            var stackTraceObj:StackTrace = StackTraceParser.parseStackTrace(null, stackTraceString);
            return stackTraceObj.frames;
        }
    }
}