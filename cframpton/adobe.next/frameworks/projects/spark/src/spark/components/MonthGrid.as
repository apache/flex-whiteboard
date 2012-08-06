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
import flash.display.InteractiveObject;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.utils.getTimer;

import mx.core.IFactory;
import mx.core.mx_internal;
import mx.events.FlexEvent;

import spark.components.calendarClasses.DateSelection;
import spark.components.calendarClasses.DateSet;
import spark.components.calendarClasses.DateUtil;
import spark.components.calendarClasses.IDateItemRenderer;
import spark.components.calendarClasses.MonthGridLayout;
import spark.components.calendarClasses.SixWeekLayoutMode;
import spark.components.calendarClasses.WeekOrientation;
import spark.events.MonthGridEvent;
import spark.formatters.DateTimeFormatter;
import spark.layouts.supportClasses.LayoutBase;
import spark.utils.MouseEventUtil;

use namespace mx_internal;

[Exclude(name="layout", kind="property")]

/**
 *  The MonthGrid class displays a grid of cells: a row/column of headers for the names of the days 
 *  of the week, and rows/columns of cells for each day of the month, laid out in weeks.  If the
 *  month's weekOrientation is "rows", the reading order is by rows and if it is "columns" 
 *  the reading order is by columns.
 * 
 *  <p>Headers are rendered by the class specified by the <code>dayOfTheWeekRenderer</code> property.
 *  Days of the month are rendered by the class sepcified by the <code>dayOfTheMonthRenderer</code> 
 *  property.
 *  Column separators are rendered by the class specified by the <code>columnSeparator</code> 
 *  property and row separators are rendered by the class specified by the <code>rowSeparator</code>
 *  property.</p>
 *
 *  <p>You can change the format of the days of the week by setting the 
 *  <code>dayOfTheWeekFormatter</code> property and you can change the format of the days in the 
 *  month by setting the <code>dayOfTheMonthFormatter</code>.</p>
 * 
 *  You can control the size of the cells by setting the <code>requestedCellWidth</code>, 
 *  <code>requestedCellHeight</code>, <code>requestedHeaderSize</code> and padding properties.  
 *  You can control the spacing between the cells using the <code>horizontalGap</code>,
 *  <code>verticalGap</code> and <code>headerGap</code> properties.
 * 
 *  There are also properties which allow you to control the display of days that come before or
 *  after the days in the current month.
 * 
 *  Do not modify the <code>layout</code> property. 
 *  Instead, use the properties of the MonthGrid class to modify the characteristics of the 
 *  MonthGridLayout class.
 */

// Questions: 
// - what if you want the headers one color, the days of the week a 2nd color and the dates a 3rd color?
// - what if you want the header background color to go straight across - including spaces between renders
// - toolTips on the date cells?

public class MonthGrid extends Group
{
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

    public function MonthGrid()
    {
        super();
        super.layout = new MonthGridLayout();        
         
        MouseEventUtil.addDownDragUpListeners(this, 
            monthGrid_mouseDownDragUpHandler, 
            monthGrid_mouseDownDragUpHandler, 
            monthGrid_mouseDownDragUpHandler);
        
        addEventListener(MouseEvent.MOUSE_UP, monthGrid_mouseUpHandler);
        addEventListener(MouseEvent.MOUSE_MOVE, monthGrid_mouseMoveHandler);
        addEventListener(MouseEvent.ROLL_OUT, monthGrid_mouseRollOutHandler);      

    }
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
        
    private var inUpdateDisplayList:Boolean;

    /**
     *  @private
     *  Set to specify custom weekday names.  This will override the dayOfTheWeekFormatter values.
     *  The array should contain 7 string values, for example, ["1","2","3","4","5","6","7"].
     */     
    mx_internal var dayNamesOverride:Array = null;
    
    //--------------------------------------------------------------------------
    //
    //  Properties 
    //
    //--------------------------------------------------------------------------
        
    //----------------------------------
    //  caretDate
    //----------------------------------
    
    /**
     * @private
     */
    public function get caretDate():Date
    {
        return dateChooser ? dateChooser.caretDate : null;
    }
    
    //----------------------------------
    //  caretIndicator
    //----------------------------------
    
    private var _caretIndicator:IFactory = null;
    
    [Bindable("caretIndicatorChanged")]
    
    /**
     *  A visual element that's displayed for the caret date cell.
     *  
     *  @default null
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 5.0
     */
    public function get caretIndicator():IFactory
    {
        return _caretIndicator;
    }
    
    /**
     *  @private
     */
    public function set caretIndicator(value:IFactory):void
    {
        if (_caretIndicator == value)
            return;
        
        _caretIndicator = value;
        invalidateDisplayListFor("caretIndicator");
        
        dispatchChangeEvent("caretIndicatorChanged");
    }    
    
    //----------------------------------
    //   cellHeight
    //----------------------------------
    
    private var _cellHeight:Number = NaN;
    
    [Bindable("cellHeightChanged")]
    [Inspectable(category="General", minValue="0.0")]
    
    /**
     *  The height of the day of the month cell, including cell padding, in pixels.
     *
     *  @see #requestedCellHeight
     * 
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5.0
     */
    public function get cellHeight():Number
    {
        return _cellHeight;
    }
    
    /**
     *  @private
     */
    public function setCellHeight(value:Number):void
    {
        if (_cellHeight == value || (isNaN(_cellHeight) && isNaN(value)))
            return;
        
        _cellHeight = value < 0 ? 0 : value;
        
        invalidateSize()
        invalidateDisplayListFor("grid");
        
        dispatchChangeEvent("cellHeightChanged");
    }    

    //----------------------------------
    //  cellPaddingBottom
    //----------------------------------
    
    private var _cellPaddingBottom:Number = 0;
    
    [Bindable("cellPaddingBottomChanged")]
    [Inspectable(category="General", minValue="0.0")]
    
    /**
     *  Bottom inset, in pixels, for all cell renderers. 
     * 
     *  @default 0
     *  
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5.0.0
     */
    public function get cellPaddingBottom():Number
    {
        return _cellPaddingBottom;
    }
    
    /**
     *  @private
     */
    public function set cellPaddingBottom(value:Number):void
    {
        if (_cellPaddingBottom == value)
            return;
        
        _cellPaddingBottom = isNaN(value) || value < 0 ? 0 : value;
        
        invalidateSize()
        invalidateDisplayListFor("grid");
        
        dispatchChangeEvent("cellPaddingBottomChanged");
    }
    
   //----------------------------------
    //  cellPaddingLeft
    //----------------------------------
    
    private var _cellPaddingLeft:Number = 0;
    
    [Bindable("cellPaddingLeftChanged")]
    [Inspectable(category="General", minValue="0.0")]
    
    /**
     *  Left inset, in pixels, for all cell renderers. 
     * 
     *  @default 0
     *  
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5.0.0
     */
    public function get cellPaddingLeft():Number
    {
        return _cellPaddingLeft;
    }
    
    /**
     *  @private
     */
    public function set cellPaddingLeft(value:Number):void
    {
        if (_cellPaddingLeft == value)
            return;
        
        _cellPaddingLeft = isNaN(value)  || value < 0 ? 0 : value;
        
        invalidateSize()
        invalidateDisplayListFor("grid");
        
        dispatchChangeEvent("cellPaddingLeftChanged");
    }    
    
    //----------------------------------
    //  cellPaddingRight
    //----------------------------------
    
    private var _cellPaddingRight:Number = 0;
    
    [Bindable("cellPaddingRightChanged")]
    [Inspectable(category="General")]
    [Inspectable(category="General", minValue="0.0")]
    
    /**
     *  Right inset, in pixels, for all cell renderers. 
     * 
     *  @default 0
     *  
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5.0.0
     */
    public function get cellPaddingRight():Number
    {
        return _cellPaddingRight;
    }
    
    /**
     *  @private
     */
    public function set cellPaddingRight(value:Number):void
    {
        if (_cellPaddingRight == value)
            return;
        
        _cellPaddingRight = isNaN(value) || value < 0 ? 0 : value;
        
        invalidateSize()
        invalidateDisplayListFor("grid");
        
        dispatchChangeEvent("cellPaddingRightChanged");
    }    
    
    //----------------------------------
    //  cellPaddingTop
    //----------------------------------
    
    private var _cellPaddingTop:Number = 0;
    
    [Bindable("cellPaddingTopChanged")]
    [Inspectable(category="General")]
    [Inspectable(category="General", minValue="0.0")]
    
    /**
     *  Top inset, in pixels, for all cell renderers. 
     * 
     *  @default 0
     *  
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5.0.0
     */
    public function get cellPaddingTop():Number
    {
        return _cellPaddingTop;
    }
    
    /**
     *  @private
     */
    public function set cellPaddingTop(value:Number):void
    {
        if (_cellPaddingTop == value)
            return;
        
        _cellPaddingTop = isNaN(value)  || value < 0 ? 0 : value;
        
        invalidateSize()
        invalidateDisplayListFor("grid");
        
        dispatchChangeEvent("cellPaddingTopChanged");
    }    
    
    //----------------------------------
    //  cellWidth
    //----------------------------------
    
    private var explicitCellWidth:Number = NaN;
    private var _cellWidth:Number = NaN;
    
    [Bindable("cellWidthChanged")]
    [Inspectable(category="General", minValue="0.0")]

    /**
     *  The actual width of the day of the month cell including cell padding, in pixels.
     * 
     *  @see #requestedCellWidth
     * 
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5.0
     */
    public function get cellWidth():Number
    {
        return _cellWidth;
    }
    
    /**
     *  @private
     */
    public function setCellWidth(value:Number):void
    {
        if (_cellWidth == value || (isNaN(_cellWidth) && isNaN(value)))
            return;
        
        _cellWidth = value < 0 ? 0 : value;
        
        invalidateSize()
        invalidateDisplayListFor("grid");
        
        dispatchChangeEvent("cellWidthChanged");
    }    
        
    //----------------------------------
    //  columnSeparator
    //----------------------------------
    
    private var _columnSeparator:IFactory = null;
    
    [Bindable("columnSeparatorChanged")]
    
    /**
     *  A visual element displayed between each column in the month layout.
     * 
     *  @default null
     * 
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5.0.0
     */
    public function get columnSeparator():IFactory
    {
        return _columnSeparator;
    }
    
    /**
     *  @private
     */
    public function set columnSeparator(value:IFactory):void
    {
        if (_columnSeparator == value)
            return;
        
        _columnSeparator = value;
        invalidateDisplayListFor("grid");
        dispatchChangeEvent("columnSeparatorChanged");
    }    
    
    //----------------------------------
    //  dateChooser
    //----------------------------------
    
    private var _dateChooser:DateChooser = null;
    
    [Bindable("dateChooserChanged")]
    
    /**
     *  The DateChooser control associated with this MonthGrid.
     * 
     *  @default null
     *
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5.0
     */
    public function get dateChooser():DateChooser
    {
        return _dateChooser;
    }
    
    /**
     *  @private
     */
    public function set dateChooser(value:DateChooser):void
    {
        if (_dateChooser == value)
            return;
        
        _dateChooser = value;
        dispatchChangeEvent("dateChooserChanged");
    }
            
    //----------------------------------
    //  displayedMonth
    //----------------------------------
    
    private var _displayedMonth:int = new Date().month;
    
    [Bindable("dateChanged")]
    
    /**
     *  Specifies the month that will be displayed.
     *  Setting this property will change the appearance of the component.
     *  This should be set by the month item renderer when this group becomes visible.
     *  
     *  @default "current month"
     * 
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5.0
     */
    public function get displayedMonth():int
    {
        return _displayedMonth;
    }
    
    /**
     *  @private
     */
    public function set displayedMonth(value:int):void
    {
        if (value < 0 || value > 11)
            value = 0;
        
        if (value == _displayedMonth)
            return;
               
        _displayedMonth = value;
        
        invalidateDisplayListFor("grid");
        
        dispatchChangeEvent("dateChanged");
    } 

    //----------------------------------
    //  displayedYear
    //----------------------------------
    
    private var _displayedYear:int = new Date().fullYear;
    
    [Bindable("dateChanged")]
    
    /**
     *  Specifies the month that will be displayed.
     *  Setting this property will change the appearance of the component.
     *  This should be set by the month item renderer when this group becomes visible.
     *  
     *  @default "current year"
     * 
     *  @see #displayMode
     * 
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5.0
     */
    public function get displayedYear():int
    {
        return _displayedYear;
    }
    
    /**
     *  @private
     */
    public function set displayedYear(value:int):void
    {
        if (value < DateChooser.MIN_DATE.fullYear)
            value = DateChooser.MIN_DATE.fullYear;
        else if (value > DateChooser.MAX_DATE.fullYear)
            value = DateChooser.MAX_DATE.fullYear;
        
        if (value == _displayedYear)
            return;
        
        _displayedYear = value;
        
        invalidateDisplayListFor("grid");
        
        dispatchChangeEvent("dateChanged");
    } 

    //----------------------------------
    //  dateSelection (mx_internal)
    //----------------------------------
    
    private var _dateSelection:DateSelection;
    
    /**
     *  @private
     */
    mx_internal function get dateSelection():DateSelection
    {
        return _dateSelection;
    }
    
    /**
     *  @private
     *  If this is serving as a DataChooser skin part, then this property is created 
     *  by DataChooser/partAdded() and then set here.   It is only set once, unless that 
     *  "monthGrid" part is removed, at which point it's set to null.
     */
    mx_internal function set dateSelection(value:DateSelection):void
    {
        _dateSelection = value;
    }
    
    //----------------------------------
    //  dayOfTheMonthFormatter
    //----------------------------------
    
    private var _dayOfTheMonthFormatter:DateTimeFormatter = null;
    private var dayOfTheMonthFormatterChanged:Boolean;
    
    [Bindable("dayOfTheMonthFormatterChanged")]
    
    /**
     *  The formatter that is used to format the day of the month.
     * 
     *  <p>For example, if the <code>dateTimePattern</code> where:</p> 
     *  <pre>
     *  "d", the day would be the miniumum number of digits, ie no leading zero
     *  "dd", the day would be a numeric in two digits
     *  </pre>
     * 
     *  @default "formatter for minimum number of digits"
     * 
     *  @see spark.formatters.DateTimeFormatter#dateTimePattern
     * 
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5.0
     */
    public function get dayOfTheMonthFormatter():DateTimeFormatter
    {
        // Default is min number of digits - either 1 or 2.
        if (_dayOfTheMonthFormatter == null)
        {
            _dayOfTheMonthFormatter = new DateTimeFormatter();
            _dayOfTheMonthFormatter.dateTimePattern = "d";
        }
        
        return _dayOfTheMonthFormatter;
    }
    
    /**
     *  @private
     */
    public function set dayOfTheMonthFormatter(value:DateTimeFormatter):void
    {
        if (_dayOfTheMonthFormatter == value)
            return;
        
        _dayOfTheMonthFormatter = value;
        
        invalidateProperties();
        invalidateSize()
        invalidateDisplayListFor("grid");
        
        dispatchChangeEvent("dayOfTheMonthFormatterChanged");
    }    
    
    //----------------------------------
    //  dayOfTheMonthRenderer
    //----------------------------------
    
    private var _dayOfTheMonthRenderer:IFactory = null;
    private var dayOfTheMonthRendererChanged:Boolean;
    
    [Bindable("dayOfTheMonthRendererChanged")]
    
    /**
     *  The IDateItemRenderer class that is used to render the day of the month.
     *  The <code>label</code> field of the renderer is set with the day of the month which has been
     *  formatted using the <code>dayOfTheMonthFormatter</code>.
     * 
     *  @see #dayOfTheMonthFormatter
     *  @see spark.components.calendarClasses.DataRenderer
     *  @see spark.components.calendarClasses.IDataRenderer
     * 
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5.0
     */
    public function get dayOfTheMonthRenderer():IFactory
    {
        return _dayOfTheMonthRenderer;
    }
    
    /**
     *  @private
     */
    public function set dayOfTheMonthRenderer(value:IFactory):void
    {
        if (_dayOfTheMonthRenderer == value)
            return;
        
        _dayOfTheMonthRenderer = value;
        
        invalidateProperties();
        invalidateSize()
        invalidateDisplayListFor("grid");
        dayOfTheMonthRendererChanged = true;
        
        dispatchChangeEvent("dayOfTheMonthRendererChanged");
    }    
    
    //----------------------------------
    //  dayOfTheWeekFormatter
    //----------------------------------
    
    private var _dayOfTheWeekFormatter:DateTimeFormatter = null;
    private var dayOfTheWeekFormatterChanged:Boolean;
    
    [Bindable("dayOfTheWeekFormatterChanged")]
    
    /**
     *  The formatter that is used to format the names of the days in the week.
     * 
     *  <p>For example, if the <code>dateTimePattern</code> where:</p> 
     *  <pre>
     *  "EEEE", the short abbreviation for the day in the week would be used
     *  "EEE", the full name of the day in the week would be used
     *  "E" the long abbreviation of the day in the week would be used.
     *  </pre>
     * 
     *  @default "formatter for the short abbreviation of the day in week"
     * 
     *  @see spark.formatters.DateTimeFormatter#dateTimePattern
     * 
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5.0
     */
    public function get dayOfTheWeekFormatter():DateTimeFormatter
    {
        // Default is short abbreviation.
        if (_dayOfTheWeekFormatter == null)
        {
            _dayOfTheWeekFormatter = new DateTimeFormatter();
            _dayOfTheWeekFormatter.dateTimePattern = "EEEE";
        }
        
        return _dayOfTheWeekFormatter;
    }
    
    /**
     *  @private
     */
    public function set dayOfTheWeekFormatter(value:DateTimeFormatter):void
    {
        if (_dayOfTheWeekFormatter == value)
            return;
        
        _dayOfTheWeekFormatter = value;
        
        invalidateSize()
        invalidateDisplayListFor("grid");
        dayOfTheWeekFormatterChanged = true;
        
        dispatchChangeEvent("dayOfTheWeekFormatterChanged");
    }    

    //----------------------------------
    //  dayOfTheWeekRenderer
    //----------------------------------
    
    private var _dayOfTheWeekRenderer:IFactory = null;
    private var dayOfTheWeekRendererChanged:Boolean;
    
    [Bindable("dayOfTheWeekRendererChanged")]
    
    /**
     *  The IDateItemRenderer class that is used to render the day of the week.
     *  The <code>label</code> field of the renderer is set with the day of the week which has been
     *  formatted using the <code>dayOfTheWeekFormatter</code>.
     * 
     *  @default null
     * 
     *  @see #dayOfTheWeekFormatter
     *  @see spark.components.calendarClasses.DataRenderer
     *  @see spark.components.calendarClasses.IDataRenderer
     * 
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5.0
     */
    public function get dayOfTheWeekRenderer():IFactory
    {
        return _dayOfTheWeekRenderer;
    }
    
    /**
     *  @private
     */
    public function set dayOfTheWeekRenderer(value:IFactory):void
    {
        if (_dayOfTheWeekRenderer == value)
            return;
        
        _dayOfTheWeekRenderer = value;
        
        invalidateProperties();
        invalidateSize()
        invalidateDisplayListFor("grid");
        dayOfTheWeekRendererChanged = true;
        
        dispatchChangeEvent("dayOfTheWeekRendererChanged");
    }    
    
    //----------------------------------
    //  headerGap
    //----------------------------------
    
    private var _headerGap:Number = 2;
    
    [Bindable("headerGapChanged")]
    [Inspectable(category="General")]
    
    /**
     *  Space between the headers, which contain the names of the days of the week, and the 
     *  dates in the month, in pixels.
     *  If the <code>weekOrientation</code> is <code>rows</code> it is vertical space, otherwise
     *  the space is horizontal.
     *
     *  @default 2
     *  
     *  @see #horizontalGap
     *  @see #verticalGap
     *  @see #weekOrientation
     *
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5.0.0
     */
    public function get headerGap():Number
    {
        return _headerGap;
    }
    
    /**
     *  @private
     */
    public function set headerGap(value:Number):void
    {
        if (value == _headerGap)
            return;
        
        _headerGap = isNaN(value) ? 0 : value;
        
        invalidateSize()
        invalidateDisplayListFor("grid");
        
        dispatchChangeEvent("headerGapChanged");
    }

    //----------------------------------
    //  headerSize
    //----------------------------------
    
    private var _headerSize:Number = NaN;
    
    [Bindable("headerSizeChanged")]
    
    /**
     *  In pixels, either the width or the height of the day name headers, 
     *  depending on <code>weekOrientation</code>.
     * 
     *  @see #requestedHeaderSize
     * 
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5.0
     */
    public function get headerSize():Number
    {
        return _headerSize;
    }
    
    /**
     *  @private
     */
    public function setHeaderSize(value:Number):void
    {
        if (_headerSize == value || (isNaN(_headerSize) && isNaN(value)))
            return;
        
        _headerSize = value < 0 ? 0 : value;
        
        invalidateSize()
        invalidateDisplayListFor("grid");
        
        dispatchChangeEvent("headerSizeChanged");
    }    
    
    //----------------------------------
    //  horizontalGap
    //----------------------------------
    
    private var _horizontalGap:Number = 2;
    
    [Bindable("horizontalGapChanged")]
    [Inspectable(category="General")]
    
    /**
     *  Horizontal space between columns, in pixels.
     *
     *  @default 2
     *  
     *  @see #headerGap
     *  @see #verticalGap
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 3.0
     *  @productversion Flex 5.0
     */
    public function get horizontalGap():Number
    {
        return _horizontalGap;
    }
    
    /**
     *  @private
     */
    public function set horizontalGap(value:Number):void
    {
        if (value == _horizontalGap)
            return;
        
        _horizontalGap = isNaN(value) ? 0 : value;
        
        invalidateSize()
        invalidateDisplayListFor("grid");
        
        dispatchChangeEvent("horizontalGapChanged");
    }
    
    //----------------------------------
    //  hoverColumnIndex 
    //----------------------------------
    
    private var _hoverColumnIndex:int = -1;
    
    [Bindable("hoverColumnIndexChanged")]
    
    /**
     *  Specifies column index of the <code>hoverIndicator</code> in the grid of date renderers.
     *  
     *  <p>If either the <code>hoverRowIndex</code> or <code>hoverColumnIndex</code> is -1
     *  or an invalid value the hover indicator is not displayed.</p>
     * 
     *  @default -1
     * 
     *  @see hoverRowIndex
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 3.0
     *  @productversion Flex 5.0
     */
    public function get hoverColumnIndex():int
    {
        return _hoverColumnIndex;
    }
    
    /**
     *  @private
     */
    public function set hoverColumnIndex(value:int):void
    {
        if (_hoverColumnIndex == value)
            return;
        
        _hoverColumnIndex = value;
        
        // Unconditionally invalidate because renderers may depend on
        // hoverColumnIndex even when the hoverIndicator doesn't exist.
        invalidateDisplayListFor("hoverIndicator");
        
        dispatchChangeEvent("hoverColumnIndexChanged");
    }
    
    //----------------------------------
    //  hoverIndicator
    //----------------------------------
    
    private var _hoverIndicator:IFactory = null;
    
    [Bindable("hoverIndicatorChanged")]
    
    /**
     *  A visual element that's displayed on top of the date cell under the mouse.
     *  
     *  @default null
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 5.0
     */
    public function get hoverIndicator():IFactory
    {
        return _hoverIndicator;
    }
    
    /**
     *  @private
     */
    public function set hoverIndicator(value:IFactory):void
    {
        if (_hoverIndicator == value)
            return;
        
        _hoverIndicator = value;
        invalidateDisplayListFor("hoverIndicator");

        dispatchChangeEvent("hoverIndicatorChanged");
    }    
        
    //----------------------------------
    //  hoverRowIndex
    //----------------------------------
    
    private var _hoverRowIndex:int = -1;
    
    [Bindable("hoverRowIndexChanged")]
    
    /**
     *  Specifies row index of the <code>hoverIndicator</code> in the grid of date renderers.
     * 
     *  <p>If either the <code>hoverRowIndex</code> or <code>hoverColumnIndex</code> is -1
     *  or an invalid value the hover indicator is not displayed.</p>
     * 
     *  @default -1
     * 
     *  @see hoverColumnIndex
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 3.0
     *  @productversion Flex 5.0
     */
    public function get hoverRowIndex():int
    {
        return _hoverRowIndex;
    }
    
    /**
     *  @private
     */
    public function set hoverRowIndex(value:int):void
    {
        if (_hoverRowIndex == value)
            return;
        
        _hoverRowIndex = value;
        
        // Unconditionally invalidate because renderers may depend on
        // hoverRowIndex even when the hoverIndicator doesn't exist.
        invalidateDisplayListFor("hoverIndicator");
        
        dispatchChangeEvent("hoverRowIndexChanged");
    }
    
    //----------------------------------
    //  paddingLeft
    //----------------------------------
    
    private var _paddingLeft:Number = 0;
    
    [Bindable("paddingLeftChanged")]
    [Inspectable(category="General")]
    
    /**
     *  The minimum number of pixels between the container's left edge and
     *  the left edge of the month layout.
     * 
     *  @default 0
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 3.0
     *  @productversion Flex 5.0
     */
    public function get paddingLeft():Number
    {
        return _paddingLeft;
    }
    
    /**
     *  @private
     */
    public function set paddingLeft(value:Number):void
    {
        if (_paddingLeft == value)
            return;
        
        _paddingLeft = isNaN(value) ? 0 : value;
        
        invalidateSize()
        invalidateDisplayListFor("grid");
        
        dispatchChangeEvent("paddingLeftChanged");
    }    
    
    //----------------------------------
    //  paddingRight
    //----------------------------------
    
    private var _paddingRight:Number = 0;
    
    [Bindable("paddingRightChanged")]
    [Inspectable(category="General")]
    
    /**
     *  The minimum number of pixels between the container's right edge and
     *  the right edge of the month layout.
     * 
     *  @default 0
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 3.0
     *  @productversion Flex 5.0
     */
    public function get paddingRight():Number
    {
        return _paddingRight;
    }
    
    /**
     *  @private
     */
    public function set paddingRight(value:Number):void
    {
        if (_paddingRight == value)
            return;
        
        _paddingRight = isNaN(value) ? 0 : value;
        
        invalidateSize()
        invalidateDisplayListFor("grid");
        
        dispatchChangeEvent("paddingRightChanged");
    }    
    
    //----------------------------------
    //  paddingTop
    //----------------------------------
    
    private var _paddingTop:Number = 0;
    
    [Bindable("paddingTopChanged")]
    [Inspectable(category="General")]
    
    /**
     *  Number of pixels between the container's top edge
     *  and the top edge of the of the month layout.
     * 
     *  @default 0
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 3.0
     *  @productversion Flex 5.0
     */
    public function get paddingTop():Number
    {
        return _paddingTop;
    }
    
    /**
     *  @private
     */
    public function set paddingTop(value:Number):void
    {
        if (_paddingTop == value)
            return;
        
        _paddingTop = isNaN(value) ? 0 : value;
        
        invalidateSize()
        invalidateDisplayListFor("grid");
        
        dispatchChangeEvent("paddingTopChanged");
    }    
    
    //----------------------------------
    //  paddingBottom
    //----------------------------------
    
    private var _paddingBottom:Number = 0;
    
    [Bindable("paddingBottomChanged")]
   [Inspectable(category="General")]
    
    /**
     *  Number of pixels between the container's bottom edge
     *  and the bottom edge of the of the month layout.
     * 
     *  @default 0
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 3.0
     *  @productversion Flex 5.0
     */
    public function get paddingBottom():Number
    {
        return _paddingBottom;
    }
    
    /**
     *  @private
     */
    public function set paddingBottom(value:Number):void
    {
        if (_paddingBottom == value)
            return;
        
        _paddingBottom = isNaN(value) ? 0 : value;
        
        invalidateSize()
        invalidateDisplayListFor("grid");
        
        dispatchChangeEvent("paddingBottomChanged");
    }
    
    //----------------------------------
    //   requestedCellHeight
    //----------------------------------
    
    private var _requestedCellHeight:Number = NaN;
    
    [Bindable("requestedCellHeightChanged")]
    [Inspectable(category="General", minValue="0.0")]
    
    /**
     *  The requested height of the day of the month cell including cell padding, in pixels.
     * 
     *  <p>If set to <code>NaN</code>, the cell height is the height of
     *  <code>dayOfTheMonthRenderer</code>  plus <code>cellPaddingTop</code> and 
     *  <code>cellPaddingBottom</code>.</p>
     * 
     *  <p>To determine the actual height of a cell use <code>cellHeight</code>.</p>
     * 
     *  @default NaN
     * 
     *  @see #cellHeight
     * 
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5.0
     */
    public function get requestedCellHeight():Number
    {
        return _requestedCellHeight;
    }
    
    /**
     *  @private
     */
    public function set requestedCellHeight(value:Number):void
    {
        if (_requestedCellHeight == value || (isNaN(_requestedCellHeight) && isNaN(value)))
            return;
        
        _requestedCellHeight = value < 0 ? 0 : value;
        
        invalidateSize()
        invalidateDisplayListFor("grid");
        
        dispatchChangeEvent("requestedCellHeightChanged");
    }    
    

    //----------------------------------
    //  requestedCellWidth
    //----------------------------------
    
    private var _requestedCellWidth:Number = NaN;
    
    [Bindable("requestedCellWidthChanged")]
    [Inspectable(category="General", minValue="0.0")]
    
    /**
     *  The requested width of the day of the month cell, including cell padding, in pixels.
     * 
     *  <p>If set to <code>NaN</code>, the cell width is the width of the 
     *  <code>dayOfTheMonthRenderer</code>  plus <code>cellPaddingLeft</code> and 
     *  <code>cellPaddingRight</code>.</p>
     * 
     *  <p>To determine the actual width of a cell use <code>cellWidth</code>.</p>
     * 
     *  @default NaN
     * 
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5.0
     */
    public function get requestedCellWidth():Number
    {
        return _requestedCellWidth;
    }
    
    /**
     *  @private
     */
    public function set requestedCellWidth(value:Number):void
    {
        explicitCellWidth = value;
        if (_requestedCellWidth == value || (isNaN(_requestedCellWidth) && isNaN(value)))
            return;
        
        _requestedCellWidth = value < 0 ? 0 : value;
        
        invalidateSize()
        invalidateDisplayListFor("grid");
        
        dispatchChangeEvent("requestedCellWidthChanged");
    }    
   
    //----------------------------------
    //  requestedHeaderSize
    //----------------------------------
    
    private var _requestedHeaderSize:Number = NaN;
    
    [Bindable("requestedHeaderSizeChanged")]
    
    /**
     *  In pixels, either the requested width or the requested height of the day name headers, 
     *  depending on <code>weekOrientation</code>.
     * 
     *  <p>If <code>weekOrientation</code> is <code>rows</code>, the header width is the
     *  <code>cellWidth</code> and the header height is the <code>headerSize</code>.
     *  If <code>weekOrientation</code> is <code>columns</code>, the header width is
     *  the <code>headerSize</code> and the header height is the <code>cellHeight</code>.</p>
     *
     *  <p>If set to <code>NaN</code>, the header size is computed using the 
     *  <code>dayOfTheWeekRenderer</code> and cell padding.  If will be large enough to
     *  fit every day name in the relevant dimension.</p>
     * 
     *  @default NaN
     * 
     *  @see #weekOrientation
     *  @see #dayOfTheWeekRenderer
     * 
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5.0
     */
    public function get requestedHeaderSize():Number
    {
        return _requestedHeaderSize;
    }
    
    /**
     *  @private
     */
    public function set requestedHeaderSize(value:Number):void
    {
        if (_requestedHeaderSize == value || (isNaN(_requestedHeaderSize) && isNaN(value)))
            return;
        
        _requestedHeaderSize = value < 0 ? 0 : value;
        
        invalidateSize()
        invalidateDisplayListFor("grid");
        
        dispatchChangeEvent("requestedHeaderSizeChanged");
    }    
        
    //----------------------------------
    //  rowSeparator
    //----------------------------------
    
    private var _rowSeparator:IFactory = null;
    
    [Bindable("rowSeparatorChanged")]
    
    /**
     *  A visual element that's displayed in between each row in the month layout.
     * 
     *  @default null
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 5.0
     */
    public function get rowSeparator():IFactory
    {
        return _rowSeparator;
    }
    
    /**
     *  @private
     */
    public function set rowSeparator(value:IFactory):void
    {
        if (_rowSeparator == value)
            return;
        
        _rowSeparator = value;
        invalidateDisplayListFor("grid");
        dispatchChangeEvent("rowSeparatorChanged");
    }    

    //----------------------------------
    //  selectableDates
    //----------------------------------
    
    /**
     * @private
     */
    public function get selectableDates():DateSet
    {
        return dateChooser ? dateChooser.selectableDates : null;
    }
    
    //----------------------------------
    //  selectionIndicator
    //----------------------------------
    
    private var _selectionIndicator:IFactory = null;
    
    [Bindable("selectionIndicatorChanged")]
    
    /**
     *  A visual element that's displayed on top of each date cell that is selected.
     *  
     *  @default null
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 5.0
     */
    public function get selectionIndicator():IFactory
    {
        return _selectionIndicator;
    }
    
    /**
     *  @private
     */
    public function set selectionIndicator(value:IFactory):void
    {
        if (_selectionIndicator == value)
            return;
        
        _selectionIndicator = value;
        
        invalidateDisplayListFor("selectionIndicator");
        
        dispatchChangeEvent("selectionIndicatorChanged");
    }    
    
    //----------------------------------
    //  showCaret
    //----------------------------------
    
    /**
     * @private
     */
    mx_internal function get showCaret():Boolean
    {
        return dateChooser ? dateChooser.showCaret : false;
    }
            
    //----------------------------------
    //  showExtraWeekAtEnd
    //----------------------------------
    
//    private var _showExtraWeekAtEnd:Boolean = false;
//    
//    [Bindable("showExtraWeekAtEndChanged")]
//    [Inspectable(category="General", defaultValue="false")]
    
    /**
     *  If <code>showFixedWeeks</code> is true and
     *  extra weeks(s) are added to the display, the extra weeks are added at
     *  the end of current month.
     *
     *  @default false
     *  
     *  @see #showFixedWeeks
     *  @see #showDaysInOtherMonths
     * 
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5.0
     */
//    public function get showExtraWeekAtEnd():Boolean
//    {
//        return _showExtraWeekAtEnd;    
//    }
//    
//    public function set showExtraWeekAtEnd(value:Boolean):void
//    {
//        if (_showExtraWeekAtEnd == value)
//            return;
//        
//        _showExtraWeekAtEnd = value;
//        
//        invalidateDisplayListFor("grid");
//        
//        dispatchChangeEvent("showExtraWeekAtEndChanged");
//    }    
    
    //----------------------------------
    //  showFixedWeeks
    //----------------------------------
    
//    private var _showFixedWeeks:Boolean = true;
//    
//    [Bindable("showFixedWeeksChanged")]
//    [Inspectable(category="General", defaultValue="true")]
    
    /**
     *  Shows a fixed number of weeks for each month.
     *  If <code>true</code>, the month layout will always show 6 weeks, even if there are only
     *  four or five weeks in the month.  
     *  If <code>false</code>, only weeks for the current month will be showed.
     *
     *  @default true
     *  
     *  @see #showFixedWeeksAtEnd
     *  @see #showDaysInOtherMonths
     * 
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5.0
     */
//    public function get showFixedWeeks():Boolean
//    {
//        return _showFixedWeeks;    
//    }
//    
//    public function set showFixedWeeks(value:Boolean):void
//    {
//        if (_showFixedWeeks == value)
//            return;
//        
//        _showFixedWeeks = value;
//        
//        invalidateDisplayListFor("grid");
//        
//        dispatchChangeEvent("showFixedWeeksChanged");
//    }    
    
    //----------------------------------
    //    showDaysInOtherMonths
    //----------------------------------
    
    private var _showDaysInOtherMonths:Boolean = true;
    
    [Bindable("showDaysInOtherMonthsChanged")]
    [Inspectable(category="General", defaultValue="true")]
    
    /**
     *  Show dates in other months before the first day or after the last day
     *  of the current month if there is space available.
     *
     *  @default true
     *  
     *  @see #showExtraWeekAtEnd
     *  @see #showFixedWeeks
     * 
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5.0
     */
    public function get showDaysInOtherMonths():Boolean
    {
        return _showDaysInOtherMonths;    
    }
    
    public function set showDaysInOtherMonths(value:Boolean):void
    {
        if (_showDaysInOtherMonths == value)
            return;
        
        _showDaysInOtherMonths = value;
        
        invalidateDisplayListFor("grid");
        
        dispatchChangeEvent("showDaysInOtherMonthsChanged");
    }    
    
    //----------------------------------
    //  showTodayIndicator
    //----------------------------------

    [Bindable("showTodayIndicatorChanged")]

    private var _showTodayIndicator:Boolean = true;

    /**
     *  Specifies that today is highlighted with the <code>todayIndicator</code>
     *  in the date selector, when the current month is displayed.
     *
     *  @default true
     *  
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5.0
     */
    public function get showTodayIndicator():Boolean
    {
        return _showTodayIndicator;    
    }
    
    public function set showTodayIndicator(value:Boolean):void
    {
        if (_showTodayIndicator == value)
            return;
        
        _showTodayIndicator = value;
        
        invalidateDisplayListFor("todayIndicator");       
        dispatchChangeEvent("showTodayIndicatorChanged");
    }    

    //----------------------------------
    //  sixWeekLayoutMode
    //----------------------------------
    
    private var _sixWeekLayoutMode:String = SixWeekLayoutMode.EXTRA_WEEK_AFTER;
    private var sixWeekLayoutModeChanged:Boolean;
    
    [Bindable("sixWeekLayoutModeChanged")]
    [Inspectable(category="General", defaultValue="off, extraWeekAfter, extraWeekBefore")]
    
    /**
     *  Determines if the month layout will always show six weeks, even if there are only four
     *  or five weeks in the month.  Extra weeks may be from the month before or the month after.
     * 
     *  <pre>
     *  The the possible values are:
     *     SixWeekLayoutMode.OFF ("off")
     *          Only weeks for the current month will be shown.
     *     SixWeekLayoutMode.EXTRA_WEEK_AFTER ("extraWeekAfter")
     *          If extra week(s) are added so that six weeks are shown,
     *          the extra weeks(s) are added after the weeks in the current current month.
     *          This is the default.
     *     SixWeekLayoutMode.EXTRA_WEEK_BEFORE ("extraWeekBefore")
     *          If extra week(s) are added so that six weeks are shown,
     *          and the first day of the month is at the start of the week, an extra week
     *          will be added before the weeks in the current month.  
     *          Any additional weeks will be added after the weeks in the current month.
     * </pre>
     * 
     *  <p>Changing this property changes the layout of the month.</p>
     *
     *  @default SixWeekLayoutMode.EXTRA_WEEK_AFTER ("extraWeekAfter")
     *  
     *  @see #showDaysInOtherMonths
     * 
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3
     *  @productversion Flex 5.0
     */
    public function get sixWeekLayoutMode():String
    {
        return _sixWeekLayoutMode;
    }
    
    /**
     *  @private
     */
    public function set sixWeekLayoutMode(value:String):void
    {
        if (value == _sixWeekLayoutMode)
            return;
        
        if (value != SixWeekLayoutMode.OFF && value != SixWeekLayoutMode.EXTRA_WEEK_BEFORE && 
            value != SixWeekLayoutMode.EXTRA_WEEK_AFTER)
        {
            return;
        }
        
        _sixWeekLayoutMode = value;
        
        invalidateProperties();
        invalidateSize();
        invalidateDisplayList();
        
        dispatchChangeEvent("sixWeekLayoutModeChanged");
    }
    
    //----------------------------------
    //  todayIndicator
    //----------------------------------
    
    private var _todayIndicator:IFactory = null;
    
    [Bindable("todayIndicatorChanged")]
    
    /**
     *  A visual element that's displayed on top of today's date cell if <code>showTodayIndicator</code> is
     *  <code>true</code>.
     *  
     *  @default null
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 5.0
     */
    public function get todayIndicator():IFactory
    {
        return _todayIndicator;
    }
    
    /**
     *  @private
     */
    public function set todayIndicator(value:IFactory):void
    {
        if (_todayIndicator == value)
            return;
        
        _todayIndicator = value;
        invalidateDisplayListFor("todayIndicator");
        dispatchChangeEvent("todayIndicatorChanged");
    }    
    
    //----------------------------------
    //  typicalDate
    //----------------------------------
    
    private var _typicalDate:Date = null;
    private var typicalDateChanged:Boolean;
    
    [Bindable("typicalDateChanged")]
    
    /**
     *  The month's layout will use the typical date to configure a dayOfTheMonth renderer
     *  and a dayOfTheWeek renderer to determine the measured size of the monthGrid.
     *  By defining the typical date, the layout does not have to measure each day of the
     *  week to determine the largest one.
     * 
     *  <p>This is ignored if <code>requestedCellWidth</code>, <code>requestedCellHeight</code> and 
     * <code>requestedHeaderSize</code> are all specified.</p>
     * 
     *  @default null
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 5.0
     */
    public function get typicalDate():Date
    {  
        return _typicalDate ? new Date(_typicalDate.time) : null;
    }
    
    /**
     *  @private
     */
    public function set typicalDate(value:Date):void
    {
        // Are the dates the same?
        if (DateUtil.datesEqual(value, _typicalDate))
            return;
                
        _typicalDate = value ? new Date(value.time) : null;
        
        invalidateProperties();
        invalidateSize();
        invalidateDisplayList();
        typicalDateChanged = true;        
        
        dispatchChangeEvent("typicalDateChanged");
    } 
        
    //----------------------------------
    //  verticalGap
    //----------------------------------
    
    private var _verticalGap:Number = 2;
    
    [Bindable("verticalGapChanged")]
    [Inspectable(category="General")]
    
    /**
     *  Vertical space between rows, in pixels.
     *
     *  @see #horizontalGap
     *  @see #verticalGap
     * 
     *  @default 2
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 3.0
     *  @productversion Flex 5.0
     */
    public function get verticalGap():Number
    {
        return _verticalGap;
    }
    
    /**
     *  @private
     */
    public function set verticalGap(value:Number):void
    {
        if (value == _verticalGap)
            return;
        
        _verticalGap = isNaN(value) ? 0 : value;
        
        invalidateSize()
        invalidateDisplayListFor("grid");
        
        dispatchChangeEvent("verticalGapChanged");
    }
    
    //----------------------------------
    //  weekOrientation
    //----------------------------------
    
    private var _weekOrientation:String = WeekOrientation.ROWS;
    private var weekOrientationChanged:Boolean;
    
    [Bindable("weekOrientationChanged")]
    
    /**
     *  The weekOrientation of the month layout.  
     *
     *  <pre>
     *  The the possible values are:
     *     WeekOrientation.ROWS ("rows")
     *          The reading order of each week is row by row which is a horizontal orientation.
     *     WeekOrientation.COLUMNS ("columns")
     *          The reading order of each week is column by column which is a vertical orientation.
     * </pre>
     * 
     *  @default WeekOrientation.ROWS ("rows")
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 3.0
     *  @productversion Flex 5.0
     * 
     *  @internal From the globalization group:
     *  @internal There is not a data source that tells which locales prefer to use vertical layout. 
     *  @internal Most likely any locales are ok with the horizontal layout by default. 
     *  @internal At the same time, people who use some locales such as those in India,
     *  @internal often use horizontal layout. The conclusion is that the default for all locales 
     *  @internal can be horizontal layout but it is good to provide a switch for the users.
     */
    public function get weekOrientation():String
    {
        return _weekOrientation; 
    }
    
    /**
     *  @private
     */
    public function set weekOrientation(value:String):void
    {
        if (_weekOrientation == value) 
            return;
        
        _weekOrientation = value; 
        invalidateProperties();
        invalidateSize();
        invalidateDisplayList();
        weekOrientationChanged = true;        
        
        dispatchChangeEvent("weekOrientationChanged");
    } 
    
    //--------------------------------------------------------------------------
    //
    //  Overridden Properties
    //
    //--------------------------------------------------------------------------
        
    //----------------------------------
    //  layout
    //----------------------------------    
    
    /**
     *  @private
     */
    override public function set layout(value:LayoutBase):void
    {
        throw(new Error(resourceManager.getString("components", "layoutReadOnly")));
    }


    //--------------------------------------------------------------------------
    //
    //  Overridden Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    override protected function commitProperties():void
    {
        super.commitProperties();
                        
        if (weekOrientationChanged || sixWeekLayoutModeChanged || typicalDateChanged)
        {
            if (layout)
                layout.clearVirtualLayoutCache();
            weekOrientationChanged = false;
            sixWeekLayoutModeChanged = false;
            typicalDateChanged = false;
        }
        
        if (dayOfTheWeekFormatterChanged || dayOfTheMonthFormatterChanged)
        {
            if (layout)
                layout.clearVirtualLayoutCache();
            dayOfTheWeekFormatterChanged = false;
            dayOfTheMonthFormatterChanged = false;
        }

        if (dayOfTheWeekRendererChanged || dayOfTheMonthRendererChanged)
        {
            if (layout)
                layout.clearVirtualLayoutCache();
            dayOfTheWeekRendererChanged = false;
            dayOfTheMonthRendererChanged = false;
        }
        
    }
    
    /**
     *  @private
     *  During virtual layout updateDisplayList() eagerly validates lazily
     *  created (or recycled) IRs.   We don't want changes to those IRs to
     *  invalidate the size of the grid.
     */
    override public function invalidateSize():void
    {
        if (!inUpdateDisplayList)
        {
            super.invalidateSize();
        }
    }

    /**
     *  @private
     *  During virtual layout updateDisplayList() eagerly validates lazily
     *  created (or recycled) IRs.  Calls to invalidateDisplayList() eventually
     *  short-circuit but doing so early saves a few percent.
     */
    override public function invalidateDisplayList():void
    {
        if (!inUpdateDisplayList)
        {
            setInvalidateDisplayListReason("none");            
            super.invalidateDisplayList();
        }
    }

    /**
     *  @private
     */
    override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    {
        if (inUpdateDisplayList)
            return;
        
        inUpdateDisplayList = true;
        super.updateDisplayList(unscaledWidth, unscaledHeight);
        inUpdateDisplayList = false;
        
        clearInvalidateDisplayListReasons();
    }
    
//    override public function setActualSize(w:Number, h:Number):void
//    {
//        trace("MonthGrid setActualSize: width = " + w + " height = " + h);
//        super.setActualSize(w, h);
//    }
    
    //--------------------------------------------------------------------------
    //
    //  Tracking MonthGrid invalidateDisplayList() "reasons", invalid cells
    //
    //-------------------------------------------------------------------------- 
    /**
     *  @private
     *  Low cost "list" of invalidateDisplayList() reasons.
     */
    private var invalidateDisplayListReasonsMask:uint = 0;
    
    /**
     *  @private
     *  Table that maps from reason names to bit fields.
     */
    private static const invalidateDisplayListReasonBits:Object = {
        grid: uint(1 << 0),
        hoverIndicator: uint(1 << 1),
        selectionIndicator: uint(1 << 2),
        todayIndicator: uint(1 << 3),
        downState: uint(1 << 4),
        none: uint(~0)
    };
    
    /**
     *  @private
     *  Set the bit that corresponds to reason.  Only used by invalidateDisplayListFor().
     */
    private function setInvalidateDisplayListReason(reason:String):void
    {
        invalidateDisplayListReasonsMask |= invalidateDisplayListReasonBits[reason];
    }
    
    //--------------------------------------------------------------------------
    //
    //  mx_internal Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Return true if invalidateDisplayListFor() was called with the specified reason
     *  since the last updateDisplayList() pass.
     */
    mx_internal function isInvalidateDisplayListReason(reason:String):Boolean
    {
        const bit:uint = invalidateDisplayListReasonBits[reason];
        return (invalidateDisplayListReasonsMask & bit) == bit;
    }
    
    /**
     *  @private
     */
    mx_internal function clearInvalidateDisplayListReasons():void
    {
        invalidateDisplayListReasonsMask = 0;
    }
       
    /**
     *  @private
     *  This version of invlaidateDisplayList() stores the "reason" for the invalidate
     *  request so that MonthGridLayout/updateDisplayList() can do its job more efficiently.
     *  MonthGridLayout tests the accumulated invalidateDisplayList reasons with 
     *  isInvalidateDisplayListReason() and they're automatically cleared by 
     *  updateDisplayList() here.
     * 
     *  Note that if invalidateDisplayList() is called directly, all possible 
     *  invalidateDispayList reasons are implicitly specified, in other words if
     *  no reason is specified then they all are (see invalidateDisplayListReasonBits.none).
     *  That way, callers need not be aware of this internal API.
     */
    mx_internal function invalidateDisplayListFor(reason:String):void
    {
        if (!inUpdateDisplayList)
        {
            setInvalidateDisplayListReason(reason);            
            super.invalidateDisplayList();
            dispatchChangeEvent("invalidateDisplayList");
        }
    }
    
    /**
     *  @private per PARB
     * 
     *  Formats the <code>date</code> using the <code>dayOfTheMonthFormatter</code>.
     *
     *  @param date A date to format.
     * 
     *  @return String The numerical day of the month.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 3.0
     *  @productversion Flex 5.0
     */
    mx_internal function dateToDayOfTheMonthString(date:Date):String
    {
        const dtf:DateTimeFormatter = dayOfTheMonthFormatter;
        return dtf ? dtf.format(date) : String(date.getDate());
    }
    
    /**
     *  @private per PARB
     * 
     *  Formats the <code>date</code> using the <code>dayOfTheWeekFormatter</code>.
     *
     *  @param date A date to format.
     * 
     *  @return String The name of the day of the week.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 3.0
     *  @productversion Flex 5.0
     */
    mx_internal function dateToDayOfTheWeekString(date:Date):String
    {
        if (dayNamesOverride && dayNamesOverride.length == 7)
            return dayNamesOverride[date.day];
        
        const dtf:DateTimeFormatter = dayOfTheWeekFormatter;
        return dtf ? dtf.format(date) : String(date.getDate());
    }    
    
    //--------------------------------------------------------------------------
    //
    //  MonthGridLayout Cover Methods, Properties
    //
    //-------------------------------------------------------------------------- 
    
    /**
     *  If the requested item renderer is visible, returns a reference to 
     *  the item renderer currently displayed at the specified cell location.  
     *  Note that once the returned item renderer is no longer visible it may be 
     *  recycled and its properties reset.  
     * 
     *  <p>If the requested item renderer is not visible. then 
     *  each time this method is called, a new item renderer is created.  
     *  The new item renderer is not visible.</p>
     *  
     *  @param rowIndex The 0-based row index of the item renderer's cell.
     * 
     *  @param columnIndex The 0-based column index of the item renderer's cell.
     * 
     *  @return The item renderer or null if the cell location is invalid.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 3.0
     *  @productversion Flex 5.0
     */
    public function getDateItemRendererAt(rowIndex:int, columnIndex:int):IDateItemRenderer
    {
        return MonthGridLayout(layout).getDateItemRenderer(rowIndex, columnIndex);
    }
    
    /**
     *  If the requested item renderer is visible, returns a reference to 
     *  the item renderer currently displayed at the point, specified in the local
     *  coordinates.  
     *  Note that once the returned item renderer is no longer visible it may be 
     *  recycled and its properties reset.  
     * 
     *  <p>If the requested item renderer is not visible. then 
     *  each time this method is called, a new item renderer is created.  
     *  The new item renderer is not visible.</p>
     *  
     *  @param point A point in the monthGrid
     * .
     *  @return The item renderer or null if the cell location is invalid.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 3.0
     *  @productversion Flex 5.0
     */
    public function getDateItemRendererAtPoint(point:Point):IDateItemRenderer
    {
        return MonthGridLayout(layout).getDateItemRendererAtPoint(point);
    }
            
    //--------------------------------------------------------------------------
    //
    //  Private Methods
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

    /**
     *  @private
     */
    private function dispatchFlexEvent(type:String):void
    {
        if (hasEventListener(type))
            dispatchEvent(new FlexEvent(type));
    }
       
    //--------------------------------------------------------------------------
    //
    //  Mouse Event handlers
    //
    //--------------------------------------------------------------------------
    
    
    //--------------------------------------------------------------------------
    //
    //  GridEvents
    //
    //--------------------------------------------------------------------------  
    
    /**
     *  @private
     *  True while doing a drag operation with the mouse.
     */
    private var dragInProgress:Boolean = false;
    
    mx_internal var mouseDownRowIndex:int = -1;
    mx_internal var mouseDownColumnIndex:int = -1;
    
    private var rollRowIndex:int = -1;
    private var rollColumnIndex:int = -1;
    private var lastClickTime:Number;
    
    // default max time between clicks for a double click is 480ms.
    mx_internal var DOUBLE_CLICK_TIME:Number = 480;
    
    /**
     *  @private
     *  This method is called when a MOUSE_DOWN event occurs within the grid and 
     *  for all subsequent MOUSE_MOVE events until the button is released (even if the 
     *  mouse leaves the grid).  The last event in such a "down drag up" gesture is 
     *  always a MOUSE_UP.  By default this method dispatches MONTH_GRID_MOUSE_DOWN, 
     *  MONTH_GRID_MOUSE_DRAG, or a MONTH_GRID_MOUSE_UP event in response to the the corresponding
     *  mouse event.  The MonthGridEvent's rowIndex, columnIndex, column, item, and itemRenderer 
     *  properties correspond to the grid cell under the mouse.  
     * 
     *  @param event A MOUSE_DOWN, MOUSE_MOVE, or MOUSE_UP MouseEvent from a down/move/up gesture initiated within the grid.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */    
    protected function monthGrid_mouseDownDragUpHandler(event:MouseEvent):void
    {
        const eventStageXY:Point = new Point(event.stageX, event.stageY);
        const eventGridXY:Point = globalToLocal(eventStageXY);
        
        const renderer:IDateItemRenderer = getDateItemRendererAtPoint(eventGridXY);
        
        const eventRowIndex:int = renderer ? renderer.rowIndex : -1;
        const eventColumnIndex:int = renderer ? renderer.columnIndex : -1;

        var gridEventType:String;
        switch(event.type)
        {
            case MouseEvent.MOUSE_MOVE: 
            {
                gridEventType = MonthGridEvent.MONTH_GRID_MOUSE_DRAG; 
                break;
            }
            case MouseEvent.MOUSE_UP: 
            {
                gridEventType = MonthGridEvent.MONTH_GRID_MOUSE_UP;
                mouseDownRowIndex = -1;
                mouseDownColumnIndex = -1;
                if (renderer)
                    invalidateDisplayListFor("downState");
                break;
            }
            case MouseEvent.MOUSE_DOWN:
            {
                gridEventType = MonthGridEvent.MONTH_GRID_MOUSE_DOWN;
                mouseDownRowIndex = eventRowIndex;
                mouseDownColumnIndex = eventColumnIndex;
                dragInProgress = true;
                if (renderer)
                    invalidateDisplayListFor("downState");
                break;
            }
        }
        
        dispatchGridEvent(event, gridEventType, eventGridXY, eventRowIndex, eventColumnIndex);
        if (gridEventType == MonthGridEvent.MONTH_GRID_MOUSE_UP)
            dispatchGridClickEvents(event, eventGridXY, eventRowIndex, eventColumnIndex);
    }
    
    /**
     *  @private
     *  This method is called whenever a MOUSE_MOVE event occurs within the grid
     *  without the button pressed.  By default it dispatches a MONTH_GRID_ROLL_OVER for the
     *  first MOUSE_MOVE MonthGridEvent whose location is within a grid cell, and a 
     *  MONTH_GRID_ROLL_OUT MonthGridEvent when the mouse leaves a cell.  Listeners are guaranteed
     *  to receive a MONTH_GRID_ROLL_OUT event for every MONTH_GRID_ROLL_OVER event.
     * 
     *  @param event A MOUSE_MOVE MouseEvent within the grid, without the button pressed.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */    
    protected function monthGrid_mouseMoveHandler(event:MouseEvent):void
    {
        const eventStageXY:Point = new Point(event.stageX, event.stageY);
        const eventGridXY:Point = globalToLocal(eventStageXY);
        const renderer:IDateItemRenderer = getDateItemRendererAtPoint(eventGridXY);
        
        const eventRowIndex:int = renderer ? renderer.rowIndex : -1;
        const eventColumnIndex:int = renderer ? renderer.columnIndex : -1;
        
        if ((eventRowIndex != rollRowIndex) || (eventColumnIndex != rollColumnIndex))
        {
            if ((rollRowIndex != -1) || (rollColumnIndex != -1))
                dispatchGridEvent(event, MonthGridEvent.MONTH_GRID_ROLL_OUT, eventGridXY, rollRowIndex, rollColumnIndex);
            if ((eventRowIndex != -1) && (eventColumnIndex != -1))
                dispatchGridEvent(event, MonthGridEvent.MONTH_GRID_ROLL_OVER, eventGridXY, eventRowIndex, eventColumnIndex);
            rollRowIndex = eventRowIndex;
            rollColumnIndex = eventColumnIndex;
        }
    }
    
    /**
     *  @private
     *  This method is called whenever a ROLL_OUT occurs on the grid.
     *  By default it dispatches a MONTH_GRID_ROLL_OUT event.
     * 
     *  @param event A ROLL_OUT MouseEvent from the grid.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */       
    protected function monthGrid_mouseRollOutHandler(event:MouseEvent):void
    {
        if ((rollRowIndex != -1) || (rollColumnIndex != -1))
        {
            const eventStageXY:Point = new Point(event.stageX, event.stageY);
            const eventGridXY:Point = globalToLocal(eventStageXY);            
            dispatchGridEvent(event, MonthGridEvent.MONTH_GRID_ROLL_OUT, eventGridXY, rollRowIndex, rollColumnIndex);
            rollRowIndex = -1;
            rollColumnIndex = -1;
        }
    }
    
    /**
     *  @private
     *  This method is called whenever a MONTH_GRID_MOUSE_UP occurs on the grid.
     *  By default it dispatches a MONTH_GRID_MOUSE_UP event.
     * 
     *  @param event A MONTH_GRID_MOUSE_UP MouseEvent from the grid.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */       
    protected function monthGrid_mouseUpHandler(event:MouseEvent):void 
    {
        // If in a drag, the drag handler already dispatched a mouse up
        // event so don't do it again here.
        if (dragInProgress)
        {
            dragInProgress = false;
            return;
        }
        
        const eventStageXY:Point = new Point(event.stageX, event.stageY);
        const eventGridXY:Point = globalToLocal(eventStageXY);
        const renderer:IDateItemRenderer = getDateItemRendererAtPoint(eventGridXY);
        
        const eventRowIndex:int = renderer ? renderer.rowIndex : -1;
        const eventColumnIndex:int = renderer ? renderer.columnIndex : -1;
        
        dispatchGridEvent(event, MonthGridEvent.MONTH_GRID_MOUSE_UP, eventGridXY, eventRowIndex, eventColumnIndex);
        dispatchGridClickEvents(event, eventGridXY, eventRowIndex, eventColumnIndex);
    }
    
    /**
     *  @private
     *  This method is called after we dispatch a MONTH_GRID_MOUSE_UP.
     *  It determines whether to dispatch a MONTH_GRID_CLICK or MONTH_GRID_DOUBLE_CLICK
     *  event following a MONTH_GRID_MOUSE_UP.
     * 
     *  A MONTH_GRID_CLICK event is dispatched when the mouse up event happens in
     *  the same cell as the mouse down event.
     * 
     *  A MONTH_GRID_DOUBLE_CLICK event is dispatched in place of the MONTH_GRID_CLICK
     *  event when the last click event happened within DOUBLE_CLICK_TIME.
     */       
    private function dispatchGridClickEvents(mouseEvent:MouseEvent, gridXY:Point, rowIndex:int, columnIndex:int):void
    {
        var dispatchGridClick:Boolean = (rowIndex == mouseDownRowIndex &&
            columnIndex == mouseDownColumnIndex);
        var newClickTime:Number = getTimer();
        
        // In the case that we dispatched a click last time, check if we
        // should dispatch a double click this time.
        // This isn't stricly adequate, since the mouse might have been on a different cell for 
        // the first click.  It's not clear that the extra checking would be worthwhile.
        if (doubleClickEnabled && dispatchGridClick && !isNaN(lastClickTime) &&
            (newClickTime - lastClickTime <= DOUBLE_CLICK_TIME))
        {
            dispatchGridEvent(mouseEvent, MonthGridEvent.MONTH_GRID_DOUBLE_CLICK, gridXY, rowIndex, columnIndex);
            lastClickTime = NaN;
            return;
        }
        
        // Otherwise, just dispatch the click event.
        if (dispatchGridClick)
        {
            dispatchGridEvent(mouseEvent, MonthGridEvent.MONTH_GRID_CLICK, gridXY, rowIndex, columnIndex);
            lastClickTime = newClickTime;
        }
    }
    
    /**
     *  @private
     */
    private function dispatchGridEvent(mouseEvent:MouseEvent, type:String, gridXY:Point, 
                                       rowIndex:int, columnIndex:int):void
    {
        const dateRenderer:IDateItemRenderer = getDateItemRendererAt(rowIndex, columnIndex);
        const bubbles:Boolean = mouseEvent.bubbles;
        const cancelable:Boolean = mouseEvent.cancelable;
        const relatedObject:InteractiveObject = mouseEvent.relatedObject;
        const ctrlKey:Boolean = mouseEvent.ctrlKey;
        const altKey:Boolean = mouseEvent.altKey;
        const shiftKey:Boolean = mouseEvent.shiftKey;
        const buttonDown:Boolean = mouseEvent.buttonDown;
        const delta:int = mouseEvent.delta;        
        
        const event:MonthGridEvent = new MonthGridEvent(
            type, bubbles, cancelable, 
            gridXY.x, gridXY.y, 
            relatedObject, ctrlKey, altKey, shiftKey, buttonDown, delta,
            rowIndex, columnIndex, dateRenderer);
        dispatchEvent(event);
    }
}    
}