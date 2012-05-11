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

Component contributed by Jeffry Houser (jhouser@apache.org)
Date: 5/11/2012


What is This:

This is an "extended" approach to the ToggleSwitch component.  The primary purpose is 
to make it easy to change the text for the selected label and the unselected label. 
In the intiial rendition from Adobe Flex; a new skin had to be created to change 
these two properties. 

There are two properties added to the ToggleSwitch to help this happen:

selectedLabel
unselectedLabel

The modified ToggleSwitch also exposes two new skin parts:

selectedLabelDisplay
unselectedLabelDisplay

These components were already in the default ToggleSwitchSkin, but not exposed as SkinParts. 
The components use a custom class LabelDisplayComponent which was originally defined in the ToggleSkin, 
but is now separated out into a custom class for use outside of the skin.

The Code/Projects:

The contents contains library code and a sample application.  The sample application specifies the 
same default styles for our extended ToggleSwitch that are specified in the mobile theme for the default
ToggleSwitch.  


How to move into Main Branch:

If the Apache Flex team wanted to merge this into the main SDK, I percieve these are the things needed to be 
done:

Merge "extended" ToggleSwitch code into ToggleSwitch of main branch
* Move new Skin PArts
* Move PartAdded Method
* Move new properties
* move commitProperties method

Add LabelDisplayComponent class to the main branch

Merge "extended" ToggleSwitchSkin code into the ToggleSwitchSkin code of main branch:
* I think this is just the removal of the LabelDisplayComponent
