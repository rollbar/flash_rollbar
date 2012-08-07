package com.ratchet.notifier {

    import flash.errors.IllegalOperationError;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.HTTPStatusEvent;
    import flash.events.IOErrorEvent;
    import flash.events.SecurityErrorEvent;

    import flash.net.URLLoader;
    import flash.net.URLLoaderDataFormat;
    import flash.net.URLRequest;
    import flash.net.URLRequestMethod;

    import flash.system.Capabilities;

    import com.ratchet.json.JSON;
    
    [Event(name="complete", type="flash.events.Event")]
    [Event(name="httpStatus", type="flash.events.HTTPStatusEvent")]
    [Event(name="ioError", type="flash.events.IOErrorEvent")]
    [Event(name="securityError", type="flash.events.SecurityErrorEvent")]
    public class RatchetNotifier extends EventDispatcher {

        private static const API_ENDPONT_URL:String = "https://submit.ratchet.io/api/1/item/";
        private static const NOTIFIER_DATA:String = {name: "flash_ratchet", version: 1.0};
        private static const MAX_ITEM_COUNT:int = 5;

        private static instance:RatchetNotifier = null;
        
        private var loader:URLLoader;

        private var accessToken:String;
        private var environment:String;
        private var swfUrl:String;
        private var embeddedUrl:String;
        private var queryString:String;
        private var serverData:Object;

        private var itemCount:int = 0;

        protected function RatchetNotifier(accessToken:String,
                                           environment:String,
                                           userIp:String=null,
                                           serverData:Object=null) {
            this.accessToken = accessToken;
            this.environment = environment;
            this.serverData = serverData || {};
            this.userIp = userIp;
            
            swfUrl = unescape(LoaderInfo(this.root.loaderInfo).url);
            embeddedUrl = getEmbeddedUrl();
            queryString = getQueryString();

            loader = new URLLoader();
            loader.dataFormat = URLLoaderDataFormat.TEXT;
 
            loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, handleUrlLoaderEvent);
            loader.addEventListener(IOErrorEvent.IO_ERROR, handleUrlLoaderEvent);
            loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, handleUrlLoaderEvent);
            loader.addEventListener(Event.COMPLETE, handleUrlLoaderEvent);
        }

        public function handleError(err:Error):void {
            handleStackTrace(err.getStackTrace());
        }

        public function handleError(err:ErrorEvent):void {
            handleStackTrace(err.getStackTrace());
        }

        public function buildPayload(stackTrace:String):Object {
            var stackTraceObj:Object = parseDataFromStackTrace(stackTrace);
            var payload:Object = {
                accessToken: accessToken,
                timestamp: int(getTimer()),
                platform: "flash",
                language: "as3",
                request: {
                    url: embeddedUrl,
                    query_string: queryString,
                    user_ip: userIp
                },
                client: {
                    browser: browser,
                    runtime: int(getTimer() - startTime),
                    swf_url: swfUrl,
                    flash_player: {
                        freeMemory: System.freeMemory,
                        privateMemory: System.privateMemory,
                        totalMemory: System.totalMemory
                        capabilities: {
                            avHardwareDisable: Capabilities.avHardwareDisable,
                            cpuArchitecture: Capabilities.cpuArchitecture,
                            externalInterfaceAvailable: ExternalInterface.available,
                            hasAccessibility: Capabilities.hasAccessibility,
                            hasAudio: Capabilities.hasAudio,
                            isDebugger: Capabilities.isDebugger,
                            language: Capabilities.language,
                            localFileReadDisable: Capabilities.localFileReadDisable,
                            manufacturer: Capabilities.manufacturer,
                            os: Capabilities.os,
                            pixelAspectRatio: Capabilities.pixelAspectRatio,
                            playerType: Capabilities.playerType,
                            screenDPI: Capabilities.screenDPI,
                            screenResolutionX: Capabilities.screenResolutionX,
                            screenResolutionY: Capabilities.screenResolutionY,
                            version: Capabilities.version
                        }
                    }
                },
                server: server,
                notifier: NOTIFIER_DATA,
                data: {
                    environment: environment,
                    body: {
                        trace: {
                            frames: stackTraceObj.frames,
                            exception: {
                                class: stackTraceObj.class,
                                message: stackTraceObj.message
                            }
                        }
                    }
                }
            };
            return payload;
        }
        
        public function dispose():void {
            loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, handleUrlLoaderEvent);
            loader.removeEventListener(IOErrorEvent.IO_ERROR, handleUrlLoaderEvent);
            loader.removeEventListener(HTTPStatusEvent.HTTP_STATUS, handleUrlLoaderEvent);
            loader.removeEventListener(Event.COMPLETE, handleUrlLoaderEvent);
            loader = null;
        }

        private function handleStackTrace(stackTrace:String):void {
            sendPayload(buildPayload(stackTrace);
        }

        private function sendPayload(payload:Object):void {
            if (itemCount < MAX_ITEM_COUNT) {
                var request = new URLRequest();
                request.method = URLRequestMethod.POST;
                request.data = [JSON.encode(payload)];
                request.url = API_ENDPONT_URL;         

                loader.load(request);
                itemCount++;
            } else {
                // too many handled items
            }
        }

        private function handleUrlLoaderEvent(event:Event):void {
            dispatchEvent(event); 
        }

        private function getEmbeddedUrl():String {
            if (ExternalInterface.available) {
                return ExternalInterface.call("window.location.href");
            }
            return null;
        }

        private function getQueryString():String {
            if (ExternalInterface.available) {
                return ExternalInterface.call("window.location.search.substring", 1);
            }
            return null;
        }
        
        /*
         * from http://www.actionscript-flash-guru.com/blog/18-parse-file-package-function-name-from-stack-trace-in-actionscript-as3
         */
        protected function parseDataFromStackTrace(stackTrace:String):Object {
            // extract function name from the stack trace
            var parsedDataObj:Object = {fileName: "", packageName: "", className: "", functionName: ""};
            var nameResults:Array;

            // extract the package from the class name
            var matchExpression:RegExp;
            var isFileNameFound:Boolean;

            // if running in debugger you are going to remove that data
            var removeDebuggerData:RegExp = /\[.*?\]/msgi;
            stackTrace = stackTrace.replace(removeDebuggerData, "");

            // remove the Error message at the top of the stack trace
            var removeTop:RegExp = /^Error.*?at\s/msi;
            stackTrace = stackTrace.replace(removeTop, "");
            stackTrace = "at " + stackTrace;

            // get file name
            matchExpression = /(at\s)*(.*?)_fla::/i;
            nameResults = stackTrace.match(matchExpression);
            if (nameResults != null && nameResults.length > 2) {
                parsedDataObj.fileName = nameResults[2];
                parsedDataObj.fileName = parsedDataObj.fileName.replace(/^\s*at\s/i, "") + ".fla";
                isFileNameFound = true;
            }

            // match timeline data
            matchExpression = /^at\s(.*?)::(.*?)\/(.*?)::(.*?)\(\)/i;
            nameResults = stackTrace.match(matchExpression);

            if (nameResults != null && nameResults.length > 4) {
                if (!isFileNameFound) {
                    parsedDataObj.fileName = String(nameResults[1]).replace(/_fla$/i, ".fla");
                    parsedDataObj.fileName = parsedDataObj.fileName.replace(/^at\s/i, "");
                }
                parsedDataObj.packageName = String(nameResults[1]);
                parsedDataObj.className = String(nameResults[2]);
                parsedDataObj.functionName = String(nameResults[4]);
            } else {
                // match function in a class of format com.package::SomeClass/somefunction()
                matchExpression = /^at\s(.*?)::(.*?)\/(.*?)\(\)/i;
                nameResults = stackTrace.match(matchExpression);
                if (nameResults != null && nameResults.length > 3) {
                    if (!isFileNameFound) {
                        parsedDataObj.fileName = String(nameResults[2]) + ".as";
                    }
                    parsedDataObj.packageName = nameResults[1];
                    parsedDataObj.className = nameResults[2];
                    parsedDataObj.functionName = String(nameResults[3]);
                } else {
                    // match a contructor with $iinit
                    matchExpression = /^at\s(.*?)::(.*?)\$(.*?)\(\)/i;
                    nameResults = stackTrace.match(matchExpression);
                    if (nameResults != null && nameResults.length > 3) {
                        if (!isFileNameFound) {
                            parsedDataObj.fileName = String(nameResults[2]) + ".as";
                        }
                        parsedDataObj.packageName = String(nameResults[1]);
                        parsedDataObj.className = String(nameResults[2]);
                        parsedDataObj.functionName = String(nameResults[2]);
                    } else {
                        // match a contructor that looks like this com.package::SomeClassConstructor()
                        matchExpression = /^at\s(.*?)::(.*?)\(\)/i;
                        nameResults = stackTrace.match(matchExpression);
                        if (nameResults != null && nameResults.length > 2) {
                            if (!isFileNameFound) {
                                parsedDataObj.fileName = String(nameResults[2]) + ".as";
                            }
                            parsedDataObj.packageName = String(nameResults[1]);
                            parsedDataObj.className = String(nameResults[2]);
                            parsedDataObj.functionName = String(nameResults[2]);
                        } else {
                            // can't find a match - this is a catch all, you never know, 
                            if (!isFileNameFound) {
                                parsedDataObj.fileName = "NO_DATA";
                            }
                            parsedDataObj.packageName = "NO_DATA";
                            parsedDataObj.className = "NO_DATA";
                            parsedDataObj.functionName = "NO_DATA";
                        }
                    }
                }
            }
            return parsedDataObj;
        }
    }
}
