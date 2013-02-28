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
    import mx.utils.ObjectUtil;

    import org.apache.flex.utilities.developerToolSuite.executor.domain.ISettingsToSave;
    import org.apache.flex.utilities.developerToolSuite.executor.domain.ISettingsValidationInProgressModel;
    import org.apache.flex.utilities.developerToolSuite.executor.infrastructure.message.SaveSettingsMessage;
    import org.spicefactory.lib.reflect.ClassInfo;
    import org.spicefactory.lib.reflect.Property;

    public class SaveSettingsCommand extends AbstractDBCommand {

        private var _msg:SaveSettingsMessage;

        public function execute(msg:SaveSettingsMessage):void {
            log.debug("Executing Command with message: " + ObjectUtil.toString(msg));
            this._msg = msg;
            executeAsync();
        }

        override protected function prepareSql():void {
            var property:String;
            sql = "";
            for (property in _msg.settings) {
                sql += "UPDATE setting SET value='" + _msg.settings[property] + "' WHERE name='" + property + "';";
            }

            super.prepareSql();
        }
    }
}
