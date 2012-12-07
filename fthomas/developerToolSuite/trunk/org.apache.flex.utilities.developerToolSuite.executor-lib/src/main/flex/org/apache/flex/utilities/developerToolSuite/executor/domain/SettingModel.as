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

    public class SettingModel implements ISettingsModel {

        public function get availableLanguages():ArrayCollection {
            return new ArrayCollection(LocaleUtil.AVAILABLE_LANGUAGES);
        }

        public function get currentLanguage():Object {
            return LocaleUtil.getDefaultLanguage(_locale);
        }

        private var _environmentVariables:Dictionary;

        private var _locale:String;

        private var _JAVA_HOME:String;
        private var _ANT_HOME:String;
        private var _MAVEN_HOME:String;

        private var _javaEnabled:Boolean;
        private var _antEnabled:Boolean;
        private var _mavenEnabled:Boolean;

        private var _svnEnabled:Boolean;
        private var _gitEnabled:Boolean;

        private var _appBounds:String;
        private var _appDisplayState:String;

        public function get environmentVariables():Dictionary {
            return _environmentVariables;
        }

        [Bindable]
        public function set environmentVariables(value:Dictionary):void {
            _environmentVariables = value;
        }

        public function get locale():String {
            return _locale;
        }

        [Bindable]
        public function set locale(value:String):void {
            _locale = value;
        }

        public function get JAVA_HOME():String {
            return _JAVA_HOME;
        }

        [Bindable]
        public function set JAVA_HOME(value:String):void {
            _JAVA_HOME = value;
        }

        public function get ANT_HOME():String {
            return _ANT_HOME;
        }

        [Bindable]
        public function set ANT_HOME(value:String):void {
            _ANT_HOME = value;
        }

        public function get MAVEN_HOME():String {
            return _MAVEN_HOME;
        }

        [Bindable]
        public function set MAVEN_HOME(value:String):void {
            _MAVEN_HOME = value;
        }

        public function get javaEnabled():Boolean {
            return _javaEnabled;
        }

        [Bindable]
        public function set javaEnabled(value:Boolean):void {
            _javaEnabled = value;
        }

        public function get antEnabled():Boolean {
            return _antEnabled;
        }

        [Bindable]
        public function set antEnabled(value:Boolean):void {
            _antEnabled = value;
        }

        public function get mavenEnabled():Boolean {
            return _mavenEnabled;
        }

        [Bindable]
        public function set mavenEnabled(value:Boolean):void {
            _mavenEnabled = value;
        }

        public function get svnEnabled():Boolean {
            return _svnEnabled;
        }

        [Bindable]
        public function set svnEnabled(value:Boolean):void {
            _svnEnabled = value;
        }

        public function get gitEnabled():Boolean {
            return _gitEnabled;
        }

        [Bindable]
        public function set gitEnabled(value:Boolean):void {
            _gitEnabled = value;
        }

        public function get appBounds():String {
            return _appBounds;
        }

        [Bindable]
        public function set appBounds(value:String):void {
            _appBounds = value;
        }

        public function get appDisplayState():String {
            return _appDisplayState;
        }

        [Bindable]
        public function set appDisplayState(value:String):void {
            _appDisplayState = value;
        }
    }
}
