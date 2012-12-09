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
    import flash.events.ProgressEvent;

    import mx.logging.ILogger;
    import mx.utils.ObjectUtil;

    import org.apache.flex.utilities.developerToolSuite.executor.domain.SettingModel;
    import org.apache.flex.utilities.developerToolSuite.executor.infrastructure.message.ValidateSvnPathMessage;
    import org.apache.flex.utilities.developerToolSuite.executor.infrastructure.util.LogUtil;

    public class ValidateSvnPathCommand extends AbstractShellCommand {

        private static var LOG:ILogger = LogUtil.getLogger(ValidateAntPathCommand);

        [Inject]
        public var settings:SettingModel;

        private var _done:Boolean;

        public function execute(msg:ValidateSvnPathMessage):void {
            LOG.debug("Executing Command with message: " + ObjectUtil.toString(msg));
            settings.svnEnabled = false;
            executeCommand();
        }

        override protected function executeCommand():void {
            LOG.debug("Executing Command");

            if (shell.OS == "win") {
                command.push("/C");
            }

            command.push("svn");
            command.push("help");

            super.executeCommand();
        }

        protected function readOutputs(output:String):void {
            if (_done) {
                return;
            }

            _done = true;
            if (output.indexOf("Subversion command-line client") > -1) {
                settings.svnEnabled = true;
                result(CommandCallBack.DEFAULT_RESULT);
            } else {
                result(CommandCallBack.DEFAULT_ERROR);
            }

            return;
        }

        override protected function outputDataHandler(event:ProgressEvent):void {
            super.outputDataHandler(event);
            readOutputs(standardOutput);
        }

        override protected function errorDataHandler(event:ProgressEvent):void {
            super.errorDataHandler(event);
            readOutputs(standardError);
        }
    }
}
