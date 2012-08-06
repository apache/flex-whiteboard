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

import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.utils.Timer;
import flash.utils.getTimer;

import mx.core.mx_internal;
import mx.managers.IToolTipManagerClient;

import spark.core.IToolTip;

use namespace mx_internal;

[ExcludeClass]

/**
 *  @private
 */
public class ToolTipManagerImpl extends EventDispatcher implements IToolTipManagerImpl
{
    include "../../mx/core/Version.as";
    
    //--------------------------------------------------------------------------
    //
    //  Class variables
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     * 
     *  Place to hook in additional classes.
     */
    public static var mixins:Array;
    
    /**
     *  @private
     */
    private static var _instance:IToolTipManagerImpl;
    
    //--------------------------------------------------------------------------
    //
    //  Class methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  This is called by Singleton.getInstance(interfaceName).
     */
    public static function getInstance():IToolTipManagerImpl
    {
        if (!_instance)
            _instance = new ToolTipManagerImpl();
        
        return _instance;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    public function ToolTipManagerImpl()
    {
        super();
        
        if (_instance)
            throw new Error("Instance already exists.");
        
        if (mixins)
        {
            var n:int = mixins.length;
            for (var i:int = 0; i < n; i++)
            {
                new mixins[i](this);
            }
        }
        
        if (hasEventListener("initialize"))
            dispatchEvent(new Event("initialize"));
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  enabled
    //----------------------------------
    
    /**
     * 	@private
     */
    private var _enabled:Boolean = true;
    
    /**
     *  @private
     */
    public function get enabled():Boolean
    {
        return _enabled;
    }
    
    /**
     *  @private
     */
    public function set enabled(value:Boolean):void
    {
        _enabled = value;
    }	
    
    //----------------------------------
    //  currentTarget
    //----------------------------------
    
    /**
     *  @private
     */
    private var _currentTarget:IToolTipManagerClient;
    
    /**
     *  @private
     */
    public function get currentTarget():IToolTipManagerClient
    {
        return _currentTarget;
    }
    
    /**
     *  @private
     */
    public function set currentTarget(value:IToolTipManagerClient):void
    {
        _currentTarget = value;
    }
    
    //----------------------------------
    //  currentToolTip
    //----------------------------------
    
    /**
     * 	@private
     */
    private var _currentToolTip:IToolTip;		
    
    /**
     *  @private
     */
    public function get currentToolTip():IToolTip
    {
        return _currentToolTip;
    }
    
    /**
     *  @private
     */
    public function set currentToolTip(value:IToolTip):void
    {
        _currentToolTip = value;
    }		
    
    //----------------------------------------------------------------------
    //
    //  Variables
    //
    //----------------------------------------------------------------------
    
    /**
     *  @private
     *  A flag that keeps track of whether this class's initializeIfNeeded()
     *  method has been executed.
     */
    private var _isInitialized:Boolean = false;
    
    /**
     *  @private
     *  This timer is used to delay the appearance of a tool tip
     *  after the mouse moves over a target.
     *
     *  <p>This timer is started when the mouse moves over a registered 
     *  component, with a duration specified by showDelay.
     *  If the mouse moves out of this object before the timer fires,
     *  the tool tip is never created.
     *  If the mouse stays over the object until the timer fires,
     *  the tool tip is created and popped up.
     */
    private var _showTimer:Timer;
    
    /**
     *  @private
     *  This timer is used to make the tooltip "time out" and hide itself
     *  if the mouse stays over a target.
     */
    private var _hideTimer:Timer;
    
    /**
     *  @private
     *  This timestamp is used for the scrub delay, to determine whether
     *  the current target's tool tip should be shown immediately.
     */
    private var _previousToolTipHideTime:int; /* milliseconds */
    
    //----------------------------------------------------------------------
    //
    //  Methods
    //
    //----------------------------------------------------------------------		
    
    //----------------------------------------------
    //  Component registration / deregistration
    //----------------------------------------------
    
    /**
     *  @private
     */
    public function registerTarget(target:IToolTipManagerClient):void
    {
        initializeIfNeeded();
        target.addEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
        target.addEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
    }
    
    /**
     *  @private
     */		
    public function unregisterTarget(target:IToolTipManagerClient):void
    {
        target.removeEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
        target.removeEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
    }
    
    //----------------------------------
    //  Initialization
    //----------------------------------
    
    /**
     *  @private
     *  Lazy initialization.
     *  Occurs when the first target component is registered.
     */
    private function initializeIfNeeded():void
    {
        if (_isInitialized)
            return;
        
        initializeTimers();
        
        _isInitialized = true;
        
        // Notify any mixins.
        if (hasEventListener("initialize"))
            dispatchEvent(new Event("initialize"));
    }
    
    //----------------------------------
    //  Opening tool tips
    //----------------------------------		
    
    /**
     *  @private
     *  Opens a tool tip immediately or schedules a tooltip to be opened
     *  for the current target, depending on the show delay and scrub delay.
     */
    private function showOrScheduleToolTip():void
    {
        if (!currentTarget)
            return;       
        
        // If for example, the showDelay == 0 and the hideDelay == 0, 
        // don't show the tool tip at all.
        var shouldShowToolTip:Boolean = !isInfiniteDelay(showDelay) && !isZeroDelay(hideDelay);
        if (!shouldShowToolTip)
            return;
        
        var shouldShowToolTipImmediately:Boolean = isZeroDelay(showDelay) || isScrubbing;
        if (shouldShowToolTipImmediately)
            showToolTipImmediately();
        else
            scheduleToolTip();
    }
    
    /**
     *  @private
     *  Opens a tool tip immediately for the current target.
     *  If the target component's toolTipData getter returns null, don't show 
     *  the tool tip. 
     */
    private function showToolTipImmediately():void
    {	
        if (!currentTarget)
            return;
        
        var toolTipData:Object = currentTarget.toolTipData;
        if (!toolTipData)
            return;
        
        currentToolTip = new toolTipClass();
        currentToolTip.data = toolTipData;
        
        currentToolTip.addEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
        currentToolTip.addEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
        
        currentToolTip.showToolTip(currentTarget);
        
        if (!isInfiniteDelay(hideDelay))
            startHideDelay(hideDelay);
    }
    
    /**
     *  @private
     */
    private function scheduleToolTip():void
    {		
        if (!currentTarget)
            return;
        
        startShowDelay(showDelay);
    }
    
    //----------------------------------
    //  Closing tool tips
    //----------------------------------		
    
    /**
     *  @private
     */
    private function hideOrUnscheduleToolTip():void
    {
        hideToolTipImmediately();
        unscheduleToolTip();
    }
    
    /**
     *  @private
     */
    private function hideToolTipImmediately():void
    {
        if (!currentToolTip)
            return;	
        
        currentToolTip.removeEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
        currentToolTip.removeEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
        
        currentToolTip.hideToolTip();
        currentToolTip = null;
        
        currentTarget = null;
        
        // Stop any leftover hide delay.
        stopHideDelay();
        
        _previousToolTipHideTime = getTimer();
        
        // Dispatch an event that we've closed the tool tip.
        // This is picked up by the marshal mixin, which notifies the other
        // ToolTipManagers in sibling ApplicationDomains.
        if (hasEventListener("toolTipClosed"))
            dispatchEvent(new Event("toolTipClosed"));		
    }
    
    /**
     *  @private
     */
    private function unscheduleToolTip():void
    {
        if (!isToolTipScheduled)
            return;
        
        stopShowDelay();
        
        currentTarget = null;
    }
    
    /**
     * @private
     * Returns true if the potential child is equal to the parent 
     * or is in the parent's display list.
     */
    private function isChildOfParent(potentialChild:DisplayObject, parent:DisplayObject):Boolean
    {
        // If there is no parent, there can't be a child of it.
        if (!parent)
            return false;
        
        // Start at the child.
        var currentParent:DisplayObject = potentialChild;
        while (currentParent)
        {
            if (currentParent == parent)
                return true;
            
            // Move up the display tree.
            currentParent = currentParent.parent;
        }
        
        return false;
    }
    
    //----------------------------------
    //  Timer management
    //----------------------------------	
    
    /**
     *  @private
     */
    private function initializeTimers():void
    {
        _showTimer = new Timer(0, 1);
        _showTimer.addEventListener(TimerEvent.TIMER, showTimerHandler);
        
        _hideTimer = new Timer(0, 1);
        _hideTimer.addEventListener(TimerEvent.TIMER, hideTimerHandler);
        
        setPreviousToolTipHideTime();
    }
    
    /**
     *  @private
     */
    private function get isToolTipScheduled():Boolean
    {
        return _showTimer.running;
    }	
    
    /**
     *  @private
     */
    private function get isScrubbing():Boolean
    {
        return timeSincePreviousToolTip < scrubDelay;
    }
    
    /**
     *  @private
     */
    private function get timeSincePreviousToolTip():int
    {
        // In case getTimer rolled over and is counting in the negative range,
        // take the absolute value.
        var delta:int = getTimer() - _previousToolTipHideTime;
        return delta > 0 ? delta : -delta;
    }
    
    /**
     *  @private
     */
    mx_internal function setPreviousToolTipHideTime():void
    {
        _previousToolTipHideTime = getTimer();
    }
    
    /**
     *  @private
     */
    private function startShowDelay(showDelay:Number):void
    {
        startTimerWithDelay(_showTimer, showDelay);
    }
    
    /**
     *  @private
     */
    private function stopShowDelay():void
    {
        stopTimer(_showTimer);
    }
    
    /**
     *  @private
     */
    private function startHideDelay(hideDelay:Number):void
    {
        startTimerWithDelay(_hideTimer, hideDelay);	
    }
    
    /**
     *  @private
     */
    private function stopHideDelay():void
    {
        stopTimer(_hideTimer);
    }
    
    /**
     *  @private
     */
    private function startTimerWithDelay(timer:Timer, delay:Number):void
    {
        timer.reset();
        timer.delay = delay;
        timer.start();
    }
    
    /**
     *  @private
     */
    private function stopTimer(timer:Timer):void
    {
        timer.stop();
    }
    
    //----------------------------------
    //  Fetching styles
    //----------------------------------
    
    /**
     *  @private
     */    
    private function get toolTipClass():Class
    {
        return getCurrentTargetStyle("toolTipClass");
    }
    
    /**
     *  @private
     */    
    private function get showDelay():Number
    {
        return getCurrentTargetStyle("toolTipShowDelay");
    }
    
    /**
     *  @private
     */    
    private function get hideDelay():Number
    {
        return getCurrentTargetStyle("toolTipHideDelay");
    }
    
    /**
     *  @private
     */    
    private function get scrubDelay():Number
    {
        return getCurrentTargetStyle("toolTipScrubDelay");
    }
    
    /**
     *  @private
     */
    private function getCurrentTargetStyle(styleName:String):*
    {
        return currentTarget.getStyle(styleName);
    }
    
    //----------------------------------
    //  Interpreting delay
    //----------------------------------
    
    /**
     *  @private
     *  Any value from negative infinity up to 0 means do something immediately.
     */
    private function isZeroDelay(delay:Number):Boolean
    {
        return delay <= 0;   
    }
    
    /**
     *  @private
     *  Positive infinity or NaN means never do something.
     */
    private function isInfiniteDelay(delay:Number):Boolean
    {
        return delay == Number.POSITIVE_INFINITY
            || isNaN(delay);
    }
    
    //--------------------------------------------------------------------------
    //
    //  Event handlers
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  Timer event handlers
    //----------------------------------
    
    /**
     *  @private
     */
    private function showTimerHandler(event:TimerEvent):void
    {
        showToolTipImmediately();
    }
    
    /**
     *  @private
     */
    private function hideTimerHandler(event:TimerEvent):void
    {
        hideToolTipImmediately();
    }
    
    //----------------------------------
    //  Mouse event handlers
    //----------------------------------
    
    /**
     *  @private
     *  Handler for roll overs on registered UIComponents and the tool tip,
     *  if shown.
     *  Tool tips will only be shown if the ToolTipManager is enabled.
     */
    private function rollOverHandler(event:MouseEvent):void
    {
        if (!enabled)
            return;
        
        // event.currentTarget will always be a registered target component 
        // or the tool tip.
        var isOverCurrentToolTipNow:Boolean = event.currentTarget == currentToolTip;
        var isOverCurrentTargetNow:Boolean = event.currentTarget == currentTarget;
        
        // If the mouse is still over the current target or tool tip, 
        // change nothing.
        if (isOverCurrentToolTipNow || isOverCurrentTargetNow)
            return;
        
        // Show a tool tip for the new target.
        currentTarget = event.currentTarget as IToolTipManagerClient;
        showOrScheduleToolTip();
    }
    
    /**
     *  @private
     *  Handler for roll outs on registered UIComponents and the tool tip,
     *  if shown.
     */
    private function rollOutHandler(event:MouseEvent):void
    {
        // event.relatedObject can be a child display object 
        // of a registered target component or the tool tip.
        var isOverCurrentToolTipNow:Boolean = isChildOfParent(event.relatedObject, currentToolTip as DisplayObject);
        var isOverCurrentTargetNow:Boolean = isChildOfParent(event.relatedObject, currentTarget as DisplayObject);
        
        // If the mouse is still over the current target or tool tip, 
        // change nothing.
        if (isOverCurrentToolTipNow || isOverCurrentTargetNow)
            return;
        
        // Hide or unschedule the current tool tip.
        hideOrUnscheduleToolTip();
    }
}
}
