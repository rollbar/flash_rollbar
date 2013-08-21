package com.rollbar.stacktrace {
    import flash.system.Capabilities;
    public class StackTrace {
        public var errorClassName:String = "";
        public var message:String = "";
        public var lines:Vector.<StackTraceLine>;
        public var srcPath:String;

        private var separator:String;
    
        public function StackTrace(srcPath:String) {
            this.srcPath = srcPath || "";
            lines = new Vector.<StackTraceLine>();
            if (this.srcPath && this.srcPath.charAt(0) == '/') {
                separator = '/';
            } else {
                separator = "\\";
            }
        }

        public function get frames():Array {
            var ret:Array = new Array();
            var filename:String;
            for each (var line:StackTraceLine in lines) {
                if (line.file.indexOf(srcPath) === -1) {
                    if (line.file.charAt(0) != separator && 
                            srcPath.charAt(srcPath.length - 1) != separator) {
                        srcPath = srcPath + separator;
                    }
                    filename = srcPath + line.file
                } else {
                    filename = line.file;
                }
                ret.splice(0, 0, {filename: filename,
                                  lineno: int(line.number),
                                  method: line.method,
                                  code: null});
            }
            return ret;
        }
    }
}
