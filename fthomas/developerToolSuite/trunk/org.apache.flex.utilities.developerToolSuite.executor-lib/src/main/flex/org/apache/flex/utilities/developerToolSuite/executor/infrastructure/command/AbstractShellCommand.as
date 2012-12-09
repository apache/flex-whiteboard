/**
 Licensed to the Apache Software Foundation (ASF) under one or more
 contributor license agreements.  See the NOTICE file distributed with
 this work for additional information regarding copyright ownership.
 The ASF licenses this file to You under the Apache License, Version 2.0
 (the "License"); you may not use this file except in compliance with
 the License.  You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */
package org.apache.flex.utilities.developerToolSuite.executor.infrastructure.command {
    import flash.events.IOErrorEvent;
    import flash.events.NativeProcessExitEvent;
    import flash.events.ProgressEvent;

    import mx.logging.ILogger;

    import org.apache.flex.utilities.developerToolSuite.executor.infrastructure.nativeProcess.NativeShellHelper;
    import org.apache.flex.utilities.developerToolSuite.executor.infrastructure.util.LogUtil;

    public class AbstractShellCommand {

        protected var log:ILogger = LogUtil.getLogger(this);

        public var callback:Function;

        protected var shell:NativeShellHelper;

        protected var shellPath:String;
        protected var command:Vector.<String> = new Vector.<String>();

        protected var standardOutput:String;
        protected var standardError:String;

        public function AbstractShellCommand() {
            shell = new NativeShellHelper();
        }

        protected function executeCommand():void {
            addShellListeners();

            shell.run(command, shellPath);
        }

        private function addShellListeners():void {
            shell.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, outputDataHandler, false, 0, true);
            shell.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, errorDataHandler, false, 0, true);
            shell.addEventListener(IOErrorEvent.STANDARD_OUTPUT_IO_ERROR, IOErrorHandler, false, 0, true);
            shell.addEventListener(IOErrorEvent.STANDARD_ERROR_IO_ERROR, IOErrorHandler, false, 0, true);
            shell.addEventListener(NativeProcessExitEvent.EXIT, exitHandler, false, int.MIN_VALUE, true);
        }

        private function removeShellListeners():void {
            shell.removeEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, outputDataHandler);
            shell.removeEventListener(ProgressEvent.STANDARD_ERROR_DATA, errorDataHandler);
            shell.removeEventListener(IOErrorEvent.STANDARD_OUTPUT_IO_ERROR, IOErrorHandler);
            shell.removeEventListener(IOErrorEvent.STANDARD_ERROR_IO_ERROR, IOErrorHandler);
            shell.removeEventListener(NativeProcessExitEvent.EXIT, exitHandler);
        }

        protected function outputDataHandler(event:ProgressEvent):void {
            var shell:NativeShellHelper = event.currentTarget as NativeShellHelper;
            standardOutput = shell.process.standardOutput.readUTFBytes(shell.process.standardOutput.bytesAvailable);
            log.debug("Reading standard output: \n" + standardOutput);
        }

        protected function errorDataHandler(event:ProgressEvent):void {
            var shell:NativeShellHelper = event.currentTarget as NativeShellHelper;
            standardError = shell.process.standardError.readUTFBytes(shell.process.standardError.bytesAvailable);
            log.debug("Reading standard error: \n" + standardError);
        }

        protected function IOErrorHandler(event:IOErrorEvent):void {
            log.error(event.toString());
            result(new CommandCallBackError(event.text, event.errorID));
        }

        protected function exitHandler(event:NativeProcessExitEvent):void {
            log.debug("Process exited with ", event.exitCode.toString());
            removeShellListeners();
        }

        protected function result(error:ICommandCallBack):void {
            shell.process.exit();
            callback(error);
        }
    }
}
