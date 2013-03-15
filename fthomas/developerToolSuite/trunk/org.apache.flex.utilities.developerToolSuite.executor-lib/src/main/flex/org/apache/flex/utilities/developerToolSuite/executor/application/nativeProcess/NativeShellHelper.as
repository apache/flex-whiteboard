package org.apache.flex.utilities.developerToolSuite.executor.application.nativeProcess {
    import flash.desktop.NativeProcess;
    import flash.desktop.NativeProcessStartupInfo;
    import flash.errors.IllegalOperationError;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.IOErrorEvent;
    import flash.events.NativeProcessExitEvent;
    import flash.events.ProgressEvent;
    import flash.filesystem.File;
    import flash.system.Capabilities;

    import mx.logging.ILogger;

    import org.apache.flex.utilities.developerToolSuite.executor.application.util.LogUtil;

    public class NativeShellHelper extends EventDispatcher {

        // Use trace during tests as AIR thru Maven doesn't support resource xml config files for logging.
        private static var LOG:ILogger;

        private static var _gcLocker:GCLocker;

        private var _process:NativeProcess;
        private var _isRunning:Boolean;

        private var _isLogEnabled:Boolean;

        public function NativeShellHelper() {
            super();
            if (!LOG) {
                LOG = LogUtil.getLogger(NativeShellHelper);
            }
            if (!_gcLocker) {
                _gcLocker = new GCLocker();
            }
            _process = new NativeProcess();
        }

        public function get process():NativeProcess {
            return _process;
        }

        public function get isRunning():Boolean {
            return _isRunning;
        }

        public function run(command:Vector.<String> = null, shell:String = null):void {

            if (_isRunning) {
                throw new Error("NativeProcessHelper is currently busy");
                return;
            }
            _isRunning = true;

            //Avoid the garbage collection
            _gcLocker.lock(this);

            if (!shell) {
                shell = getShellPath();
            }

            LOG.debug("Executing: {0} {1}", shell, command.join(" "));

            var nativeProcessStartupInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();

            var file:File = File.applicationDirectory.resolvePath(shell);
            nativeProcessStartupInfo.executable = file;
            nativeProcessStartupInfo.arguments = command;

            _process.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, dispatch2, false, 0, true);
            _process.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, dispatch2, false, 0, true);
            _process.addEventListener(IOErrorEvent.STANDARD_OUTPUT_IO_ERROR, dispatch2, false, 0, true);
            _process.addEventListener(IOErrorEvent.STANDARD_ERROR_IO_ERROR, dispatch2, false, 0, true);
            _process.addEventListener(NativeProcessExitEvent.EXIT, exitHandler, false, -100, true);

            try {
                _process.start(nativeProcessStartupInfo);
            } catch (error:IllegalOperationError) {
                LOG.error("Illegal Operation: {0}", error.toString());
            } catch (error:ArgumentError) {
                LOG.error("Argument Error: {0}", error.toString());
            } catch (error:Error) {
                LOG.error("Error: {0}", error.toString());
            }
        }

        public function logMessages():void {
            if (_isLogEnabled) {
                return;
            }
            _isLogEnabled = true;
            _process.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, outputDataLogHandler, false, 0, true);
            _process.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, errorDataLogHandler, false, 0, true);
            _process.addEventListener(IOErrorEvent.STANDARD_OUTPUT_IO_ERROR, IOErrorLogHandler, false, 0, true);
            _process.addEventListener(IOErrorEvent.STANDARD_ERROR_IO_ERROR, IOErrorLogHandler, false, 0, true);
            _process.addEventListener(NativeProcessExitEvent.EXIT, exitLogHandler, false, 0, true);
        }

        private function errorDataLogHandler(event:ProgressEvent):void {
            trace(_process.standardError.readUTFBytes(_process.standardError.bytesAvailable));
            //LOG.error(_process.standardError.readUTFBytes(_process.standardError.bytesAvailable));
        }

        private function exitLogHandler(event:NativeProcessExitEvent):void {
            trace("Process exited with " + event.exitCode);
            //LOG.info("Process exited with " + event.exitCode);

        }

        private function IOErrorLogHandler(event:IOErrorEvent):void {
            trace(event.toString());
            //LOG.error(event.toString());
        }

        private function outputDataLogHandler(event:ProgressEvent):void {
            var output:String = _process.standardOutput.readUTFBytes(_process.standardOutput.bytesAvailable);
            trace("Output: " + output);
            //LOG.info("Output: " + output);
        }

        private function dispatch2(e:Event):void {
            this.dispatchEvent(e);
        }

        private function exitHandler(e:Event):void {
            _gcLocker.release(this);
            _process = null;
            _isRunning = false;
            this.dispatchEvent(e);
        }

        public static function get OS():String {
            var os:String;

            if (Capabilities.os.toLowerCase().indexOf("win") > -1) {
                os = "win";
            } else if (Capabilities.os.toLowerCase().indexOf("mac") > -1) {
                os = "mac";
            } else if (Capabilities.os.toLowerCase().indexOf("linux") > -1) {
                os = "linux";
            }

            return os;
        }

        public function get OS():String {
            return NativeShellHelper.OS;
        }

        public function getShellPath():String {
            var shellPath:String;

            if (OS == "win") {
                shellPath = "C:/Windows/System32/cmd.exe";
            } else if (OS == "mac") {
                shellPath = "/Applications/Utilities/Terminal.app";
            } else if (OS == "linux") {

                var file:File;
                try {
                    file = new File("/bin/bash");
                    if (file.exists) {
                        shellPath = file.nativePath;
                    }
                } catch (err:Error) {
                }
                ;

                if (!shellPath) {
                    try {
                        file = new File("/bin/bsh");
                        if (file.exists) {
                            shellPath = file.nativePath;
                        }
                    } catch (err:Error) {
                    }
                    ;
                }

                if (!shellPath) {
                    try {
                        file = new File("/bin/csh");
                        if (file.exists) {
                            shellPath = file.nativePath;
                        }
                    } catch (err:Error) {
                    }
                    ;
                }
            }
            if (!shellPath) {
                throw new Error("Unsupported System");
            }

            return shellPath;
        }

        public static function formatPath(path:String):String {
            return path.replace(/\\/g, "/");
        }

        public function formatPath(path:String):String {
            return NativeShellHelper.formatPath(path);
        }
    }
}
internal class GCLocker {

    private var _lockedRefs:Array;

    public function GCLocker() {
        _lockedRefs = [];
    }

    public function release(ref:*):void {
        var i:int = _lockedRefs.indexOf(ref);

        if (i >= 0) {
            _lockedRefs.splice(i, 1);
        }
    }

    public function lock(ref:*):void {
        _lockedRefs[_lockedRefs.length] = ref;
    }
}
