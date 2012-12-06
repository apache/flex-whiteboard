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
    import flash.utils.Dictionary;

    import org.apache.flex.utilities.developerToolSuite.executor.domain.SettingModel;

    public class GetEnvironmentVariablesCommand extends AbstractShellCommand {

        [Inject]
        public var settings:SettingModel;

        public function execute():void {
            executeCommand();
        }

        override protected function executeCommand():void {

            if (shell.OS == "win") {
                command.push("/C");
                command.push("set");
            }
            else command.push("env");

            super.executeCommand();
        }

        private function extractVariables(output:String):void {
            settings.environmentVariables = new Dictionary();

            var rows:Array = output.split("\r\n");
            for each (var row:String in rows) {
                var tuple:Array = row.split("=");
                settings.environmentVariables[tuple[0]] = tuple[1];
            }
            result(settings.environmentVariables);
        }

        override protected function outputDataHandler(event:ProgressEvent):void {
            super.outputDataHandler(event);
            extractVariables(standardOutput);
        }
    }
}
