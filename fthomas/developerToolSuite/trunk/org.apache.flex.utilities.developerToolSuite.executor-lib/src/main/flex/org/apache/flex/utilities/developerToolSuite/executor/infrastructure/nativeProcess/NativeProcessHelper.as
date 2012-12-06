package org.apache.flex.utilities.developerToolSuite.executor.infrastructure.nativeProcess {
    import flash.desktop.NativeProcess;
    import flash.desktop.NativeProcessStartupInfo;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.IOErrorEvent;
    import flash.events.NativeProcessExitEvent;
    import flash.events.ProgressEvent;
    import flash.filesystem.File;

    import mx.logging.ILogger;

    import org.apache.flex.utilities.developerToolSuite.executor.infrastructure.util.LogUtil;

    public class NativeProcessHelper extends EventDispatcher {

        // Use trace during tests as AIR thru Maven doesn't support resource xml config files for logging.
        private static var LOG:ILogger;

        private static var _gcLocker:GCLocker;

        private var _process:NativeProcess;
        private var _isRunning:Boolean;

        private var _isLogEnabled:Boolean;

        public function NativeProcessHelper() {
            super();
            if (!LOG)
                LOG = LogUtil.getLogger(NativeProcessHelper);
            if (!_gcLocker)
                _gcLocker = new GCLocker();
        }

        public function get process():NativeProcess {
            return _process;
        }

        public function get isRunning():Boolean {
            return _isRunning;
        }

        public function run(command:String, args:Vector.<String> = null):void {

            if (_isRunning) {
                throw new Error("NativeProcessHelper is currently busy");
                return;
            }
            _process = new NativeProcess();
            _isRunning = true;

            //Avoid the garbage collection
            _gcLocker.lock(this);

            var nativeProcessStartupInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
            var processArgs:Vector.<String> = new Vector.<String>();

            var file:File = File.applicationDirectory.resolvePath(command);
            nativeProcessStartupInfo.executable = file;
            processArgs = args;
            nativeProcessStartupInfo.arguments = processArgs;

            _process.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, dispatch2, false, 0, true);
            _process.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, dispatch2, false, 0, true);
            _process.addEventListener(IOErrorEvent.STANDARD_OUTPUT_IO_ERROR, dispatch2, false, 0, true);
            _process.addEventListener(IOErrorEvent.STANDARD_ERROR_IO_ERROR, dispatch2, false, 0, true);
            _process.addEventListener(NativeProcessExitEvent.EXIT, exitHandler, false, -100, true);
            _process.start(nativeProcessStartupInfo);
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
