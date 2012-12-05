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
    import flash.filesystem.File;

    import mx.logging.ILogger;
    import mx.utils.ObjectUtil;

    import org.apache.flex.utilities.developerToolSuite.executor.infrastructure.message.ValidateJavaHomePathMessage;
    import org.apache.flex.utilities.developerToolSuite.executor.infrastructure.util.LogUtil;

    public class ValidateJavaHomePathCommand {

        private static var LOG:ILogger = LogUtil.getLogger(ValidateAntHomePathCommand);

        public function ValidateJavaHomePathCommand(msg:ValidateJavaHomePathMessage) {
            LOG.debug("Executing Command with message: " + ObjectUtil.toString(msg));
            try {
                var file:File = new File(msg.path.replace("\\", "/"));
                if (!file.resolvePath("lib/tools.jar").exists) {
                    LOG.error("Error resolving ANT_HOME");
                    msg.responder.fault(false);
                    return
                }
            } catch (err:Error) {
                LOG.error(ObjectUtil.toString(err));
                msg.responder.fault(false);
                return
            }
            LOG.info("Successfully executed command")
            msg.responder.result(true);
        }
    }
}
