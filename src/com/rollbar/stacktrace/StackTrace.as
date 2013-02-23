package com.rollbar.stacktrace {
    public class StackTrace {
        public var errorClassName:String = "";
        public var message:String = "";
        public var lines:Vector.<StackTraceLine>;
        public var srcPath:String = null;
    
        public function StackTrace(srcPath:String) {
            this.srcPath = srcPath;
            if (this.srcPath) {
                this.srcPath += "/";
            } else {
                this.srcPath = "";
            }
            lines = new Vector.<StackTraceLine>();
        }

        public function get frames():Array {
            var ret:Array = new Array();
            for each (var line:StackTraceLine in lines) {
                ret.splice(0, 0, {filename: srcPath + line.file,
                                  lineno: int(line.number),
                                  method: line.method,
                                  code: null});
            }
            return ret;
        }
    }
}
