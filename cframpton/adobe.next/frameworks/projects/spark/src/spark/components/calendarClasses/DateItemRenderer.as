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
    import flash.display.DisplayObject;
    import flash.events.Event;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    
    import mx.core.ILayoutDirectionElement;
    import mx.core.IToolTip;
    import mx.core.IUIComponent;
    import mx.core.LayoutDirection;
    import mx.core.mx_internal;
    import mx.events.FlexEvent;
    import mx.events.ToolTipEvent;
    import mx.managers.ISystemManager;
    import mx.managers.IToolTipManagerClient;
    import mx.managers.ToolTipManager;
    import mx.utils.PopUpUtil;
    
    import spark.components.MonthGrid;
    import spark.components.Group;
    import spark.components.supportClasses.TextBase;
    
    use namespace mx_internal;
    
    //--------------------------------------
    //  Events
    //--------------------------------------
    
    /**
     *  Dispatched when the <code>data</code> property changes.
     *
     *  @eventType mx.events.FlexEvent.DATA_CHANGE
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    [Event(name="dataChange", type="mx.events.FlexEvent")]
    
    //--------------------------------------
    //  Excluded APIs
    //--------------------------------------
    
    [Exclude(name="transitions", kind="property")]
    
    /**
     *  The DateItemRenderer class defines the base class for custom date item renderers
     *  for the Spark calendar control, DateChooser.  It renders either one day of the week 
     *  (e.g. M,T,W) or one day of the month (e.g. 1,2,3).
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public class DateItemRenderer extends Group implements IDateItemRenderer
    {
        include "../../core/Version.as";
        
        //--------------------------------------------------------------------------
        //
        //  Static Methods
        //
        //--------------------------------------------------------------------------
        
        //--------------------------------------------------------------------------
        //
        //  Constructor
        //
        //--------------------------------------------------------------------------
        
        /**
         *  Constructor.
         * 
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 2.5
         *  @productversion Flex 4.5
         */
        public function DateItemRenderer()
        {
            super();
            
            setCurrentStateNeeded = true;
            accessibilityEnabled = false;
        }
        
        //--------------------------------------------------------------------------
        //
        //  Variables
        //
        //--------------------------------------------------------------------------
        
        /**
         *  @private
         *  True if the renderer has been created and commitProperties hasn't
         *  run yet. See commitProperties.
         */
        private var setCurrentStateNeeded:Boolean = false;
        
        /**
         *  @private
         *  A flag determining if this renderer should play any 
         *  associated transitions when a state change occurs. 
         */
        mx_internal var playTransitions:Boolean = false; 
        
        //--------------------------------------------------------------------------
        //
        //  Properties
        //
        //--------------------------------------------------------------------------
        
        /**
         *  @private
         */
        private function dispatchChangeEvent(type:String):void
        {
            if (hasEventListener(type))
                dispatchEvent(new Event(type));
        }
        
        //----------------------------------
        //  baselinePosition override
        //----------------------------------
        
        /**
         *  @private
         */
        override public function get baselinePosition():Number
        {
            if (!validateBaselinePosition() || !labelDisplay)
                return super.baselinePosition;
            
            const labelPosition:Point = globalToLocal(labelDisplay.parent.localToGlobal(
                new Point(labelDisplay.x, labelDisplay.y)));
            
            return labelPosition.y + labelDisplay.baselinePosition;
        }
        
        //----------------------------------
        //  date
        //----------------------------------
        
        private var _date:Date = null;
                
        /**
         *  @inheritDoc
         *  
         *  @default null
         *  
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 2.5
         *  @productversion Flex 4.5
         */
        public function get date():Date
        {
            return _data as Date;
        }
        
        //----------------------------------
        //  down
        //----------------------------------
        
        /**
         *  @private
         *  storage for the down property 
         */
        private var _down:Boolean = false;
        
        /**
         *  @inheritDoc
         *
         *  @default false
         * 
         *  @langversion 3.0
         *  @playerversion Flash 11
         *  @playerversion AIR 3.0
         *  @productversion Flex 5.0
         */    
        public function get down():Boolean
        {
            return _down;
        }
        
        /**
         *  @private
         */    
        public function set down(value:Boolean):void
        {
            if (value == _down)
                return;
            
            _down = value;
            setCurrentState(getCurrentRendererState(), playTransitions);
        }
        
        //----------------------------------
        //  dragging
        //----------------------------------
        
        private var _dragging:Boolean = false;
        
        [Bindable("draggingChanged")]        
        
        /**
         *  @inheritDoc
         * 
         *  @langversion 3.0
         *  @playerversion Flash 11
         *  @playerversion AIR 3.0
         *  @productversion Flex 5.0
         */
        public function get dragging():Boolean
        {
            return _dragging;
        }
        
        /**
         *  @private  
         */
        public function set dragging(value:Boolean):void
        {
            if (_dragging == value)
                return;
            
            _dragging = value;
            setCurrentState(getCurrentRendererState(), playTransitions);
            dispatchChangeEvent("draggingChanged");        
        }
        
        //----------------------------------
        //  columnIndex
        //----------------------------------
        
        private var _columnIndex:int = -1;
        
        /**
         *  @inheritDoc 
         *  
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 2.5
         *  @productversion Flex 4.5
         */
        public function get columnIndex():int
        {
            return _columnIndex;
        }
        
        public function set columnIndex(value:int):void
        {
            _columnIndex = value;
        }

        //----------------------------------
        //  data
        //----------------------------------
        
        private var _data:Object = null;
        
        [Bindable("dataChange")]  // compatible with FlexEvent.DATA_CHANGE
        
        /**
         *  The value of the data provider item for the grid row 
         *  corresponding to the item renderer.
         *  This value corresponds to the object returned by a call to the 
         *  <code>dataProvider.getItemAt(rowIndex)</code> method.
         *
         *  <p>Item renderers can override this property definition to access 
         *  the data for the entire row of the grid. </p>
         *  
         *  @default null
         *  
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 2.5
         *  @productversion Flex 4.5
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
            if (_data == value)
                return;
            
            _data = value;
            
            const eventType:String = "dataChange"; 
            if (hasEventListener(eventType))
                dispatchEvent(new FlexEvent(eventType));  
        }
                      
        //----------------------------------
        //  hovered
        //----------------------------------
        
        private var _hovered:Boolean = false;
        
        /**
         *  @inheritDoc
         *
         *  @default false
         * 
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 2.5
         *  @productversion Flex 4.5
         */    
        public function get hovered():Boolean
        {
            return _hovered;
        }
        
        /**
         *  @private
         */    
        public function set hovered(value:Boolean):void
        {
            if (value == _hovered)
                return;
            
            _hovered = value;
            setCurrentState(getCurrentRendererState(), playTransitions);
        }
        
        //----------------------------------
        //  monthGrid
        //----------------------------------
        
        private var _monthGrid:MonthGrid = null;
        
        [Bindable("monthGridChange")]

        public function get monthGrid():MonthGrid
        {
            return _monthGrid;
        }
        
        /**
         *  @private
         */
        public function set monthGrid(value:MonthGrid):void
        {
            if (_monthGrid == value)
                return;
            
            _monthGrid = value;
       }
        
        //----------------------------------
        //  nextMonth
        //----------------------------------
        
        private var _nextMonth:Boolean = false;
        
        /**
         *  @inheritDoc 
         *  
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 2.5
         *  @productversion Flex 4.5
         */
        public function get nextMonth():Boolean
        {
            return _nextMonth;
        }
        
        public function set nextMonth(value:Boolean):void
        {
            _nextMonth = value;    
        }
        
        //----------------------------------
        //  previousMonth
        //----------------------------------
        
        private var _previousMonth:Boolean = false;
        
        /**
         *  @inheritDoc 
         *  
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 2.5
         *  @productversion Flex 4.5
         */
        public function get previousMonth():Boolean
        {
            return _previousMonth;
        }
        
        public function set previousMonth(value:Boolean):void
        {
            _previousMonth = value;    
        }
        
        //----------------------------------
        //  rowIndex
        //----------------------------------
        
        private var _rowIndex:int = -1;
        
        [Bindable("rowIndexChanged")]
        
        /**
         *  @inheritDoc
         * 
         *  <p>The Grid's <code>updateDisplayList()</code> method sets this property 
         *  before calling <code>prepare()</code></p>.   
         * 
         *  @default -1
         * 
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 2.5
         *  @productversion Flex 4.5
         */    
        public function get rowIndex():int
        {
            return _rowIndex;
        }
        
        /**
         *  @private
         */    
        public function set rowIndex(value:int):void
        {
            if (_rowIndex == value)
                return;
            
            _rowIndex = value;
            dispatchChangeEvent("rowIndexChanged");        
        }
                
        //----------------------------------
        //  selected
        //----------------------------------
        
        private var _selected:Boolean = false;
        
        [Bindable("selectedChanged")]    
        
        /**
         *  @inheritDoc
         * 
         *  <p>The Grid's <code>updateDisplayList()</code> method sets this property 
         *  before calling <code>preprare()</code></p>.   
         * 
         *  @default false
         * 
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 2.5
         *  @productversion Flex 4.5
         */    
        public function get selected():Boolean
        {
            return _selected;
        }
        
        /**
         *  @private
         */    
        public function set selected(value:Boolean):void
        {
            if (_selected == value)
                return;
            
            _selected = value;
            setCurrentState(getCurrentRendererState(), playTransitions);
            dispatchChangeEvent("selectedChanged");        
        }
        
        //----------------------------------
        //  showsCaret
        //----------------------------------
        
        private var _showsCaret:Boolean = false;
        
        [Bindable("showsCaretChanged")]    
        
        /**
         *  @inheritDoc
         * 
         *  <p>The Grid's <code>updateDisplayList()</code> method sets this property 
         *  before calling <code>preprare()</code></p>.   
         * 
         *  @default false
         * 
         *  @langversion 3.0
         *  @playerversion Flash 11
         *  @playerversion AIR 3.0
         *  @productversion Flex 5.0
         */    
        public function get showsCaret():Boolean
        {
            return _showsCaret;
        }
        
        /**
         *  @private
         */    
        public function set showsCaret(value:Boolean):void
        {
            if (_showsCaret == value)
                return;
            
            _showsCaret = value;
            setCurrentState(getCurrentRendererState(), playTransitions);
            dispatchChangeEvent("labelDisplayChanged");           
        }
        
        //----------------------------------
        //  today
        //----------------------------------
        
        private var _today:Boolean = false;
        
        /**
         *  @inheritDoc 
         *  
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 2.5
         *  @productversion Flex 4.5
         */
        public function get today():Boolean
        {
            return _today;
        }
        
        /**
         *  @private
         */    
        public function set today(value:Boolean):void
        {
            if (_today == value)
                return;
            
            _today = value;
        }

        //----------------------------------
        //  weekDay
        //----------------------------------
        
        private var _weekDay:Boolean = false;
        
        /**
         *  True if the day is not Saturday (day 6) or Sunday (day 0).
         *  Note there are a few locales which have a different definition of weekday.
         *  
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 2.5
         *  @productversion Flex 4.5
         */
        public function get weekday():Boolean
        {
            return _weekDay;
        }
        
        /**
         *  @private
         */    
        public function set weekday(value:Boolean):void
        {
            if (_weekDay == value)
                return;
            
            _weekDay = value;
        }

        //----------------------------------
        //  label
        //----------------------------------
        
        private var _label:String = "";
        
        [Bindable("labelChanged")]
        
        /**
         *  @copy IDateItemRenderer#label
         *
         *  @default ""
         * 
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 2.5
         *  @productversion Flex 4.5
         */
        public function get label():String
        {
            return _label;
        }
        
        /**
         *  @private
         */ 
        public function set label(value:String):void
        {
            if (_label == value)
                return;
            
            _label = value;
            
            if (labelDisplay)
                labelDisplay.text = _label;
            
            dispatchChangeEvent("labelChanged");
        }
        
        //----------------------------------
        //  labelDisplay
        //----------------------------------
        
        private var _labelDisplay:TextBase = null;
        
        [Bindable("labelDisplayChanged")]
        
        /**
         *  An optional visual component in the item renderer 
         *  for displaying the <code>label</code> property.   
         *  If you use this property to specify a visual component, 
         *  the component's <code>text</code> property is kept synchronized 
         *  with the item renderer's <code>label</code> property.
         * 
         *  @default null
         * 
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 2.5
         *  @productversion Flex 4.5
         */    
        public function get labelDisplay():TextBase
        {
            return _labelDisplay
        }
        
        /**
         *  @private
         */    
        public function set labelDisplay(value:TextBase):void
        {
            if (_labelDisplay == value)
                return;
            
            _labelDisplay = value;
            dispatchChangeEvent("labelDisplayChanged");        
        }
        
        //--------------------------------------------------------------------------
        //
        //  Methods - ItemRenderer State Support 
        //
        //--------------------------------------------------------------------------
        
        /**
         *  Returns the name of the state to be applied to the renderer. 
         *  For example, a basic item renderer returns the String "normal", "hovered", 
         *  or "selected" to specify the renderer's state. 
         *  If dealing with touch interactions (or mouse interactions where selection
         *  is ignored), "down" and "downAndSelected" can also be returned.
         * 
         *  <p>A subclass of GridItemRenderer must override this method to return a value 
         *  if the behavior desired differs from the default behavior.</p>
         * 
         *  <p>In Flex 4.0, the 3 main states were "normal", "hovered", and "selected".
         *  In Flex 4.5, "down" and "downAndSelected" have been added.</p>
         *  
         *  <p>The full set of states supported (in order of precedence) are: 
         *    <ul>
         *      <li>dragging</li>
         *      <li>downAndSelected</li>
         *      <li>selectedAndShowsCaret</li>
         *      <li>hoveredAndShowsCaret</li>
         *      <li>normalAndShowsCaret</li>
         *      <li>down</li>
         *      <li>selected</li>
         *      <li>hovered</li>
         *      <li>normal</li>
         *    </ul>
         *  </p>
         * 
         *  @return A String specifying the name of the state to apply to the renderer. 
         *  
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 2.5
         *  @productversion Flex 4.5
         */
        
        protected function getCurrentRendererState():String
        {
            // this code is pretty confusing without multi-dimensional states, but it's
            // defined in order of precedence.
            
            //if (dragging && hasState("dragging"))
            //    return "dragging";
            
            //if (selected && down && hasState("downAndSelected"))
            //    return "downAndSelected";
            
            if (selected && showsCaret && hasState("selectedAndShowsCaret"))
                return "selectedAndShowsCaret";
            
            if (hovered && showsCaret && hasState("hoveredAndShowsCaret"))
                return "hoveredAndShowsCaret";
            
            if (showsCaret && hasState("normalAndShowsCaret"))
                return "normalAndShowsCaret"; 
            
            //if (down && hasState("down"))
            //    return "down";
            
            if (selected && hasState("selected"))
                return "selected";
            
            if (hovered && hasState("hovered"))
                return "hovered";
            
            if (hasState("normal"))    
                return "normal";
            
            // If none of the above states are defined in the item renderer,
            // we return null. This means the user-defined renderer
            // will display but essentially be non-interactive visually. 
            return null;
        }
        
        //--------------------------------------------------------------------------
        //
        //  Overridden Methods
        //
        //--------------------------------------------------------------------------
        
//        override public function setLayoutBoundsPosition(x:Number, y:Number, postLayoutTransform:Boolean=true):void
//        {
//            trace("DateIR", date, "x", x, "y", y, "rowIndex", rowIndex, "colIndex", columnIndex);
//            super.setLayoutBoundsPosition(x, y, postLayoutTransform);
//        }

        /**
         *  @private
         */ 
        override protected function commitProperties():void
        {
            super.commitProperties();
            
            if (setCurrentStateNeeded)
            {
                setCurrentState(getCurrentRendererState(), playTransitions); 
                setCurrentStateNeeded = false;
            }
        }
        
        /**
         *  @private
         */
        override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
        {
            super.updateDisplayList(width, height);
        } 
        
        override public function toString():String
        {
            return "(" + rowIndex + "." + columnIndex + ") " + (date ? date.toLocaleString() : "") + " today=" + today + " weekDay=" + weekday + " selected=" + selected;
        }

        /**
         *  @inheritDoc
         *  
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 2.5
         *  @productversion Flex 4.5
         */
        public function prepare(hasBeenRecycled:Boolean):void
        {
        }
        
        /**
         *  @inheritDoc
         *  
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 2.5
         *  @productversion Flex 4.5
         */
        public function discard(willBeRecycled:Boolean):void
        {
        }        
    }
}