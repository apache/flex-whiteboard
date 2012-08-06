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

package mx.managers
{

import mx.core.IFlexDisplayObject;

/**
 *  Components that implement IToolTipManagerClient can have tool tips and must 
 *  have a toolTip getter/setter and toolTipData getter/setter.
 *  The ToolTipManager class manages showing and hiding the 
 *  tool tip on behalf of any component which is an IToolTipManagerClient.
 *  The Spark ToolTipManager queries the component's toolTipData getter to
 *  display the component's tool tip.
 *  If using the Spark ToolTipManager, the component should also be a
 *  DisplayObjectContainer in addtion to an IToolTipManagerClient.
 *  The Spark ToolTipManager will call the component's getStyle method to
 *  determine the component's tool tip configuration, defined by 
 *  the toolTipClass, toolTipShowDelay, toolTipHideDelay, and toolTipScrubDelay
 *  styles.
 *  The MX ToolTipManager queries the component's toolTip getter to
 *  display the component's tool tip.
 *  The string returned by the toolTip getter is used for accessibility.
 * 
 *  @see mx.controls.ToolTip
 *  @see mx.managers.ToolTipManager
 *  @see mx.core.IToolTip
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public interface IToolTipManagerClient extends IFlexDisplayObject
{
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  toolTip
    //----------------------------------
    
    /**
     *  The text of this component's tooltip.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function get toolTip():String;
    
    /**
     *  @private
     */
    function set toolTip(value:String):void;
    
    /**
     *  Arbitrary data to render in this component's Spark ToolTip. 
     *  This may be a String or any other object. 
     *
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5
     */		
    function get toolTipData():Object
    
    /**
     *  @private
     */
    function set toolTipData(value:Object):void; 
    
    /**
     *  @copy mx.core.UIComponent#getStyle()
     *
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5
     */
    function getStyle(styleProp:String):*;
}

}
