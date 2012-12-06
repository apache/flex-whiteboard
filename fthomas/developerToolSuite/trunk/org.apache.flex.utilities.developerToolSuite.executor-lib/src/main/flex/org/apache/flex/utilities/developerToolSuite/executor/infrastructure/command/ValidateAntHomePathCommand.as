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
    import flash.filesystem.File;

    import mx.logging.ILogger;
    import mx.utils.ObjectUtil;

    import org.apache.flex.utilities.developerToolSuite.executor.domain.SettingModel;

    import org.apache.flex.utilities.developerToolSuite.executor.infrastructure.message.ValidateAntHomePathMessage;
    import org.apache.flex.utilities.developerToolSuite.executor.infrastructure.util.LogUtil;

    public class ValidateAntHomePathCommand extends AbstractShellCommand{

        private static var LOG:ILogger = LogUtil.getLogger(ValidateAntHomePathCommand);

        private var _msg:ValidateAntHomePathMessage;

        [Inject]
        public var settings:SettingModel;

        private var _done:Boolean;

        public function execute(msg:ValidateAntHomePathMessage):void {
            LOG.debug("Executing Command with message: " + ObjectUtil.toString(msg));
            _msg = msg;
            executeCommand();
        }

        override protected function executeCommand():void {
            LOG.debug("Executing Command with message: " + ObjectUtil.toString(_msg));

            var file:File;
            try {
                file = new File(shell.formatPath(_msg.path));
                if (!file.resolvePath("bin/ant.bat").exists) {
                    LOG.error("Error resolving ANT_HOME");
                    error(false);
                    return;
                }
            } catch (err:Error) {
                LOG.error(ObjectUtil.toString(err));
                error(false);
                return;
            }
            ;

            var ant:String = shell.formatPath(file.resolvePath("bin/ant.bat").nativePath);

            if (shell.OS == "win")
                command.push("/C");

            command.push(ant);
            command.push("-version");

            super.executeCommand();
        }

        private function extractVersion(output:String):void {

            if (_done)
                return;

            _done = true;
            if (output.indexOf("Apache Ant(TM) version") > -1) {
                settings.antEnabled = true;
                result(true);
            } else {
                settings.antEnabled = false;
                error(false);
            }
        }

        override protected function outputDataHandler(event:ProgressEvent):void {
            super.outputDataHandler(event);
            extractVersion(standardOutput);
        }

        override protected function errorDataHandler(event:ProgressEvent):void {
            super.errorDataHandler(event);
            extractVersion(standardError);
        }
    }
}
