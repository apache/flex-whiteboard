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
    import flash.data.SQLResult;

    import mx.resources.ResourceManager;
    import mx.utils.ObjectUtil;

    import org.apache.flex.utilities.developerToolSuite.LocaleUtil;
    import org.apache.flex.utilities.developerToolSuite.executor.domain.SettingModel;
    import org.apache.flex.utilities.developerToolSuite.executor.infrastructure.message.ApplicationReadyMessage;
    import org.apache.flex.utilities.developerToolSuite.executor.infrastructure.message.InitApplicationMessage;

    public class GetSettingsFromDBCommand extends AbstractDBCommand {

        [Inject]
        public var settings:SettingModel;

        public function execute(msg:InitApplicationMessage):void {
            executeAsync();
        }

        override protected function prepareSql():void {
            sql = "SELECT name, value FROM settings;";
            super.prepareSql();
        }

        override protected function result(result:SQLResult):void {
            var row:Object;

            if (result.data) {
                var numResults:int = result.data.length;
                for (var i:int = 0; i < numResults; i++) {
                    row = result.data[i];
                    settings[row.name] = row.value;
                }
            }

            if (settings.locale == null) {
                settings.locale = LocaleUtil.getDefaultLanguage().data;
            }
            ResourceManager.getInstance().localeChain = LocaleUtil.getOrderedLocalChain(settings.locale);
            dispatch(new ApplicationReadyMessage());

            var resultMessage:String = (result.data != null) ? ObjectUtil.toString(result.data) : result.rowsAffected + " affected row(s)";
            log.debug("Successfully executed shell: " + resultMessage);

            callback(new CommandCallBackResult(settings));
        }
    }
}
