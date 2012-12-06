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
package org.apache.flex.utilities.developerToolSuite.executor.domain {
    import flash.utils.Dictionary;

    import mx.collections.ArrayCollection;

    import org.apache.flex.utilities.developerToolSuite.LocaleUtil;

    [Bindable]
    public class SettingModel {

        public function get availableLanguages():ArrayCollection {
            return new ArrayCollection(LocaleUtil.AVAILABLE_LANGUAGES);
        }

        public function get currentLanguage():Object {
            return LocaleUtil.getDefaultLanguage(locale);
        }

        public var environmentVariables:Dictionary;

        public var locale:String;

        public var JAVA_HOME:String;
        public var ANT_HOME:String;
        public var MAVEN_HOME:String;

        public var javaEnabled:Boolean;
        public var antEnabled:Boolean;
        public var mavenEnabled:Boolean;
    }
}
