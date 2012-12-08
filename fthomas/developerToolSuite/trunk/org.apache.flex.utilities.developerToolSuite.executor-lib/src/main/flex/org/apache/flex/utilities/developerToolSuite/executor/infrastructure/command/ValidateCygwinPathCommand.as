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
    import org.apache.flex.utilities.developerToolSuite.executor.infrastructure.message.ValidateCygwinPathMessage;
    import org.apache.flex.utilities.developerToolSuite.executor.infrastructure.nativeProcess.NativeShellHelper;
    import org.apache.flex.utilities.developerToolSuite.executor.infrastructure.util.LogUtil;

    public class ValidateCygwinPathCommand {

        private static var LOG:ILogger = LogUtil.getLogger(ValidateCygwinPathCommand);

        private var _msg:ValidateCygwinPathMessage;

        [Inject]
        public var settings:SettingModel;

        public var callback:Function;

        private var _done:Boolean;

        public function execute(msg:ValidateCygwinPathMessage):void {
            LOG.debug("Executing Command with message: " + ObjectUtil.toString(msg));
            _msg = msg;
            settings.cygwinEnabled = false;
            executeCommand();
        }

        protected function executeCommand():void {
            LOG.debug("Executing Command with message: " + ObjectUtil.toString(_msg));

            var file:File;

            if (!_msg.path) {
                LOG.error("Path null, nothing to check, quit");
                callback(false);
                return;
            }

            try {
                file = new File(NativeShellHelper.formatPath(_msg.path));
                if (!file.resolvePath("Cygwin.bat").exists) {
                    LOG.error("Error resolving CYGWIN_HOME");
                    callback(false);
                }
                else {
                    LOG.debug("Resolved CYGWIN_HOME");
                    settings.cygwinEnabled = true;
                }
            } catch (err:Error) {
                LOG.error("Ending Command with error: " + ObjectUtil.toString(err));
                callback(false);
            }
            ;
            LOG.debug("Ending Command with result: " + file.nativePath);
            callback(true);
        }
    }
}
