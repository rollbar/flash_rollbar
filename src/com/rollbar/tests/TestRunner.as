package com.rollbar.tests {
    import flash.display.Sprite;

    import org.flexunit.internals.TraceListener;
    import org.flexunit.runner.FlexUnitCore;

    import com.rollbar.tests.StackTraceParserTest;

    import com.rollbar.notifier.Rollbar;

    public class TestRunner extends Sprite {
        private var core:FlexUnitCore;

        public function TestRunner() {
            super();
            
            Rollbar.init(this, 'aaaabbbbccccddddeeeeffff00001111', 'production');
            
            core = new FlexUnitCore();
            core.addListener(new TraceListener());
            core.run(StackTraceParserTest);
        }
    }
}