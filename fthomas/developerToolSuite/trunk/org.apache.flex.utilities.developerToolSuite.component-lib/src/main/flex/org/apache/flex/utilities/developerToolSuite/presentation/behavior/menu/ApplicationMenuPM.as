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
package org.apache.flex.utilities.developerToolSuite.presentation.behavior.menu {
    import flash.utils.getDefinitionByName;

    import org.apache.flex.utilities.developerToolSuite.presentation.graphic.menu.GeneralMenu;
    import org.apache.flex.utilities.developerToolSuite.presentation.graphic.menu.ProjectMenu;
    import org.spicefactory.parsley.core.context.Context;
    import org.spicefactory.parsley.core.context.DynamicObject;

    public class ApplicationMenuPM implements IApplicationMenuPM {

        private static var linkageEnforcer:Array = [ProjectMenu, GeneralMenu];

        private static const menuXml:XML = <root>
            <menuitem menuClass='org.apache.flex.utilities.developerToolSuite.presentation.graphic.menu.ProjectMenu' label='PROJECT'>
                <menuitem menuClass='org.apache.flex.utilities.developerToolSuite.presentation.graphic.menu.ProjectMenu' label='NEW_PROJECT' action='newProject'/>
                <menuitem menuClass='org.apache.flex.utilities.developerToolSuite.presentation.graphic.menu.ProjectMenu' label='OPEN_PROJECT' action='openProject'/>
                <menuitem menuClass='org.apache.flex.utilities.developerToolSuite.presentation.graphic.menu.ProjectMenu' label='CLOSE_PROJECT' action='closeProject'/>
                <menuitem menuClass='org.apache.flex.utilities.developerToolSuite.presentation.graphic.menu.ProjectMenu' label='REMOVE_PROJECT' action='removeProject'/>
                <menuitem type='separator'/>
                <menuitem menuClass='org.apache.flex.utilities.developerToolSuite.presentation.graphic.menu.GeneralMenu' label='SETTINGS' action='openSettings'/>
                <menuitem type='separator'/>
                <menuitem menuClass='org.apache.flex.utilities.developerToolSuite.presentation.graphic.menu.GeneralMenu' label='QUIT' action='quit'/>
            </menuitem>
        </root>;

        [Inject]
        public var context:Context;

        public function get dataProvider():XML {
            return menuXml;
        }

        public function getMenuItemLabel(item:Object):String {

            var label:String;
            try {
                var menuItemClass:Class = getDefinitionByName(item.@menuClass) as Class;
                label = menuItemClass[item.@label];
            } catch (err:Error) {
                trace("Erreur: " + err.message + "\n" + err.getStackTrace());
            }
            ;

            return label == null ? item.@label : label;
        }

        public function doMenuAction(item:Object):void {
            var menuItemClass:Class = getDefinitionByName(item.@menuClass) as Class;
            var dynamicObject:DynamicObject = context.createDynamicObjectByType(menuItemClass);
            var instance:Object = dynamicObject.instance;
            instance[item.@action](item);
        }
    }
}
