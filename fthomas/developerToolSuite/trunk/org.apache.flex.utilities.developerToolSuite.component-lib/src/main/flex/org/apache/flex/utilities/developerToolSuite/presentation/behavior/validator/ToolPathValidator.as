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
package org.apache.flex.utilities.developerToolSuite.presentation.behavior.validator {
    import mx.core.UIComponent;
    import mx.managers.IFocusManagerComponent;
    import mx.validators.ValidationResult;
    import mx.validators.Validator;

    public class ToolPathValidator extends Validator {

        [Bindable]
        public var errorStringResourceString:String;

        public function ToolPathValidator() {
            super();
        }

        // Class should override the doValidation() method.
        //doValidation method should accept an Object type parameter
        override protected function doValidation(value:Object):Array {
            // create an array to return.
            var validatorResults:Array = [];
            // Call base class doValidation().
            validatorResults = super.doValidation(value);
            // Return if there are errors.
            if (validatorResults.length > 0) {
                return validatorResults;
            }

            if (Boolean(value) == false) {
                validatorResults.push(new ValidationResult(true, null, "Tool Home Path Error",
                                                           resourceManager.getString('SettingsWindow', errorStringResourceString)));

                IFocusManagerComponent(trigger).setFocus();

                return validatorResults;
            }

            return validatorResults;
        }

        override protected function resourcesChanged():void {
            super.resourcesChanged();

            // Re-validate to get the localized error string displayed correctly.
            validate();
        }
    }
}

