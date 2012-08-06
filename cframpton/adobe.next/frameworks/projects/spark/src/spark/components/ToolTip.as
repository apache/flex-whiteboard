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

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.events.Event;
import flash.geom.ColorTransform;
import flash.geom.Point;

import mx.core.LayoutDirection;
import mx.core.mx_internal;
import mx.effects.Effect;
import mx.events.EffectEvent;
import mx.managers.IToolTipManagerClient;
import mx.styles.StyleProtoChain;
import mx.utils.PopUpUtil;

import spark.core.IDisplayText;
import spark.core.IToolTip;

use namespace mx_internal;

/**
 *  The ToolTip component lets you provide helpful information 
 *  to your users. 
 *  When a user moves the mouse cursor over a graphical 
 *  component, the ToolTip component pops up and displays 
 *  information about the component. 
 *  You can use ToolTips to guide 
 *  users as they work with your application.
 *
 *  <p>The ToolTip component renders a UIComponent's toolTipData 
 *  property in its skin. 
 *  The default skin is ToolTipSkin. 
 *  You can provide a custom skin by changing a UIComponent's toolTipSkin
 *  style.</p>
 * 
 *  <p>The ToolTip component positions itself automatically relative to
 *  the mouse cursor.</p>
 * 
 *  <p>You can customize ToolTip's positioning logic entirely by
 *  creating a subclass of ToolTip and overriding the 
 *  positionPopUp() method. 
 *  For reference, note that the positionPopUp() method originates 
 *  in ToolTip's base class, SkinnablePopUpContainer.</p> 
 * 
 *  <p>To customize a ToolTip's open and close transitions, you can
 *  define state transitions between its open and close states its skin.</p>
 * 
 *  <p>By default, the ToolTipManager hides tool tips when the 
 *  mouse cursor leaves the target component or a specified amount of time 
 *  elapses, known as the hide delay.
 *  If you would the user to interact with the tool tip, such as click a button
 *  inside it, set its mouseEnabled and mouseChildren properties to true. 
 *  This will keep the tool tip open while the mouse is over it, even if the
 *  mouse is no longer over the target component.</p>
 *
 *  <p>You should not nest tool tips in tool tips because it is not 
 *  supported. Thus, any components in your tool tip skin should not define 
 *  a toolTip or toolTipData property.</p>
 * 
 *  @see spark.components.ToolTipPosition
 *  @see spark.skins.spark.ToolTipSkin 
 *  @see mx.managers.ToolTipManager
 *  @see spark.components.SkinnablePopUpContainer
 *  
 *  @langversion 3.0
 *  @playerversion Flash 11
 *  @playerversion AIR 3
 *  @productversion Flex 5.0
 */
public class ToolTip extends SkinnablePopUpContainer implements IToolTip
{
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Constructor.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function ToolTip()
    {
        super();
        
        mouseEnabled = false;
        mouseChildren = false;
    }   
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    private var target:IToolTipManagerClient;
    
    //--------------------------------------------------------------------------
    //
    //  Skin parts
    //
    //--------------------------------------------------------------------------
    
    //--------------------------
    //  labelDisplay
    //--------------------------
    
    [SkinPart(required="false")]
    
    /**
     *  A skin part that defines the tool tip's label. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3
     *  @productversion Flex 5.0
     */
    public var labelDisplay:IDisplayText;
    
    //--------------------------
    //  closedToNormalEffect
    //--------------------------
    
    [SkinPart(required="false")]
    
    /**
     *  FIXME: PARB these SkinParts.
     *  The effect for the transition between the named states.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3
     *  @productversion Flex 5.0
     */
    public var closedToNormalEffect:Effect;
    
    //-------------------------------------
    //  disabledAndClosedToDisabledEffect
    //-------------------------------------
    
    [SkinPart(required="false")]
    
    /**
     *  The effect for the transition between the named states.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3
     *  @productversion Flex 5.0
     */
    public var disabledAndClosedToDisabledEffect:Effect;
    
    //-------------------------------------
    //  disabledToDisabledAndClosedEffect
    //-------------------------------------
    
    [SkinPart(required="false")]
    
    /**
     *  The effect for the transition between the named states.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3
     *  @productversion Flex 5.0
     */
    public var disabledToDisabledAndClosedEffect:Effect;
    
    //--------------------------
    //  normalToClosedEffect
    //--------------------------
    
    [SkinPart(required="false")]
    
    /**
     *  The effect for the transition between the named states.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3
     *  @productversion Flex 5.0
     */
    public var normalToClosedEffect:Effect;    
    
    //----------------------------------------------------------------------
    //
    //  Properties
    //
    //----------------------------------------------------------------------        
    
    //----------------------------------
    //  data
    //----------------------------------
    
    /**
     *  @private
     *  Storage for the tool tip data that the tool tip skin will render.
     */
    private var _data:Object;
    
    [Bindable]
    
    /**
     *  The data that the tool tip will render in its skin. Data can be a
     *  String or any arbitrary object. ToolTip will display the 
     *  value returned by the object's toString() method in its
     *  labelDisplay skin part. You should override this method
     *  
     *  <p>If you decide to use a custom skin without a labelDisplay skin
     *  part, it is still recommended that you provide a reasonable
     *  toString() implementation in the data object for accessibility 
     *  reasons.</p>
     * 
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3
     *  @productversion Flex 5.0 
     */
    public function get data():Object
    {
        return _data;   
    }
    
    /**
     *  @private
     */
    public function set data(value:Object):void
    {
        _data = value;
        
        if (labelDisplay)
            labelDisplay.text = value.toString();
    }
    
    //----------------------------------
    //  Opening and closing
    //----------------------------------    
    
    /**
     *  ToolTipManager calls this method to show the tool tip.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3
     *  @productversion Flex 5.0 
     */    
    public function showToolTip(target:IToolTipManagerClient):void
    {
        this.target = target;
        
        open(DisplayObjectContainer(target));
        
        if (target.hasEventListener("sparkToolTipShow"))
            target.dispatchEvent(new Event("sparkToolTipShow"));
    }
    
    /**
     *  ToolTipManager calls this method to hide the tool tip.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3
     *  @productversion Flex 5.0 
     */    
    public function hideToolTip():void
    {
        close();
        
        if (target.hasEventListener("sparkToolTipHide"))
            target.dispatchEvent(new Event("sparkToolTipHide"));
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Force ToolTip inheritance chain to start at the style root.
     */
    override mx_internal function initProtoChain():void
    {
        StyleProtoChain.initProtoChain(this, false);
    }
    
    /**
     *  @private
     */
    override protected function partAdded(partName:String, instance:Object):void
    {
        super.partAdded(partName, instance);
        
        if (instance == labelDisplay && data)
            labelDisplay.text = data.toString();
        else if (isOpeningEffect(instance))
            listenToOpeningEffect(Effect(instance));
        else if (isClosingEffect(instance))
            listenToClosingEffect(Effect(instance));
    }
    
    /**
     *  @private
     */
    override protected function partRemoved(partName:String, instance:Object):void
    {
        if (isOpeningEffect(instance))
            stopListeningToOpeningEffect(Effect(instance));
        else if (isClosingEffect(instance))
            stopListeningToClosingEffect(Effect(instance));
    }
    
    /**
     *  Automatically positions the tool tip above or below the mouse cursor,
     *  sliding the tool tip into view horizontally if it hangs off the screen.
     *  
     *  <p>This method overrides SkinnablePopUpContainer's implementation.</p>
     * 
     *  <p>Subclasses can override this method to define their own positioning
     *  logic.</p>
     * 
     *  @see spark.components.SkinnablePopUpContainer
     * 
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3
     *  @productversion Flex 5.0
     */     
    override public function updatePopUpPosition():void
    {           
        var toolTipPosition:Point = new Point();
        
        // Position the tool tip vertically, either above or below the 
        // cursor, depending on how it fits on the screen.
        const cursorWidth:Number = 12;
        const cursorHeight:Number = 18;
        var cursorPosition:Point = getCursorPosition();
        
        // If this tool has mouse enabled, place the tool
        // tip right at the mouse cursor so that the user can easily enter
        // the tool tip area with the mouse from the target component, without
        // possibly traversing a different component with a different tool tip.
        var toolTipBelowCursorY:Number = mouseEnabled ? 
            cursorPosition.y : cursorPosition.y + cursorHeight;
        var toolTipAboveCursorY:Number = cursorPosition.y - height;
        
        var fitsBelowCursor:Boolean = 
            toolTipBelowCursorY + height < screen.height
        var fitsAboveCursor:Boolean =
            toolTipAboveCursorY > 0;
        var fitsNowhere:Boolean = !fitsBelowCursor && !fitsAboveCursor;
        
        var shouldPositionBelowCursor:Boolean = 
            fitsBelowCursor || fitsNowhere;
        
        toolTipPosition.y = shouldPositionBelowCursor ? 
            toolTipBelowCursorY : toolTipAboveCursorY;
        
        // Position the tool tip horizontally.
        // For LTR layout, put the left edge of the tool tip against the 
        // left edge of the cursor. 
        // For RTL layout, put the right edge of the tool tip against the 
        // right edge of the cursor.
        // Note that the tool tip is always positioned in non-mirrored
        // screen coordinates.
        var isLTR:Boolean = layoutDirection == LayoutDirection.LTR;
        toolTipPosition.x = isLTR ? 
            cursorPosition.x : cursorPosition.x + cursorWidth - width;
        
        // Slide the tool tip into view horizontally if it's hanging off the 
        // right or left edges of the screen.
        toolTipPosition.x = clamp(toolTipPosition.x, 0, screen.right - width);
        
        // Submit the tool tip position.
        PopUpUtil.applyPopUpTransform(owner, new ColorTransform(), systemManager, this, toolTipPosition);
    }
    
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Clamps a value between minimum and maximum values.
     */
    private function clamp(value:Number, min:Number, max:Number):Number
    {
        return Math.max(min, Math.min(value, max));
    }
    
    /**
     *  @private
     *  Returns the mouse cursor position in global coordinates.
     */
    private function getCursorPosition():Point
    {
        var systemManagerAsDisplayObject:DisplayObject = DisplayObject(systemManager);
        return new Point(
            systemManagerAsDisplayObject.mouseX,
            systemManagerAsDisplayObject.mouseY
        );
    }

    /**
     *  @private
     */
    private function isOpeningEffect(instance:Object):Boolean
    {
        return instance == closedToNormalEffect
            || instance == disabledAndClosedToDisabledEffect;
    }
    
    /**
     *  @private
     */
    private function isClosingEffect(instance:Object):Boolean
    {
        return instance == disabledToDisabledAndClosedEffect
            || instance == normalToClosedEffect;
    }
    
    /**
     *  @private
     */
    private function listenToOpeningEffect(effect:Effect):void
    {
        effect.addEventListener(EffectEvent.EFFECT_END, openingEffect_effectEndListener);
    }
    
    /**
     *  @private
     */
    private function listenToClosingEffect(effect:Effect):void
    {
        effect.addEventListener(EffectEvent.EFFECT_END, closingEffect_effectEndListener);
    }
    
    /**
     *  @private
     */
    private function stopListeningToOpeningEffect(effect:Effect):void
    {
        effect.removeEventListener(EffectEvent.EFFECT_END, openingEffect_effectEndListener);
    }
    
    /**
     *  @private
     */
    private function stopListeningToClosingEffect(effect:Effect):void
    {
        effect.removeEventListener(EffectEvent.EFFECT_END, closingEffect_effectEndListener);
    }
    
    //--------------------------------------------------------------------------
    //
    //  Event Handlers
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  This method dispatches an internal event when the tool tip is done
     *  rendering its opening animation.
     */    
    private function openingEffect_effectEndListener(event:EffectEvent):void
    {
        addEventListener(Event.ENTER_FRAME, openingEffect_enterFrameListener);
    }
    
    /**
     *  @private
     */
    private function openingEffect_enterFrameListener(event:Event):void
    {
        removeEventListener(Event.ENTER_FRAME, openingEffect_enterFrameListener);
        
        if (target.hasEventListener("sparkToolTipShown"))
            target.dispatchEvent(new Event("sparkToolTipShown"));
    }
    
    /**
     *  @private
     *  This method dispatches an internal event when the tool tip is done
     *  rendering its closing animation.
     */    
    private function closingEffect_effectEndListener(event:EffectEvent):void
    {
        addEventListener(Event.ENTER_FRAME, closingEffect_enterFrameListener);
    }
    
    /**
     *  @private
     */    
    private function closingEffect_enterFrameListener(event:Event):void
    {
        removeEventListener(Event.ENTER_FRAME, closingEffect_enterFrameListener);
        
        if (target.hasEventListener("sparkToolTipHidden"))
            target.dispatchEvent(new Event("sparkToolTipHidden"));
    }
}
}
