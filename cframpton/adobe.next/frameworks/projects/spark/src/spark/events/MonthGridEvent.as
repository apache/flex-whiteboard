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

package spark.events
{
import flash.display.InteractiveObject;
import flash.events.Event;
import flash.events.MouseEvent;

import spark.components.DateChooser;
import spark.components.MonthGrid;
import spark.components.calendarClasses.IDateItemRenderer;

[ExcludeClass]

/**
 *  The GridEvent class extends the MouseEvent class to includes additional 
 *  grid specific information based on the event's location relative to a grid cell.
 *  This information includes the following:
 *
 *  <ul>
 *    <li>The row and column index of the cell.</li>
 *    <li>The data provider item that corresponds to the row of the cell.</li>
 *    <li>The monthGrid.</li>  
 *    <li>The item renderer for the monthGrid.</li>  
 *  </ul>
 * 
 *  <p>Grid events have a one-to-one correspondence with mouse events.  
 *  They are dispatched in response to mouse events that have "bubbled" 
 *  from some Grid descendant to the Grid itself.   
 *  One significant difference is that event listeners for grid events 
 *  are guaranteed to see an entire down-drag-up mouse gesture, 
 *  even if the drag and up parts of the gesture do not occur over the grid.   
 *  The <code>gridMouseDrag</code> event corresponds to a 
 *  mouse move event with the button held down.</p> 
 * 
 *  @see spark.components.DataChooser
 *  @see spark.components.calendarClasses.MonthGrid
 *  
 *  @langversion 3.0
 *  @playerversion Flash 11
 *  @playerversion AIR 3.0
 *  @productversion Flex 5.0
 */
public class MonthGridEvent extends MouseEvent
{
    include "../core/Version.as";    
    
    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------
    
    /**
     *  The value of the <code>type</code> property for a <code>gridMouseDown</code> GridEvent.
     *
     *  <p>The properties of the event object have the following values:</p>
     *  <table class="innertable">
     *     <tr><th>Property</th><th>Value</th></tr>
     *     <tr><td><code>bubbles</code></td><td>false</td></tr>
     *     <tr><td><code>cancelable</code></td><td>false</td></tr>
     *     <tr><td><code>currentTarget</code></td><td>The Object that defines the 
     *       event listener that handles the event. For example, if you use 
     *       <code>myButton.addEventListener()</code> to register an event listener, 
     *       myButton is the value of the <code>currentTarget</code>. </td></tr>
     *     <tr><td><code>column</code></td><td>The column where the event occurred, 
     *        or null if the event did not occur over a column.</td></tr>
     *     <tr><td><code>columnIndex</code></td><td>The index of the column where 
     *        the event occurred, or -1 if the event did not occur over a grid column.</td></tr>
     *     <tr><td><code>grid</code></td><td>The Grid associated with this event.</td></tr>
     *     <tr><td><code>item</code></td><td>The data provider item for this row, 
     *        or null if the event did not occur over a grid row.</td></tr>
     *     <tr><td><code>itemRenderer</code></td><td>The The item renderer that displayed 
     *       this cell, or null if the event did not occur over a visible cell.</td></tr>
     *     <tr><td><code>rowIndex</code></td><td>The index of the row where the event occurred, 
     *        or -1 if the event did not occur over a grid row.</td></tr>
     *     <tr><td><code>target</code></td><td>The Object that dispatched the event; 
     *        it is not always the Object listening for the event. 
     *        Use the <code>currentTarget</code> property to always access the 
     *        Object listening for the event.</td></tr>
     *     <tr><td><code>type</code></td><td>GirdEvent.MONTH_GRID_MOUSE_DOWN</td></tr>
     *  </table>
     *
     *  @eventType gridMouseDown
     * 
     *  @see flash.display.InteractiveObject#event:mouseDown
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */    
    public static const MONTH_GRID_MOUSE_DOWN:String = "gridMouseDown";
    
    /**
     *  The value of the <code>type</code> property for a <code>gridMouseDrag</code> GridEvent.  
     *  This event is only dispatched when a listener has handled a <code>mouseDown</code> event, 
     *  and then only while the mouse moves with the button held down.
     *
     *  <p>The properties of the event object have the following values:</p>
     *  <table class="innertable">
     *     <tr><th>Property</th><th>Value</th></tr>
     *     <tr><td><code>bubbles</code></td><td>false</td></tr>
     *     <tr><td><code>cancelable</code></td><td>false</td></tr>
     *     <tr><td><code>currentTarget</code></td><td>The Object that defines the 
     *       event listener that handles the event. For example, if you use 
     *       <code>myButton.addEventListener()</code> to register an event listener, 
     *       myButton is the value of the <code>currentTarget</code>. </td></tr>
     *     <tr><td><code>column</code></td><td>The column where the event occurred, 
     *        or null if the event did not occur over a column.</td></tr>
     *     <tr><td><code>columnIndex</code></td><td>The index of the column where 
     *        the event occurred, or -1 if the event did not occur over a grid column.</td></tr>
     *     <tr><td><code>grid</code></td><td>The Grid associated with this event.</td></tr>
     *     <tr><td><code>item</code></td><td>The data provider item for this row, 
     *        or null if the event did not occur over a grid row.</td></tr>
     *     <tr><td><code>itemRenderer</code></td><td>The The item renderer that displayed 
     *       this cell, or null if the event did not occur over a visible cell.</td></tr>
     *     <tr><td><code>rowIndex</code></td><td>The index of the row where the event occurred, 
     *        or -1 if the event did not occur over a grid row.</td></tr>
     *     <tr><td><code>target</code></td><td>The Object that dispatched the event; 
     *        it is not always the Object listening for the event. 
     *        Use the <code>currentTarget</code> property to always access the 
     *        Object listening for the event.</td></tr>
     *     <tr><td><code>type</code></td><td>GirdEvent.MONTH_GRID_MOUSE_DRAG</td></tr>
     *  </table>
     *
     *  @eventType gridMouseDrag
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */    
    public static const MONTH_GRID_MOUSE_DRAG:String = "gridMouseDrag";        
    
    /**
     *  The value of the <code>type</code> property for a <code>gridMouseUp</code> GridEvent.
     *
     *  <p>The properties of the event object have the following values:</p>
     *  <table class="innertable">
     *     <tr><th>Property</th><th>Value</th></tr>
     *     <tr><td><code>bubbles</code></td><td>false</td></tr>
     *     <tr><td><code>cancelable</code></td><td>false</td></tr>
     *     <tr><td><code>currentTarget</code></td><td>The Object that defines the 
     *       event listener that handles the event. For example, if you use 
     *       <code>myButton.addEventListener()</code> to register an event listener, 
     *       myButton is the value of the <code>currentTarget</code>. </td></tr>
     *     <tr><td><code>column</code></td><td>The column where the event occurred, 
     *        or null if the event did not occur over a column.</td></tr>
     *     <tr><td><code>columnIndex</code></td><td>The index of the column where 
     *        the event occurred, or -1 if the event did not occur over a grid column.</td></tr>
     *     <tr><td><code>grid</code></td><td>The Grid associated with this event.</td></tr>
     *     <tr><td><code>item</code></td><td>The data provider item for this row, 
     *        or null if the event did not occur over a grid row.</td></tr>
     *     <tr><td><code>itemRenderer</code></td><td>The The item renderer that displayed 
     *       this cell, or null if the event did not occur over a visible cell.</td></tr>
     *     <tr><td><code>rowIndex</code></td><td>The index of the row where the event occurred, 
     *        or -1 if the event did not occur over a grid row.</td></tr>
     *     <tr><td><code>target</code></td><td>The Object that dispatched the event; 
     *        it is not always the Object listening for the event. 
     *        Use the <code>currentTarget</code> property to always access the 
     *        Object listening for the event.</td></tr>
     *     <tr><td><code>type</code></td><td>GirdEvent.MONTH_GRID_MOUSE_UP</td></tr>
     *  </table>
     *
     *  @eventType gridMouseUp
     * 
     *  @see flash.display.InteractiveObject#event:mouseUp
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */    
    public static const MONTH_GRID_MOUSE_UP:String = "gridMouseUp";
    
    /**
     *  The value of the <code>type</code> property for a <code>gridClick</code> GridEvent.
     *
     *  <p>The properties of the event object have the following values:</p>
     *  <table class="innertable">
     *     <tr><th>Property</th><th>Value</th></tr>
     *     <tr><td><code>bubbles</code></td><td>false</td></tr>
     *     <tr><td><code>cancelable</code></td><td>false</td></tr>
     *     <tr><td><code>currentTarget</code></td><td>The Object that defines the 
     *       event listener that handles the event. For example, if you use 
     *       <code>myButton.addEventListener()</code> to register an event listener, 
     *       myButton is the value of the <code>currentTarget</code>. </td></tr>
     *     <tr><td><code>column</code></td><td>The column where the event occurred, 
     *        or null if the event did not occur over a column.</td></tr>
     *     <tr><td><code>columnIndex</code></td><td>The index of the column where 
     *        the event occurred, or -1 if the event did not occur over a grid column.</td></tr>
     *     <tr><td><code>grid</code></td><td>The Grid associated with this event.</td></tr>
     *     <tr><td><code>item</code></td><td>The data provider item for this row, 
     *        or null if the event did not occur over a grid row.</td></tr>
     *     <tr><td><code>itemRenderer</code></td><td>The The item renderer that displayed 
     *       this cell, or null if the event did not occur over a visible cell.</td></tr>
     *     <tr><td><code>rowIndex</code></td><td>The index of the row where the event occurred, 
     *        or -1 if the event did not occur over a grid row.</td></tr>
     *     <tr><td><code>target</code></td><td>The Object that dispatched the event; 
     *        it is not always the Object listening for the event. 
     *        Use the <code>currentTarget</code> property to always access the 
     *        Object listening for the event.</td></tr>
     *     <tr><td><code>type</code></td><td>GirdEvent.MONTH_GRID_CLICK</td></tr>
     *  </table>
     *
     *  @eventType gridClick
     * 
     *  @see flash.display.InteractiveObject#event:click
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */    
    public static const MONTH_GRID_CLICK:String = "gridClick";
    
    /**
     *  The value of the <code>type</code> property for a <code>gridDoubleClick</code> GridEvent.
     *
     *  <p>The properties of the event object have the following values:</p>
     *  <table class="innertable">
     *     <tr><th>Property</th><th>Value</th></tr>
     *     <tr><td><code>bubbles</code></td><td>false</td></tr>
     *     <tr><td><code>cancelable</code></td><td>false</td></tr>
     *     <tr><td><code>currentTarget</code></td><td>The Object that defines the 
     *       event listener that handles the event. For example, if you use 
     *       <code>myButton.addEventListener()</code> to register an event listener, 
     *       myButton is the value of the <code>currentTarget</code>. </td></tr>
     *     <tr><td><code>column</code></td><td>The column where the event occurred, 
     *        or null if the event did not occur over a column.</td></tr>
     *     <tr><td><code>columnIndex</code></td><td>The index of the column where 
     *        the event occurred, or -1 if the event did not occur over a grid column.</td></tr>
     *     <tr><td><code>grid</code></td><td>The Grid associated with this event.</td></tr>
     *     <tr><td><code>item</code></td><td>The data provider item for this row, 
     *        or null if the event did not occur over a grid row.</td></tr>
     *     <tr><td><code>itemRenderer</code></td><td>The The item renderer that displayed 
     *       this cell, or null if the event did not occur over a visible cell.</td></tr>
     *     <tr><td><code>rowIndex</code></td><td>The index of the row where the event occurred, 
     *        or -1 if the event did not occur over a grid row.</td></tr>
     *     <tr><td><code>target</code></td><td>The Object that dispatched the event; 
     *        it is not always the Object listening for the event. 
     *        Use the <code>currentTarget</code> property to always access the 
     *        Object listening for the event.</td></tr>
     *     <tr><td><code>type</code></td><td>GirdEvent.MONTH_GRID_DOUBLE_CLICK</td></tr>
     *  </table>
     *
     *  @eventType gridDoubleClick
     * 
     *  @see flash.display.InteractiveObject#event:doubleClick
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */    
    public static const MONTH_GRID_DOUBLE_CLICK:String = "gridDoubleClick";     
    
    /**
     *  The value of the <code>type</code> property for a <code>gridRollOver</code> GridEvent.
     *
     *  <p>The properties of the event object have the following values:</p>
     *  <table class="innertable">
     *     <tr><th>Property</th><th>Value</th></tr>
     *     <tr><td><code>bubbles</code></td><td>false</td></tr>
     *     <tr><td><code>cancelable</code></td><td>false</td></tr>
     *     <tr><td><code>currentTarget</code></td><td>The Object that defines the 
     *       event listener that handles the event. For example, if you use 
     *       <code>myButton.addEventListener()</code> to register an event listener, 
     *       myButton is the value of the <code>currentTarget</code>. </td></tr>
     *     <tr><td><code>column</code></td><td>The column where the event occurred, 
     *        or null if the event did not occur over a column.</td></tr>
     *     <tr><td><code>columnIndex</code></td><td>The index of the column where 
     *        the event occurred, or -1 if the event did not occur over a grid column.</td></tr>
     *     <tr><td><code>grid</code></td><td>The Grid associated with this event.</td></tr>
     *     <tr><td><code>item</code></td><td>The data provider item for this row, 
     *        or null if the event did not occur over a grid row.</td></tr>
     *     <tr><td><code>itemRenderer</code></td><td>The The item renderer that displayed 
     *       this cell, or null if the event did not occur over a visible cell.</td></tr>
     *     <tr><td><code>rowIndex</code></td><td>The index of the row where the event occurred, 
     *        or -1 if the event did not occur over a grid row.</td></tr>
     *     <tr><td><code>target</code></td><td>The Object that dispatched the event; 
     *        it is not always the Object listening for the event. 
     *        Use the <code>currentTarget</code> property to always access the 
     *        Object listening for the event.</td></tr>
     *     <tr><td><code>type</code></td><td>GirdEvent.MONTH_GRID_ROLL_OVER</td></tr>
     *  </table>
     *
     *  @eventType gridRollOver
     * 
     *  @see flash.display.InteractiveObject#event:rollOver
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */    
    public static const MONTH_GRID_ROLL_OVER:String = "gridRollOver";

    /**
     *  The value of the <code>type</code> property for a <code>gridRollOut</code> GridEvent.
     *
     *  <p>The properties of the event object have the following values:</p>
     *  <table class="innertable">
     *     <tr><th>Property</th><th>Value</th></tr>
     *     <tr><td><code>bubbles</code></td><td>false</td></tr>
     *     <tr><td><code>cancelable</code></td><td>false</td></tr>
     *     <tr><td><code>currentTarget</code></td><td>The Object that defines the 
     *       event listener that handles the event. For example, if you use 
     *       <code>myButton.addEventListener()</code> to register an event listener, 
     *       myButton is the value of the <code>currentTarget</code>. </td></tr>
     *     <tr><td><code>column</code></td><td>The column where the event occurred, 
     *        or null if the event did not occur over a column.</td></tr>
     *     <tr><td><code>columnIndex</code></td><td>The index of the column where 
     *        the event occurred, or -1 if the event did not occur over a grid column.</td></tr>
     *     <tr><td><code>grid</code></td><td>The Grid associated with this event.</td></tr>
     *     <tr><td><code>item</code></td><td>The data provider item for this row, 
     *        or null if the event did not occur over a grid row.</td></tr>
     *     <tr><td><code>itemRenderer</code></td><td>The The item renderer that displayed 
     *       this cell, or null if the event did not occur over a visible cell.</td></tr>
     *     <tr><td><code>rowIndex</code></td><td>The index of the row where the event occurred, 
     *        or -1 if the event did not occur over a grid row.</td></tr>
     *     <tr><td><code>target</code></td><td>The Object that dispatched the event; 
     *        it is not always the Object listening for the event. 
     *        Use the <code>currentTarget</code> property to always access the 
     *        Object listening for the event.</td></tr>
     *     <tr><td><code>type</code></td><td>GirdEvent.MONTH_GRID_ROLL_OUT</td></tr>
     *  </table>
     *
     *  @eventType gridRollOut
     * 
     *  @see flash.display.InteractiveObject#event:rollOut
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */    
    public static const MONTH_GRID_ROLL_OUT:String = "gridRollOut";
        
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    
    /**
     *  GridEvents dispatched by the Grid class in response to mouse event are constructed with
     *  the incoming mouse event's properties.   
     *  The grid event's x,y location, meaning the value of
     *  its <code>localX</code> and <code>localY</code> properties, 
     *  is defined relative to the entire grid, not just the 
     *  part of the grid that has been scrolled into view.   
     *  Similarly, the event's row and column
     *  indices might correspond to a cell that has not been scrolled into view.
     *
     *  @param type Distinguishes the mouse gesture that caused this event to be dispatched.
     *
     *  @param bubbles Specifies whether the event can bubble up the display list hierarchy.
     *
     *  @param cancelable Specifies whether the behavior associated with the event can be prevented.
     * 
     *  @param localX The event's x coordinate relative to grid.
     * 
     *  @param localY The event's y coordinate relative to grid.
     * 
     *  @param rowIndex The index of the row where the event occurred, or -1.
     * 
     *  @param columnIndex The index of the column where the event occurred, or -1.
     * 
     *  @param column The column where the event occurred, or null.
     * 
     *  @param item The data provider item at <code>rowIndex</code>.
     * 
     *  @param relatedObject The <code>relatedObject</code> property of the 
     *  MouseEvent that triggered this GridEvent.
     * 
     *  @param itemRenderer The visible item renderer where the event occurred, or null.
     * 
     *  @param ctrlKey Whether the Control key is down.
     * 
     *  @param altKey Whether the Alt key is down.
     * 
     *  @param shiftKey Whether the Shift key is down.
     * 
     *  @param buttonDown Whether the Control key is down.
     * 
     *  @param delta Not used.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5 
     */
    public function MonthGridEvent(
        type:String,
        bubbles:Boolean = false,
        cancelable:Boolean = false,
        localX:Number = NaN,
        localY:Number = NaN,
        relatedObject:InteractiveObject = null,
        ctrlKey:Boolean = false,
        altKey:Boolean = false,
        shiftKey:Boolean = false,
        buttonDown:Boolean = false,
        delta:int = 0,
        rowIndex:int = -1,
        columnIndex:int = -1,
        itemRenderer:IDateItemRenderer = null)
    {
        super(type, bubbles, cancelable, localX, localY, 
              relatedObject, ctrlKey, altKey, shiftKey, buttonDown, delta);
   
        this.rowIndex = rowIndex;
        this.columnIndex = columnIndex;
        this.itemRenderer = itemRenderer;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  rowIndex
    //----------------------------------
    
    /**
     *  The index of the row where the event occurred, or -1 if the event
     *  did not occur over a grid row.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5 
     */
    public var rowIndex:int;
    
    //----------------------------------
    //  columnIndex
    //----------------------------------
    
    /**
     *  The index of the column where the event occurred, or -1 if the event 
     *  did not occur over a grid column.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5 
     */
    public var columnIndex:int;
        
    //----------------------------------
    //  monthGrid
    //----------------------------------
    
    /**
     *  The MonthGrid grid associated with this event.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5 
     */
    public function get monthGrid():MonthGrid
    {
        return target is MonthGrid ? MonthGrid(target) : null;
    }
    
    //----------------------------------
    //  itemRenderer
    //----------------------------------
    
    /**
     *  The date renderer that displayed this cell, or null if the event 
     *  did not occur over a visible cell. 
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5 
     */       
    public var itemRenderer:IDateItemRenderer;
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods: Event
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    override public function clone():Event
    {
        var cloneEvent:MonthGridEvent = new MonthGridEvent(
            type, bubbles, cancelable, 
            localX, localY, 
            relatedObject, ctrlKey, altKey, shiftKey, buttonDown, delta,
            rowIndex, columnIndex, itemRenderer);
        
        cloneEvent.relatedObject = this.relatedObject;
        
        return cloneEvent;
    }

    /**
     *  @private
     */
    override public function toString():String
    {
        return "MonthGridEvent{" + 
            "type=\"" + type + "\"" +
            " localX,Y=" + localX + "," + localY + 
            " rowIndex,columnIndex=" + rowIndex + "," + columnIndex + 
            "}";
    }        
}
}
