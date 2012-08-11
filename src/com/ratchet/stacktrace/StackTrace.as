package com.ratchet.stacktrace {
	public class StackTrace {
		public var title:String = "";
		public var message:String = "";
		public var lines:Vector.<StackTraceLine>;
	
		public function StackTrace() {
			lines = new Vector.<StackTraceLine>();
		}

        public function get frames():Array {
            var ret:Array = new Array();
            for each (var line:StackTraceLine in lines) {
                ret.push({filename: line.file,
                          lineno: int(line.number),
                          method: line.method,
                          code: null});
            }
            return ret;
        }
	}
}
