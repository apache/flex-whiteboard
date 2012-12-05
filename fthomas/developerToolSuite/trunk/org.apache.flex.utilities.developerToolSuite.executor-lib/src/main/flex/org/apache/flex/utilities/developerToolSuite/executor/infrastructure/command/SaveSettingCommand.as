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
    import mx.resources.ResourceManager;

    import org.apache.flex.utilities.developerToolSuite.LocaleUtil;
    import org.apache.flex.utilities.developerToolSuite.executor.domain.SettingModel;
    import org.apache.flex.utilities.developerToolSuite.executor.infrastructure.message.ChangeLanguageMessage;
    import org.apache.flex.utilities.developerToolSuite.executor.infrastructure.message.SaveSettingMessage;

    public class SaveSettingCommand extends AbstractDBCommand {

        private var _msg:SaveSettingMessage;

        [Inject]
        public var settings:SettingModel;

        public function execute(msg:SaveSettingMessage):void {
            this._msg = msg;
            executeAsync();
        }

        override protected function prepareSql():void {
            settings[_msg.name] = _msg.value;
            sql = "UPDATE settings SET value='" + _msg.value + "' WHERE name='" + _msg.name +"';";

            super.prepareSql();
        }
    }
}
