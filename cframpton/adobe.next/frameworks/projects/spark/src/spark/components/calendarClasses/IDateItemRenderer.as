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

package spark.components.calendarClasses
{
    import flash.events.IEventDispatcher;
    
    import spark.components.MonthGrid;
    
    import mx.core.IDataRenderer;
    import mx.core.IInvalidating;
    import mx.core.IVisualElement;
    import mx.managers.ILayoutManagerClient;
    
    /**
     *  The IDateItemRenderer interface must be implemented by DateChooser's MonthGrid item 
     *  renderers.  
     *  The MonthGrid uses this API to provide the item renderer with the information needed to 
     *  render one day of the week or day of the month <i>cell</i> in the date grid.  
     *
     *  <p>All of the renderer's properties are set during the execution of its parent's 
     *  <code>updateDisplayList()</code> method.  
     *  After the properties have been set, the item renderer's <code>prepare()</code> method is 
     *  called.  
     *  An IDateItemRenderer implementation should override the <code>prepare()</code> method 
     *  to make any final adjustments to its properties or any aspect of its visual elements.
     *  Typically, the <code>prepare()</code> is used to configure the renderer's visual
     *  elements based on the <code>data</code> property.</p>
     * 
     *  <p>When an item renderer is no longer needed, either because it's going to be added 
     *  to an internal reusable renderer "free" list, or because it's never going to be 
     *  used again, the IDateItemRenderer <code>discard()</code> method is called.</p> 
     * 
     *  @see spark.components.DateChooser
     *  @see spark.components.calendarClasses.MonthGrid
     * 
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5.0
     */
    public interface IDateItemRenderer extends IEventDispatcher, IDataRenderer, IVisualElement
    {
        /**
         *  The Date associated with this item renderer.
         * 
         *  @default null
         * 
         *  @langversion 3.0
         *  @playerversion Flash 11
         *  @playerversion AIR 3.0
         *  @productversion Flex 5.0
         */
        function get date():Date;
                
        /**
         *  The column index for this item renderer's cell.
         * 
         *  @default -1
         * 
         *  @langversion 3.0
         *  @playerversion Flash 11
         *  @playerversion AIR 3.0
         *  @productversion Flex 5.0
         */
        function get columnIndex():int;    
        function set columnIndex(value:int):void;
        
        /**
         *  The row index for this item renderer's cell.
         * 
         *  @default -1
         * 
         *  @langversion 3.0
         *  @playerversion Flash 11
         *  @playerversion AIR 3.0
         *  @productversion Flex 5.0
         */
        function get rowIndex():int;
        function set rowIndex(value:int):void;
        
        /**
         *  This property is set to <code>true</code> when one of two input gestures occurs within a 
         *  date cell:  either the mouse button or the touch screen is pressed.   
         *  The <code>down</code> property is reset to <code>false</code> when 
         *  the mouse button goes up, the user lifts off 
         *  the touch screen, or the mouse/touch is dragged out of the date cell.   
         * 
         *  <p>Unlike a List item renderer, date item renderers do not have exclusive
         *  responsibility for displaying the down indicator.  The Grid itself
         *  renders the down indicator for the selected row or cell. 
         *  The item renderer can also change its visual properties to emphasize
         *  that it's being pressed.</p>   
         * 
         *  @langversion 3.0
         *  @playerversion Flash 11
         *  @playerversion AIR 3.0
         *  @productversion Flex 5.0
         */
        function get down():Boolean;
        function set down(value:Boolean):void;
        
        /**
         *  Contains <code>true</code> if the item renderer is being dragged, 
         *  typically as part of a drag and drop operation.
         *  Currently, drag and drop is not supported by the Spark DateChooser control.
         *  
         *  @langversion 3.0
         *  @playerversion Flash 11
         *  @playerversion AIR 3.0
         *  @productversion Flex 5.0
         */
//        function get dragging():Boolean;
//        function set dragging(value:Boolean):void;
        
        /**
         *  Contains <code>true</code> if the item renderer is under the mouse.
         * 
         *  <p>Unlike a List item renderer, date item renderers do not have exclusive
         *  responsibility for displaying something to indicate that the renderer 
         *  or its row is under the mouse.  The Grid itself automatically displays the
         *  hoverIndicator skin part for the hovered row or cell.  date item renderers 
         *  can also change their properties to emphasize that they're hovered.</p>
         * 
         *  @langversion 3.0
         *  @playerversion Flash 11
         *  @playerversion AIR 3.0
         *  @productversion Flex 5.0
         */
        function get hovered():Boolean;
        function set hovered(value:Boolean):void;
        
        /**
         *  The String to display in the item renderer.  
         * 
         *  <p>The DateItemRenderer class automatically copies the 
         *  value of this property to the text property 
         *  of its labelDisplay element, if that element was specified.
         *  If the renderer is a day of the week cell, the label is set to the value returned
         *  by formatting the date with the <code>dayOfTheWeekFormatter</code>. 
         *  If the renderer is a day of the month cell, the label is set to the value returned
         *  by formatting the date with the <code>dayOfTheMonthFormatter</code>.</p>
         *
         *  @see spark.components.gridClasses.GridItemRenderer
         *  
         *  @langversion 3.0
         *  @playerversion Flash 11
         *  @playerversion AIR 3.0
         *  @productversion Flex 5.0
         */
        function get label():String;
        function set label(value:String):void;
        
        /**
         *  Contains <code>true</code> if the item renderer's cell is part 
         *  of the current selection.
         * 
         *  <p> Unlike a List item renderer, 
         *  date item renderers do not have exclusive responsibility for displaying 
         *  something to indicate that they're part of the selection.  
         *  The MonthGrid itself automatically displays the selectionIndicator skin part for the 
         *  selected date cells.  
         *  The item renderer can also change its visual properties to emphasize that it's part 
         *  of the selection.</p>
         * 
         *  @langversion 3.0
         *  @playerversion Flash 11
         *  @playerversion AIR 3.0
         *  @productversion Flex 5.0
         */
        function get selected():Boolean;
        function set selected(value:Boolean):void;
        
        /**
         *  Contains <code>true</code> if the item renderer's cell is indicated by the caret.
         * 
         *  <p> Unlike a List item renderer, date item renderers do not have exclusive 
         *  responsibility for displaying something to indicate their cell or row has
         *  the caret.  
         *  The MonthGrid itself automatically displays the caretIndicator skin part for the 
         *  caret date cell.  
         *  The item renderer can also change its visual properties to emphasize that it has the 
         *  caret.</p>
         * 
         *  @langversion 3.0
         *  @playerversion Flash 11
         *  @playerversion AIR 3.0
         *  @productversion Flex 5.0
         */
        function get showsCaret():Boolean;
        function set showsCaret(value:Boolean):void;    
        
        /**
         *  Contains <code>true</code> if the date of the item renderer's cell can be selected.
         *  Cells which represent dates that are not in the list of the 
         *  DateChooser's <code>selectableDates</code> are not enabled.
         * 
         *  @langversion 3.0
         *  @playerversion Flash 11
         *  @playerversion AIR 3.0
         *  @productversion Flex 5.0
         */
        function get enabled():Boolean;
        function set enabled(value:Boolean):void;    
        
        /**
         *  Contains <code>true</code> if the date of the item renderer's cell is
         *  in the next month, i.e. <code>displayedMonth</code> + 1.
         * 
         *  @langversion 3.0
         *  @playerversion Flash 11
         *  @playerversion AIR 3.0
         *  @productversion Flex 5.0
         */
        function get nextMonth():Boolean;
        function set nextMonth(value:Boolean):void;
        
        /**
         *  Contains <code>true</code> if the date of the item renderer's cell is
         *  in the previous month, i.e. <code>displayedMonth</code> - 1.
         * 
         *  @langversion 3.0
         *  @playerversion Flash 11
         *  @playerversion AIR 3.0
         *  @productversion Flex 5.0
         */
        function get previousMonth():Boolean;  
        function set previousMonth(value:Boolean):void;

        /**
         *  Contains <code>true</code> if the date of the item renderer's cell is today.
         * 
         *  @langversion 3.0
         *  @playerversion Flash 11
         *  @playerversion AIR 3.0
         *  @productversion Flex 5.0
         */
        function get today():Boolean;
        function set today(value:Boolean):void;
        
        /**
         *  Contains <code>true</code> if the date of the item renderer's cell is Monday through
         *  Friday.  
         *  <i>Note there are locales which have a different definition of weekday and this 
         *  does not currently reflect that.</i>
         * 
         *  @langversion 3.0
         *  @playerversion Flash 11
         *  @playerversion AIR 3.0
         *  @productversion Flex 5.0
         */
        function get weekday():Boolean;
        function set weekday(value:Boolean):void
            
        /**
         *  Called from the item renderer parent's <code>updateDisplayList()</code> method 
         *  after all of the renderer's properties have been set.  
         *  The <code>hasBeenRecycled</code> parameter is <code>false</code>
         *  if this renderer has not been used before, meaning it was not recycled.  
         *  This method is called when a renderer is about to become visible 
         *  and each time it's redisplayed because of a change in a renderer
         *  property, or because a redisplay was explicitly requested. 
         * 
         *  <p>This method can be used to configure all of a renderer's visual 
         *  elements and properties.
         *  Using this method can be more efficient than binding <code>data</code>
         *  properties to visual element properties.  
         *  Note: Because the <code>prepare()</code> method is called frequently, 
         *  make sure that it is coded efficiently.</p>
         *
         *  <p>The <code>prepare()</code> method may be called many times 
         *  before the <code>discard()</code> method is called.</p>
         * 
         *  <p>This method is not intended to be called directly.
         *  It is called by the MonthGrid implementation.</p>
         * 
         *  @param hasBeenRecycled  <code>true</code> if this renderer is being reused.
         * 
         *  @langversion 3.0
         *  @playerversion Flash 11
         *  @playerversion AIR 3.0
         *  @productversion Flex 5.0
         */
        function prepare(hasBeenRecycled:Boolean):void;
        
        /**
         *  Called from the item renderer parent's <code>updateDisplayList()</code> method 
         *  when it has been determined that this renderer will no longer be visible.   
         *  If the <code>willBeRecycled</code> parameter is <code>true</code>, 
         *  then the owner adds this renderer to its internal free list for reuse.  
         *  Implementations can use this method to clear any renderer properties that are 
         *  no longer needed.
         * 
         *  <p>This method is not intended to be called directly.
         *  It is called by the MonthGrid implementation.</p>
         * 
         *  @param willBeRecycled <code>true</code> if this renderer is going to be added 
         *  to the owner's internal free list for reuse.
         * 
         *  @langversion 3.0
         *  @playerversion Flash 11
         *  @playerversion AIR 3.0
         *  @productversion Flex 5.0
         */
        function discard(willBeRecycled:Boolean):void;
    }
}