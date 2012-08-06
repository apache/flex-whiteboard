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

package spark.managers.marshalClasses
{
import flash.display.DisplayObject;
import flash.events.Event;
import flash.utils.getTimer;

import mx.core.IFlexModuleFactory;
import mx.core.UIComponent;
import mx.core.mx_internal;
import mx.events.FlexEvent;
import mx.events.InterManagerRequest;
import mx.managers.IActiveWindowManager;
import mx.managers.IFocusManagerContainer;
import mx.managers.IMarshalSystemManager;
import mx.managers.ISystemManager;
import mx.managers.SystemManagerGlobals;
import mx.managers.SystemManagerProxy;

import spark.core.IToolTip;
import spark.managers.IToolTipManagerImpl;
import spark.managers.ToolTipManager;
import spark.managers.ToolTipManagerImpl;

use namespace mx_internal;

[ExcludeClass]

[Mixin]

/**
 *  @private
 *  This class extends the functionality of ToolTipManager in
 *  Marshall Plan configurations.
 *  This class listens to the local ToolTipManager for events that
 *  will trigger its handler methods.
 *  Its handler methods create InterManagerRequests to be sent across
 *  ApplicationDomains between subapps and main apps.
 *  These InterManagerRequests are dispatched through the security sandbox's
 *  sandboxRoot system manager.
 *  This class also listens to InterManagerRequests on the sandboxRoot from
 *  other ToolTipManagers.
 */
public class ToolTipManagerMarshalMixin
{
    include "../../../mx/core/Version.as";
    
    //--------------------------------------------------------------------------
    //
    //  Class Method
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    public static function init(fbs:IFlexModuleFactory):void
    {
        if (!ToolTipManagerImpl.mixins)
            ToolTipManagerImpl.mixins = [];
        if (ToolTipManagerImpl.mixins.indexOf(ToolTipManagerMarshalMixin) == -1)
            ToolTipManagerImpl.mixins.push(ToolTipManagerMarshalMixin);
    }
    
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    public function ToolTipManagerMarshalMixin(owner:ToolTipManagerImpl = null)
    {
        super();
        
        if (!owner)
            return;
        
        _toolTipManagerImpl = owner;
        _toolTipManagerImpl.addEventListener("initialize", initializeHandler);
        _toolTipManagerImpl.addEventListener("toolTipClosed", toolTipClosedHandler);
    }
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    private var _toolTipManagerImpl:ToolTipManagerImpl;
    
    /**
     *  @private
     */	
    private var _sandboxRoot:DisplayObject;
    
    //--------------------------------------------------------------------------
    //
    //  Class Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */		
    private function initializeHandler(event:Event):void
    {
        var systemManager:ISystemManager = SystemManagerGlobals.topLevelSystemManagers[0] as ISystemManager;
        _sandboxRoot = systemManager.getSandboxRoot();
        _sandboxRoot.addEventListener(InterManagerRequest.TOOLTIP_MANAGER_REQUEST, interManagerRequestHandler, false, 0, true);
    }
    
    /**
     * 	@private
     *  Notify the other managers that this manager closed a tool tip.
     */
    private function toolTipClosedHandler(event:Event):void
    {
        var interManagerRequest:InterManagerRequest = 
            new InterManagerRequest(InterManagerRequest.TOOLTIP_MANAGER_REQUEST);
        
        interManagerRequest.name = "toolTipClosed";
        
        _sandboxRoot.dispatchEvent(interManagerRequest);
    }	
    
    /**
     *  @private
     *  Receive requests and notifications from other ToolTipManagers.
     */		
    private function interManagerRequestHandler(event:Event):void
    {
        // If the event is strongly-typed as an InterManagerRequest, 
        // then it must have come from this ApplicationDomain, and the
        // local ToolTipManager. If this is the case, do nothing because 
        // here we handle requests from other managers not the local manager.
        if (event is InterManagerRequest)
            return;
        
        var interManagerRequest:Object = event;
        var requestName:String = interManagerRequest.name;
        
        if (requestName == "toolTipClosed")
        {
            // Update the scrub delay.
            _toolTipManagerImpl.setPreviousToolTipHideTime();
        }
    }
    
}
}
