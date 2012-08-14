package io.ratchet.notifier {

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

    import io.ratchet.json.JSONEncoder;
    import io.ratchet.stacktrace.StackTrace;
    import io.ratchet.stacktrace.StackTraceParser;

    [Event(name="complete", type="flash.events.Event")]
    [Event(name="httpStatus", type="flash.events.HTTPStatusEvent")]
    [Event(name="ioError", type="flash.events.IOErrorEvent")]
    [Event(name="securityError", type="flash.events.SecurityErrorEvent")]
    public final class RatchetNotifier extends Sprite {

        private static const API_ENDPONT_URL:String = "https://submit.ratchet.io/api/1/item/";
        private static const NOTIFIER_DATA:Object = {name: "flash_ratchet", version: "0.1"};
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
        private var endpointUrl:String;
        private var maxItemCount:int;
        private var userIp:String;
        private var startTime:int;
        private var branch:String;
        private var rootPath:String;

        public function RatchetNotifier(accessToken:String,
                                        environment:String,
                                        userIp:String=null,
                                        rootPath:String=null,
                                        codeBranch:String=null,
                                        serverData:Object=null,
                                        maxItemCount:int=5,
                                        endpointUrl:String=null) {
            this.accessToken = accessToken;
            this.environment = environment;
            this.serverData = serverData || {};
            this.userIp = userIp;
            this.endpointUrl = endpointUrl || API_ENDPONT_URL;
            this.maxItemCount = maxItemCount || MAX_ITEM_COUNT;
            this.branch = codeBranch || "master";
            this.rootPath = rootPath;

            loader = new URLLoader();
            loader.dataFormat = URLLoaderDataFormat.TEXT;
 
            loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, handleUrlLoaderEvent);
            loader.addEventListener(IOErrorEvent.IO_ERROR, handleUrlLoaderEvent);
            loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, handleUrlLoaderEvent);
            loader.addEventListener(Event.COMPLETE, handleUrlLoaderEvent);

            addEventListener(Event.ADDED_TO_STAGE, function(event:Event):void {
                swfUrl = unescape(parent.loaderInfo.url);
                embeddedUrl = getEmbeddedUrl();
                queryString = getQueryString();

                // Register for uncaught errors if >= 10.1.
                if (parent.loaderInfo.hasOwnProperty('uncaughtErrorEvents')) {
                    var uncaughtErrorEvents:IEventDispatcher = IEventDispatcher(parent.loaderInfo.uncaughtErrorEvents);
                    uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, handleUncaughtError);
                }
            });
        }

        public function handleError(err:Error):void {
            var stackTrace:String = err.getStackTrace();
            if (stackTrace !== null) {
                // we got a stack trace (we're in the debug player).
                handleStackTrace(stackTrace);
            } else {
                // no stack trace. just report the basics.
                handlePlainError(err.errorID, err.name, err.message);
            }
        }

        public function handleErrorEvent(event:ErrorEvent):void {
            var newError:Error = new Error("An ErrorEvent was thrown and not caught: " + event.toString());
            handleError(newError);
        }

        public function handleOtherEvent(event:*):void {
            var newError:Error = new Error("A non-Error or ErrorEvent was thrown and not caught: " + event.toString());
            handleError(newError);
        }

        public function dispose():void {
            loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, handleUrlLoaderEvent);
            loader.removeEventListener(IOErrorEvent.IO_ERROR, handleUrlLoaderEvent);
            loader.removeEventListener(HTTPStatusEvent.HTTP_STATUS, handleUrlLoaderEvent);
            loader.removeEventListener(Event.COMPLETE, handleUrlLoaderEvent);
            loader = null;
        }

        private function handleUncaughtError(event:UncaughtErrorEvent):void {
            if (event.error is Error) {
                var error:Error = event.error as Error;
                handleError(error);
            } else if (event.error is ErrorEvent) {
                var errorEvent:ErrorEvent = event.error as ErrorEvent;
                handleErrorEvent(errorEvent);
            } else {
                // Inform the user that a non-error event was thrown and not caught.
                handleOtherEvent(event);
            }
        }

        private function handleStackTrace(stackTrace:String):void {
            sendPayload(buildDebugPayload(stackTrace));
        }

        private function handlePlainError(errorID:int, name:String, message:String):void {
            sendPayload(buildReleasePayload(errorID, name, message));
        }

        private function sendPayload(payload:Object):void {
            if (itemCount < this.maxItemCount) {
                var request:URLRequest = new URLRequest();
                request.method = URLRequestMethod.POST;
                request.data = JSONEncoder.encode(payload);
                request.url = this.endpointUrl;         

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
                return ExternalInterface.call("window.location.href.toString");
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
                return ExternalInterface.call("window.navigator.userAgent.toString");
            }
            return null;
        }

        /**
         * Builds and returns a payload object using the information available in the Release player.
         *
         * errorID, name, and message should come from the relevant Error object.
         */
        private function buildReleasePayload(errorID:int, name:String, message:String):Object {
            var messageTitle:String = name + ": " + message;
            var messageBody:String = "Error ID: " + errorID + "\n" + messageTitle;

            var payload:Object = buildCommonPayload();
            payload.data.body = {
                message: {
                    body: messageBody,
                    error_id: errorID
                }
            };
            payload.data.title = messageTitle;
            return payload;
        }

        /**
         * Builds and returns a payload object using the information available in the Debug player.
         *
         * stackTrace should come from error.getStackTrace()
         */
        private function buildDebugPayload(stackTrace:String):Object {
            var stackTraceObj:StackTrace = StackTraceParser.parseStackTrace(stackTrace);

            var payload:Object = buildCommonPayload();
            payload.data.body = {
                trace: {
                    frames: stackTraceObj.frames,
                    exception: {
                        'class': stackTraceObj.errorClassName,
                        message: stackTraceObj.message
                    }
                }
            };
            return payload;
        }
        
        /**
         * Builds and returns common payload data. Used by buildReleasePayload and buildDebugPayload.
         */
        private function buildCommonPayload():Object {
            var payload:Object = {
                access_token: accessToken,
                data: {
                    environment: environment,
                    timestamp: int((new Date()).getTime() / 1000),
                    platform: "flash",
                    language: "as3",
                    request: {
                        url: embeddedUrl,
                        query_string: queryString,
                        user_ip: userIp
                    },
                    client: {
                        runtime_ms: getTimer(),
                        root: rootPath,
                        branch: branch,
                        flash: {
                            browser: getBrowserUserAgent(),
                            swf_url: swfUrl,
                            player: {
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
                        }
                    },
                    server: serverData,
                    notifier: NOTIFIER_DATA
                }
            };
            return payload;
        }
        
    }
}
