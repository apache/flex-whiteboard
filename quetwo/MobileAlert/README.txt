////////////////////////////////////////////////////////////////////////////////
//
//  Licensed to the Apache Software Foundation (ASF) under one or more
//  contributor license agreements.  See the NOTICE file distributed with
//  this work for additional information regarding copyright ownership.
//  The ASF licenses this file to You under the Apache License, Version 2.0
//  (the "License"); you may not use this file except in compliance with
//  the License.  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
////////////////////////////////////////////////////////////////////////////////

Component contributed by Nick Kwiatkowski (quetwo@apache.org)

Mobile Spark Alert Dialog Box (org.apache.skark.components.Alert)

Usage of this component is very similar to the mx.controls.Alert, in that you use the static
MobileAlert.show() method to launch a new alert dialog box.  The usage of the show method is
identical to the mx component, with the following exception :
  - The final parameter of the mx component (moduleFactory:IFlexModuleFactory) is not available.
  - The new final parameter of this component is the replacement skin that you wish to use.  
  
If you use this in other locales other than en_US, you will need to add the proper resource bundles.

3/15/2012 Notes :
  - iOS Skin was not included.  It will be during a later push
  - Android Skin needs some touching in order to make it look right on all dpi's
  - Need to add a buttonSkin for the OK/Cancel/YES/NO buttons.  Some properties are hard-coded right now.
  
   