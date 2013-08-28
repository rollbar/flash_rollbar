// Adapted from https://github.com/StephanPartzsch/as3-airbrake-notifier
package com.rollbar.stacktrace {
    public class StackTraceParser {
        public static function parseStackTrace(srcPath:String, stackTraceString:String):StackTrace {
            var data:Array = stackTraceString.split("\tat ");
            var stackTrace:StackTrace = new StackTrace(srcPath);

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
            
            // Grab method name by looking from either ':' or '/' up to and including '()'
            var methodPat:RegExp = /[:|\/]([\w<>]+\(\))/;
            var methodName:String = methodPat.exec(lineString)[1];
            
            stackTraceLine.method = methodName;
            
            // Grab debug file path if it exists by looking from a '[' to a ':'
            var filePath:String;
            var debugFilePat:RegExp = /\[([\w\/\.]+):/;
            var debugFilePatMatch:Object = debugFilePat.exec(lineString);
            if (debugFilePatMatch) {
                filePath = debugFilePatMatch[1];
            }
            
            if (filePath) { // Debug line with file path and line number
                var linePat:RegExp = /:(\d+)\]/;
                var lineNumber:String = linePat.exec(lineString)[1];
                
                stackTraceLine.number = lineNumber;
                stackTraceLine.file = filePath;
            } else { // Non-debug line with no file path and no line number
                var filePat:RegExp = /([\w\.:]+)[\(|\/]/;
                filePath = filePat.exec(lineString)[1];
                
                stackTraceLine.number = "";
                stackTraceLine.file = filePath.replace(/[\.|::]/g, '/') + '.as';
            }

            return stackTraceLine;
        }

        // http://jeffchannell.com/ActionScript-3/as3-trim.html
        public static function trim(s:String):String {
            return s ? s.replace(/^\s+|\s+$/gs, '') : ""; 
        }
    }
}
