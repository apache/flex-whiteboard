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

package spark.components
{
import flash.events.Event;
import flash.events.FocusEvent;

import mx.binding.*;
import mx.core.mx_internal;
import mx.events.FlexEvent;
import mx.events.StateChangeEvent;

import spark.components.supportClasses.ToggleButtonBase;
import spark.core.ContainerDestructionPolicy;

use namespace mx_internal;

/**
 *  The AccordionContent is meant to be a child of an Accordion component. 
 *  It contains a header and the content.
 *  
 *  <p>The AccordionContent is a skinnable component. 
 *  The skin should handle positioning of the header relative 
 *  to the contents as well as animating between open and closed states.</p>
 *  
 *  <p>The AccordionContent's default skin is the VerticalAccordionContentSkin.</p>
 * 
 *  @langversion 3.0
 *  @playerversion Flash 11
 *  @playerversion AIR 3.0
 *  @productversion Flex 5.0
 */
public class AccordionContent extends NavigatorContent
{
    include "../core/Version.as";
    
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Constructor.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5.0
     */
    public function AccordionContent()
    {
        super();
        
        addEventListener("labelChanged", accordionContent_labelChangedHandler);
        addEventListener(FlexEvent.CREATION_COMPLETE, creationCompleteHandler);
    }
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    
    //--------------------------
    //  isAnimating
    //--------------------------
    
    /**
     *  @private
     */
    private var _isAnimating:Boolean = false;
    
    /**
     *  @private
     *  Indicates whether the AccordionContent is currently animating a state
     *  transition.
     * 
     *  @default false
     *  
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5.0
     */  
    mx_internal function get isAnimating():Boolean
    {
        return _isAnimating;
    }
    
    /**
     *  @private
     */
    mx_internal function set isAnimating(value:Boolean):void
    {
        _isAnimating = value;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Skin Parts
    //
    //--------------------------------------------------------------------------
    
    //--------------------------
    //  accordionHeader
    //--------------------------
    
    [Bindable]
    [SkinPart(required="false")]
    
    /**
     *  The AccordionContent's header
     * 
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3
     *  @productversion Flex 5.0
     */
    public var accordionHeader:ToggleButtonBase;
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //--------------------------
    //  selected
    //--------------------------
    
    /**
     *  @private
     *  Storage for the selected property 
     */
    private var _selected:Boolean = false;
    
    /**
     *  @private
     *  This property is <code>true</code> if the <code>accordionHeader</code> is in the down state, 
     *  and <code>false</code> if it is in the up state. It is managed by Accordion and should be
     *  treated as read only by clients.
     * 
     *  @default "false"
     *  
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5.0
     */  
    mx_internal function get selected():Boolean
    {
        return _selected;
    }
    
    /**
     *  @private
     */
    mx_internal function set selected(value:Boolean):void
    {
        if (_selected == value)
            return;
        
        _selected = value;
        
        if (accordionHeader)
            accordionHeader.selected = _selected;
        
        invalidateProperties();
        invalidateSize();
        invalidateDisplayList();
        invalidateSkinState();
        
        dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
    }
    
    //--------------------------
    //  selectedWidth
    //--------------------------
    
    /**
     *  @private
     *  Storage for the selectedWidth property
     */
    private var _selectedWidth:Number;
    
    /**
     *  The width of the AccordionContent in its selected state.
     *  It is recommended that you use this property instead of 
     *  the <code>width</code> property.
     * 
     *  @default "NaN"
     *  
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5.0
     */  
    public function get selectedWidth():Number
    {
        return _selectedWidth;
    }
    
    /**
     *  @private
     */
    public function set selectedWidth(value:Number):void
    {
        if (value == _selectedWidth)
            return;
        
        _selectedWidth = value;    
        invalidateSize();
        invalidateDisplayList();
    }
    
    //--------------------------
    //  selectedHeight
    //--------------------------
    
    /**
     *  @private
     *  Storage for the selectedHeight property
     */
    private var _selectedHeight:Number;
    
    /**
     *  The height of the AccordionContent in its selected state.
     *  It is recommended that you use this property instead of 
     *  the <code>height</code> property.
     * 
     *  @default "NaN"
     *  
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5.0
     */  
    public function get selectedHeight():Number
    {
        return _selectedHeight;
    }
    
    /**
     *  @private
     */
    public function set selectedHeight(value:Number):void
    {
        if ( value == _selectedHeight)
            return;
        
        _selectedHeight = value;    
        invalidateSize();
        invalidateDisplayList();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    override protected function measure():void
    {
        super.measure();
        
        // Calculate dimensions.
        if (selected)
        {
            // Calculate width.
            if (!isNaN(selectedWidth))
                measuredWidth = selectedWidth;
            // Otherwise, use skin width.
            
            // Calculate height.
            if (!isNaN(selectedHeight))
                measuredHeight = selectedHeight;
            // Otherwise, use skin height.
        }
        else if (accordionHeader)
        {
            measuredWidth = accordionHeader.getPreferredBoundsWidth();
            measuredHeight = accordionHeader.getPreferredBoundsHeight();
        }
        else
        {
            measuredWidth = 0;
            measuredHeight = 0;
        }
        
        // Calculate min dimensions.
        if (accordionHeader)
        {
            measuredMinWidth = accordionHeader.getMinBoundsWidth();
            measuredMinHeight = accordionHeader.getMinBoundsHeight();
        }
        else
        {
            measuredMinWidth = 0;
            measuredMinHeight = 0;
        }
    }
    
    /**
     *  @private
     */
    override protected function attachSkin():void
    {
        super.attachSkin();
        listenToSkin();        
    }
    
    /**
     *  @private
     */
    override protected function detachSkin():void
    {
        stopListeningToSkin();        
        super.detachSkin();
    }
    
    /**
     *  @inheritDoc
     * 
     *  <p><strong>Note:</strong> It is highly recommended that the 
     *  <code>selectedWidth</code> property be used instead of the <code>width</code> property. 
     *  The <code>selectedWidth</code> corresponds to the width of the AccordionContent 
     *  when the <code>selected</code> is <code>true</code>. 
     *  Setting the <code>width</code> will result in the AccordionContent being at a fixed 
     *  width regardless of which state it is in.</p>
     * 
     *  <p>Number that specifies the width of the component, in pixels, in the parent's coordinates. 
     *  The default value is 0, but this property contains the actual component width after Flex 
     *  completes sizing the components in your application. </p>
     * 
     *  <p>Note: You can specify a percentage value in the MXML width attribute, such as width="100%", 
     *  but you cannot use a percentage value in the width property in ActionScript. 
     *  Use the percentWidth property instead.</p>
     * 
     *  <p>Note: Accordion will ignore the <code>percentWidth</code> property if specified on its 
     *  children. If the AccordionContent is an element of an Accordion, 
     *  setting <code>width</code> to a percentage will have no effect.</p>
     *
     *  <p>Setting this property causes a resize event to be dispatched. See the resize event for details 
     *  on when this event is dispatched. </p>
     *
     *  <p>This property can be used as the source for data binding</p>
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4 
     */
    override public function set width(value:Number):void
    {
        super.width = Math.round(value);
    }
    
    /**
     *  @inheritDoc
     * 
     *  <p><strong>Note:</strong> It is highly recommended that the <code>selectedHeight</code> 
     *  property be used instead of the <code>height</code> property. The <code>selectedHeight</code> 
     *  corresponds to the height of the AccordionContent when the <code>selected</code> property is <code>true</code>. 
     *  Setting the <code>height</code> will result in the AccordionContent being at a fixed height 
     *  regardless of which state it is in.</p> 
     *
     *  <p>Number that specifies the height of the component, in pixels, in the parent's coordinates. 
     *  The default value is 0, but this property contains the actual component width after Flex 
     *  completes sizing the components in your application. </p>
     * 
     *  <p>Note: You can specify a percentage value in the MXML height attribute, such as height="100%", 
     *  but you cannot use a percentage value in the height property in ActionScript. 
     *  Use the percentHeight property instead.</p>
     * 
     *  <p>Note: Accordion will ignore the <code>percentHeight</code> property if specified on 
     *  its children. If the AccordionContent is an element of an Accordion, 
     *  setting <code>height</code> as a percentage will have no effect.</p>
     *
     *  <p>Setting this property causes a resize event to be dispatched. See the resize event for details 
     *  on when this event is dispatched. </p>
     *
     *  <p>This property can be used as the source for data binding</p>
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4 
     */
    override public function set height(value:Number):void
    {
        super.height = Math.round(value);
    }
    
    /**
     *  @private
     */
    override public function setActualSize(w:Number, h:Number):void
    {
        super.setActualSize(Math.round(w), Math.round(h));
    }
    
    /**
     *  @private
     */
    override public function set enabled(value:Boolean):void
    {
        super.enabled = value;
        
        if (!value && selected)
            selected = false;
        
        if (accordionHeader)
            accordionHeader.enabled = value;
        
        invalidateSkinState();
    }
    
    
    /**
     *  @private
     */
    override protected function getCurrentSkinState():String
    {
        if (selected)
            return enabled ? "open" : "openAndDisabled";
        else
            return enabled ? "normal" : "disabled";
    }
    
    /**
     *  @private
     */
    override protected function partAdded(partName:String, instance:Object):void
    {
        super.partAdded(partName, instance);
        
        if (instance == accordionHeader)
        {
            accordionHeader.label = label;
            accordionHeader.selected = selected;
            accordionHeader.focusEnabled = false;
            accordionHeader.hasFocusableChildren = false;
            
            accordionHeader.addEventListener(Event.CHANGE, accordionHeader_changeHandler);
        }
    }
    
    /**
     *  @private
     */
    override protected function partRemoved(partName:String, instance:Object):void
    {
        super.partRemoved(partName, instance);
        
        if (instance == accordionHeader)
            accordionHeader.removeEventListener(Event.CHANGE, accordionHeader_changeHandler);   
    }
    
    //--------------------------------------------------------------------------
    //
    //  Event Handlers
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    private function accordionContent_labelChangedHandler(event:Event):void
    {
        if (accordionHeader)
            accordionHeader.label = label;
        
        invalidateSize();
        invalidateDisplayList();
    }
    
    /**
     *  @private
     *  The header may toggle as a result of user interaction.
     *  It should be kept in sync with this.selected instead.
     */
    private function accordionHeader_changeHandler(event:Event):void
    {
        accordionHeader.selected = selected;
    }

    /**
     *  @private
     */
    protected function creationCompleteHandler(event:FlexEvent):void
    {
        removeEventListener(FlexEvent.CREATION_COMPLETE, creationCompleteHandler);
        listenToSkin();
    }
    
    /**
     *  @private
     */
    private function skin_currentStateChangingHandler(event:StateChangeEvent):void
    {
        isAnimating = true;
    }
    
    /**
     *  @private
     */
    private function skin_stateChangeCompleteHandler(event:FlexEvent):void
    {
        addEventListener(Event.RENDER, renderHandler); 
    }
    
    /**
     *  @private
     */
    private function renderHandler(event:Event):void
    {
        removeEventListener(Event.RENDER, renderHandler);
        addEventListener(Event.ENTER_FRAME, enterFrameHandler); 
    }
    
    /**
     *  @private
     */
    private function enterFrameHandler(event:Event):void
    {
        removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
        
        isAnimating = false;
        if (!selected)
            applyDestructionPolicy();
        
        // If all the Accordion is now completely done animating, dispatch a
        // changeEnd event from the Accordion.
        var accordion:Accordion = owner as Accordion;
        if (accordion && !accordion.isAnimating)
            accordion.dispatchEvent(new FlexEvent(FlexEvent.CHANGE_END));
    }
    
    //--------------------------------------------------------------------------
    //
    //    Overriden methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    override protected function commitProperties():void
    {
        if (selected
            && elementCreationPolicy != "none" 
            && !deferredContentCreated)
            createDeferredContent();
        
        // commitProperties() should be called after content is created because
        // it may call validateNow(), which can cause the width or height of the
        // AccordionContent to change, triggering a resize animation.
        // The dimensions must be correct at this point for animation to have 
        // the correct end values, so the children must be created first.
        super.commitProperties();
    }
    
    //--------------------------------------------------------------------------
    //
    //    Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Applies the destruction policy on this AccordionContent's elements.
     */
    private function applyDestructionPolicy():void
    {
        var policyIsAuto:Boolean = elementDestructionPolicy == ContainerDestructionPolicy.AUTO;
        var policyIsAlways:Boolean = elementDestructionPolicy == ContainerDestructionPolicy.ALWAYS;
        var policyWarrantsDestruction:Boolean = policyIsAlways || policyIsAuto;
        var shouldCache:Boolean = policyIsAuto;
        
        if (policyWarrantsDestruction && deferredContentCreated)
            removeDeferredContent(shouldCache);
    }
    
    /**
     *  @private
     *  We listen to skin state changes in order to properly dispatch the 
     *  CHANGE_END event after state transitions are complete.
     *  However, only want to listen to skin state changes after creation 
     *  complete because we do not want to dispatch CHANGE_END when the skin
     *  state is initialized.
     *  This works because the skin is attached and its state is set up before
     *  creation complete.
     */
    private function listenToSkin():void
    {
        if (!skin || !initialized)
            return;
        
        skin.addEventListener(StateChangeEvent.CURRENT_STATE_CHANGING, skin_currentStateChangingHandler);
        skin.addEventListener(FlexEvent.STATE_CHANGE_COMPLETE, skin_stateChangeCompleteHandler);
    }
    
    /**
     *  @private
     */
    private function stopListeningToSkin():void
    {
        if (!skin || !initialized)
            return;
        
        skin.removeEventListener(StateChangeEvent.CURRENT_STATE_CHANGING, skin_currentStateChangingHandler);
        skin.removeEventListener(FlexEvent.STATE_CHANGE_COMPLETE, skin_stateChangeCompleteHandler);
    }
}

}
