package com.rollbar.notifier {

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
    
    import com.laiyonghao.Uuid;

    import com.rollbar.json.JSONEncoder;
    import com.rollbar.stacktrace.StackTrace;
    import com.rollbar.stacktrace.StackTraceParser;

    [Event(name="complete", type="flash.events.Event")]
    [Event(name="httpStatus", type="flash.events.HTTPStatusEvent")]
    [Event(name="ioError", type="flash.events.IOErrorEvent")]
    [Event(name="securityError", type="flash.events.SecurityErrorEvent")]
    public final class RollbarNotifier extends Sprite {

        private static const API_ENDPONT_URL:String = "https://api.rollbar.com/api/1/item/";
        private static const NOTIFIER_DATA:Object = {name: "flash_rollbar", version: "0.9.2"};
        private static const MAX_ITEM_COUNT:int = 5;

        private static var instance:RollbarNotifier = null;
        
        // Keep URLLoaders from being garbage collected before they finish
        private var loaders:Array;

        private var accessToken:String;
        private var environment:String;
        private var swfUrl:String;
        private var embeddedUrl:String;
        private var queryString:String;
        private var serverData:Object;
        private var itemCount:int = 0;
        private var endpointUrl:String;
        private var maxItemCount:int;
        private var personFn:Function;
        private var userId:String;
        private var person:Object;
        private var startTime:int;
        private var branch:String;
        private var rootPath:String;
        private var srcPath:String;
        private var codeVersion:String;

        public function RollbarNotifier(accessToken:String,
                                        environment:String,
                                        person:* = null,
                                        rootPath:String = null,
                                        srcPath:String = null,
                                        codeBranch:String = null,
                                        serverData:Object = null,
                                        maxItemCount:int = 5,
                                        endpointUrl:String = null) {
            this.accessToken = accessToken;
            this.environment = environment;
            this.serverData = serverData || {};
            this.endpointUrl = endpointUrl || API_ENDPONT_URL;
            this.maxItemCount = maxItemCount || MAX_ITEM_COUNT;
            this.branch = codeBranch || "master";
            this.rootPath = rootPath;
            this.srcPath = srcPath;
            
            this.loaders = new Array();

            if (person) {
                if (person is Function) {
                    this.personFn = person;
                } else if (person is String) {
                    this.userId = person;
                } else if (person is Object) {
                    this.person = person;
                    this.userId = resolveField(['id', 'userId', 'user_id', 'user'], person);
                } else {
                    this.userId = '' + person;
                }
            }

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

        public function dispose():void {
        }

        public function handleError(err:Error, extraData:Object = null):String {
            var stackTrace:String = err.getStackTrace();
            if (stackTrace !== null) {
                // we got a stack trace (we're in the debug player).
                return handleStackTrace(stackTrace, extraData);
            } else {
                // no stack trace. just report the basics.
                return handlePlainError(err.errorID, err.name, err.message, extraData);
            }
        }

        public function handleErrorEvent(event:ErrorEvent):String {
            var newError:Error = new Error("An ErrorEvent was thrown and not caught: " + event.toString());
            return handleError(newError);
        }

        public function handleOtherEvent(error:*):String {
            var newError:Error = new Error("A non-Error or ErrorEvent was thrown and not caught: " + error.toString());
            return handleError(newError);
        }
        
        public function setCodeVersion(codeVersion:String):void {
            this.codeVersion = codeVersion;
        }

        private function handleUncaughtError(event:UncaughtErrorEvent):String {
            if (event.error is Error) {
                var error:Error = event.error as Error;
                return handleError(error);
            } else if (event.error is ErrorEvent) {
                var errorEvent:ErrorEvent = event.error as ErrorEvent;
                return handleErrorEvent(errorEvent);
            } else {
                // Inform the user that a non-error event was thrown and not caught.
                return handleOtherEvent(event.error);
            }
        }

        private function handleStackTrace(stackTrace:String, extraData:Object):String {
            var payload:Object = buildDebugPayload(stackTrace, extraData);
            sendPayload(payload);
            return payload['data']['uuid'];
        }

        private function handlePlainError(errorID:int, name:String, message:String, extraData:Object):String {
            var payload:Object = buildReleasePayload(errorID, name, message, extraData);
            sendPayload(payload);
            return payload['data']['uuid'];
        }

        private function sendPayload(payload:Object):void {
            if (itemCount < this.maxItemCount) {
                var request:URLRequest = new URLRequest();
                request.method = URLRequestMethod.POST;
                request.data = JSONEncoder.encode(payload);
                request.url = this.endpointUrl;
                
                var loader:URLLoader = new URLLoader();
                loader.dataFormat = URLLoaderDataFormat.TEXT;
                
                var handler:Function = function(event:Event):void {
                    for (var i:int = 0; i < loaders.length; ++i) {
                        if (loaders[i] == loader) {
                            loaders.splice(i, 1);
                            break;
                        }
                    }
                    
                    loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, handler);
                    loader.removeEventListener(IOErrorEvent.IO_ERROR, handler);
                    loader.removeEventListener(Event.COMPLETE, handler);
                    
                    dispatchEvent(event);
                }
                
                loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, handler);
                loader.addEventListener(IOErrorEvent.IO_ERROR, handler);
                loader.addEventListener(Event.COMPLETE, handler);
                
                loaders.push(loader);

                loader.load(request);
                itemCount++;
            } else {
                // too many handled items
            }
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
        private function buildReleasePayload(errorID:int, name:String, message:String, extraData:Object):Object {
            var messageTitle:String = name + ": " + message;
            var messageBody:String = "Error ID: " + errorID + "\n" + messageTitle;

            var payload:Object = buildCommonPayload(extraData);
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
        private function buildDebugPayload(stackTrace:String, extraData:Object):Object {
            var stackTraceObj:StackTrace = StackTraceParser.parseStackTrace(srcPath, stackTrace);

            var payload:Object = buildCommonPayload(extraData);
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

        private function resolveField(fieldNames:Array, storage:Object):String {
            var index:Number;
            var len:Number = fieldNames.length;
            for (index = 0; index < len; ++index) {
                try {
                    return storage[fieldNames[index]].toString();
                } catch (e:*) {
                    // ignore
                }
            }
            return null;
        }

        /**
         * Builds and returns common payload data. Used by buildReleasePayload and buildDebugPayload.
         */
        private function buildCommonPayload(extraData:Object):Object {
            var tmpPerson:Object = this.person || (this.personFn != null ? this.personFn() : null);
            var userId:String = this.userId || resolveField(['id', 'userId', 'user_id', 'user'], tmpPerson);
            var person:Object;

            if (userId) {
                person = {id: userId};
                var email:String = resolveField(['email', 'emailAddress', 'email_address',
                        'userEmail', 'user_email'], tmpPerson);
                var username:String = resolveField(['username', 'userName', 'user_name', 'name'], tmpPerson);

                if (email) {
                    person['email'] = email;
                }
                if (username) {
                    person['username'] = username;
                }
            }

            var payload:Object = {
                access_token: accessToken,
                data: {
                    environment: environment,
                    platform: "flash",
                    language: "as3",
                    request: {
                        url: embeddedUrl,
                        query_string: queryString,
                        user_ip: "$remote_ip",
                        user_id: userId
                    },
                    client: {
                        runtime_ms: getTimer(),
                        timestamp: int((new Date()).getTime() / 1000),
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
                    notifier: NOTIFIER_DATA,
                    uuid: new Uuid().toString().toLowerCase()
                }
            };
            
            if (this.codeVersion) {
                payload['data']['code_version'] = this.codeVersion;
            }

            if (person) {
                payload['data']['person'] = person;
            }
            
            if (extraData) {
                for (var k:String in extraData) {
                    payload['data'][k] = extraData[k];
                }
            }
            
            return payload;
        }
        
    }
}
