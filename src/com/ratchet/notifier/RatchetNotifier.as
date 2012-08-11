package com.ratchet.notifier {

    import flash.display.Sprite;
    import flash.display.LoaderInfo;

    import flash.errors.IllegalOperationError;

    import flash.events.Event;
    import flash.events.ErrorEvent;
    import flash.events.EventDispatcher;
    import flash.events.HTTPStatusEvent;
    import flash.events.IOErrorEvent;
    import flash.events.IEventDispatcher;
    import flash.events.SecurityErrorEvent;
    import flash.events.UncaughtErrorEvent;

    import flash.external.ExternalInterface;

    import flash.net.URLLoader;
    import flash.net.URLLoaderDataFormat;
    import flash.net.URLRequest;
    import flash.net.URLRequestMethod;
    import flash.net.URLVariables;

    import flash.system.Capabilities;
    import flash.system.System;

    import flash.utils.getTimer;

    import com.ratchet.json.JSONEncoder;
    import com.ratchet.stacktrace.StackTrace;
    import com.ratchet.stacktrace.StackTraceParser;

    [Event(name="complete", type="flash.events.Event")]
    [Event(name="httpStatus", type="flash.events.HTTPStatusEvent")]
    [Event(name="ioError", type="flash.events.IOErrorEvent")]
    [Event(name="securityError", type="flash.events.SecurityErrorEvent")]
    public class RatchetNotifier extends Sprite {

        //private static const API_ENDPONT_URL:String = "https://submit.ratchet.io/api/1/item/";
        private static const API_ENDPONT_URL:String = "http://localhost:6943/api/1/item/";
        private static const NOTIFIER_DATA:Object = {name: "flash_ratchet", version: 1.0};
        private static const MAX_ITEM_COUNT:int = 5;

        private static var instance:RatchetNotifier = null;
        
        private var loader:URLLoader;

        private var accessToken:String;
        private var environment:String;
        private var swfUrl:String;
        private var embeddedUrl:String;
        private var queryString:String;
        private var serverData:Object;
        private var itemCount:int = 0;
        private var submitUrl:String;
        private var maxItemCount:int;
        private var userIp:String;
        private var startTime:int;

        public function RatchetNotifier(accessToken:String,
                                        environment:String,
                                        userIp:String=null,
                                        serverData:Object=null,
                                        submitUrl:String=null,
                                        maxItemCount:int=5) {
            this.accessToken = accessToken;
            this.environment = environment;
            this.serverData = serverData || {};
            this.userIp = userIp;
            this.submitUrl = submitUrl || API_ENDPONT_URL;
            this.maxItemCount = maxItemCount || MAX_ITEM_COUNT;

            loader = new URLLoader();
            //loader.dataFormat = URLLoaderDataFormat.VARIABLES;
            loader.dataFormat = URLLoaderDataFormat.TEXT;
 
            loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, handleUrlLoaderEvent);
            loader.addEventListener(IOErrorEvent.IO_ERROR, handleUrlLoaderEvent);
            loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, handleUrlLoaderEvent);
            loader.addEventListener(Event.COMPLETE, handleUrlLoaderEvent);

            addEventListener(Event.ADDED_TO_STAGE, function(event:Event):void {
                swfUrl = unescape(loaderInfo.url);
                trace('SWF URL: ' + swfUrl);
                embeddedUrl = getEmbeddedUrl();
                queryString = getQueryString();

                // Register for uncaught errors if >= 10.1.
                if(loaderInfo.hasOwnProperty('uncaughtErrorEvents')) {
                    var uncaughtErrorEvents:IEventDispatcher = IEventDispatcher(loaderInfo["uncaughtErrorEvents"]);
                    uncaughtErrorEvents.addEventListener("uncaughtError", handleUncaughtError);
                }
            });
        }

        public function handleError(err:Error):void {
            handleStackTrace(err.getStackTrace());
        }

        public function handleErrorEvent(event:ErrorEvent):void {
            handleStackTrace(buildErrorEventStackTrace(event));
        }

        public function buildPayload(stackTrace:String):Object {
            var stackTraceObj:StackTrace = StackTraceParser.parseStackTrace(stackTrace);

            var payload:Object = {
                access_token: accessToken,
                data: {
                    environment: environment,
                    body: {
                        trace: {
                            frames: stackTraceObj.frames,
                            exception: {
                                'class': 'FOO', //stackTraceObj.className,
                                message: stackTraceObj.message
                            }
                        }
                    },
                    timestamp: int((new Date()).getTime() / 1000),
                    platform: "flash",
                    language: "as3",
                    request: {
                        url: embeddedUrl,
                        query_string: queryString,
                        user_ip: userIp
                    },
                    client: {
                        browser: getBrowserUserAgent(),
                        runtime: getTimer(),
                        swf_url: swfUrl,
                        flash_player: {
                            freeMemory: System.freeMemory,
                            privateMemory: System.privateMemory,
                            totalMemory: System.totalMemory,
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
                    server: serverData,
                    notifier: NOTIFIER_DATA
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

        private function buildErrorEventStackTrace(event:ErrorEvent):String {
            return 'error event stack trace. Implement me';
        }

        private function handleUncaughtError(event:UncaughtErrorEvent):void {
            // pass
            if (event.error is Error) {
                var error:Error = event.error as Error;
                // do something with the error
            } else if (event.error is ErrorEvent) {
                var errorEvent:ErrorEvent = event.error as ErrorEvent;
                // do something with the error
            } else {
                // a non-Error, non-ErrorEvent type was thrown and uncaught
            }
        }

        private function handleStackTrace(stackTrace:String):void {
            sendPayload(buildPayload(stackTrace));
        }

        private function sendPayload(payload:Object):void {
            if (itemCount < this.maxItemCount) {
                var request:URLRequest = new URLRequest();
                var vars:URLVariables = new URLVariables();

                vars.payload = JSONEncoder.encode(payload);

                request.method = URLRequestMethod.POST;
                request.data = JSONEncoder.encode(payload);//vars;
                request.url = this.submitUrl;         

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

        private function getBrowserUserAgent():String {
            if (ExternalInterface.available) {
                return ExternalInterface.call("navigtor.userAgent");
            }
            return null;
        }
    }
}
