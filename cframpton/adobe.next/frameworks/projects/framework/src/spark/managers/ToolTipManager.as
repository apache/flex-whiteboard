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

package spark.managers
{

import flash.events.EventDispatcher;

import mx.core.Singleton;
import mx.managers.IToolTipManagerClient;

import spark.core.IToolTip;

/**
 *  The ToolTipManager lets you disable tool tips and access the currently
 *  displayed tool tip.
 * 
 *  <p>Only one tool tip can be displayed at a time. 
 *  The ToolTipManager is responsible for showing and hiding tool tips.
 *  </p>
 * 
 *  <p>The tool tip is responsible for positioning itself and defining
 *  its transition effects.</p>
 *
 *  @see spark.components.ToolTip
 * 
 *  @langversion 3.0
 *  @playerversion Flash 11
 *  @playerversion AIR 3
 *  @productversion Flex 5.0
 */
public class ToolTipManager extends EventDispatcher
{
    include "../../mx/core/Version.as";
    
    //--------------------------------------------------------------------------
    //
    //  Class variables
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Linker dependency on implementation class.
     */
    private static var _implClassDependency:ToolTipManagerImpl;
    
    /**
     *  @private
     *  Storage for the impl getter.
     *  This gets initialized on first access,
     *  not at static initialization time, in order to ensure
     *  that the Singleton registry has already been initialized.
     */
    private static var _impl:IToolTipManagerImpl;
    
    /**
     *  @private
     *  The singleton instance of ToolTipManagerImpl which was
     *  registered as implementing the IToolTipManagerImpl interface.
     */
    private static function get impl():IToolTipManagerImpl
    {
        if (!_impl)
            _impl = IToolTipManagerImpl(Singleton.getInstance("spark.managers::IToolTipManagerImpl"));
        
        return _impl;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Class Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  enabled
    //----------------------------------
    
    /**
     *  If <code>true</code>, the ToolTipManager will automatically 
     *  show tool tips when the user moves the mouse pointer over 
     *  components.
     *  If <code>false</code>, the ToolTipManager will not show
     *  tool tips.
     *
     *  @default true
     *  
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3
     *  @productversion Flex 5.0
     */
    public static function get enabled():Boolean
    {
        return impl.enabled;
    }
    
    /**
     *  @private
     */
    public static function set enabled(value:Boolean):void
    {
        impl.enabled = value;
    }	
    
    //----------------------------------
    //  currentTarget
    //----------------------------------

    /**
     *  The UIComponent that is currently displaying a tool tip or is
     *  scheduled to display a tool tip when the show delay elapses.
     *  This property is <code>null</code> if no tool tip is shown or scheduled.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3
     *  @productversion Flex 5.0
     */
    public static function get currentTarget():IToolTipManagerClient
    {
        return impl.currentTarget;
    }
    
    /**
     *  @private
     */
    public static function set currentTarget(value:IToolTipManagerClient):void
    {
        impl.currentTarget = value;
    }
    
    //----------------------------------
    //  currentToolTip
    //----------------------------------

    /**
     *  The tool tip that is currently visible,
     *  or <code>null</code> if none is shown.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3
     *  @productversion Flex 5.0
     */
    public static function get currentToolTip():IToolTip
    {
        return impl.currentToolTip;
    }
    
    /**
     *  @private
     */
    public static function set currentToolTip(value:IToolTip):void
    {
        impl.currentToolTip = value;
    }		
    
    //----------------------------------------------------------------------
    //
    //  Class Methods
    //
    //----------------------------------------------------------------------		
    
    //----------------------------------------------
    //  Component registration / deregistration
    //----------------------------------------------
    
    /**
     *  Registers a target UIComponent with the ToolTipManager. 
     *  This causes the ToolTipManager to display a tool tip when the
     *  mouse hovers over the target. 
     * 
     * 	<p>When popping up a new ToolTip, the 
     *  ToolTipManager passes the target's toolTipData 
     *  property to the ToolTip it creates. 
     *  The ToolTip's skin then renders the data for display.</p>
     *
     *  <p>This method may be called by UIComponent's setter for the toolTipData 
     *  property.</p>
     *
     *  @param target The UIComponent that owns the tool tip.
     *  
     *  @see mx.core.UIComponent
     * 
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3
     *  @productversion Flex 5.0
     */
    public static function registerTarget(target:IToolTipManagerClient):void
    {
        impl.registerTarget(target);
    }
    
    /**
     *  Unregisters a target UIComponent with the ToolTipManager. 
     *  The ToolTipManager will no longer pop up tool tips for the 
     *  target component. 
     *
     *  <p>This method may be called by UIComponent's setter for the toolTipData
     *  property.</p>
     * 
     *  @param target The UIComponent that owns the tool tip.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3
     *  @productversion Flex 5.0
     */			
    public static function unregisterTarget(target:IToolTipManagerClient):void
    {
        impl.unregisterTarget(target);
    }
}
}
