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
package org.apache.flex.utilities.developerToolSuite.presentation.graphic.menu {
    import mx.resources.ResourceManager;

    public class ProjectMenu {

        private static function getLocalizedLabel(label:String):String {
            return ResourceManager.getInstance().getString('Application', label);
        }

        public static function get PROJECT():String {
            return getLocalizedLabel('PROJECT');
        }

        public static function get NEW_PROJECT():String {
            return getLocalizedLabel('NEW_PROJECT');
        }

        public static function get OPEN_PROJECT():String {
            return getLocalizedLabel('OPEN_PROJECT');
        }

        public static function get CLOSE_PROJECT():String {
            return getLocalizedLabel('CLOSE_PROJECT');
        }

        public static function get REMOVE_PROJECT():String {
            return getLocalizedLabel('REMOVE_PROJECT');
        }
    }
}
