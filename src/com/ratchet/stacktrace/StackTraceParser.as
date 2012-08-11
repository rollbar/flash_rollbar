// Adapted from https://github.com/StephanPartzsch/as3-airbrake-notifier
package com.ratchet.stacktrace {
    public class StackTraceParser {
        public static function parseStackTrace(stackTraceString:String):StackTrace {
            var data:Array = stackTraceString.split("\tat ");
            var stackTrace:StackTrace = new StackTrace();

            parseErrorClassAndMessage(data.shift(), stackTrace);
            for (var i:int = 0; i < data.length; i++) {
                stackTrace.lines.push(parseStackTraceLine(data[i]));
            }

            return stackTrace;
        }

        private static function parseErrorClassAndMessage(input:String, stackTrace:StackTrace):void {
            var index:int = input.indexOf(": ");
            stackTrace.errorClassName = trim(input.substr(0, index));
            stackTrace.message = trim(input.substr(index + 2));
        }

        private static function parseStackTraceLine(lineString:String):StackTraceLine {
            var stackTraceLine:StackTraceLine = new StackTraceLine();

            var methodNameIndex:int = lineString.indexOf("/");
            var methodName:String = lineString.substr(methodNameIndex + 1);
            var debugIndex:int = methodName.indexOf("[");

            if (debugIndex == -1) {
                stackTraceLine.method = trim(methodName);
                stackTraceLine.number = "";

                var filePath:String = lineString.substr(0, methodNameIndex);
                filePath = filePath.replace(/\./g, '/').replace('::', '/') + '.as';
                stackTraceLine.file = filePath;
            } else {
                var colonPos:int = methodName.lastIndexOf(":");
                var lastBracketPos:int = methodName.lastIndexOf("]");
                stackTraceLine.method = methodName.substr(0, debugIndex);
                stackTraceLine.number = methodName.substring(colonPos + 1, lastBracketPos);
                stackTraceLine.file = methodName.substring(debugIndex + 1, colonPos);
            }

            return stackTraceLine;
        }

        // http://jeffchannell.com/ActionScript-3/as3-trim.html
        public static function trim(s:String):String {
            return s ? s.replace(/^\s+|\s+$/gs, '') : ""; 
        }
    }
}
