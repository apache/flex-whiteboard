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
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.utils.Dictionary;

import mx.core.IDataRenderer;
import mx.core.IFactory;
import mx.core.IInvalidating;
import mx.core.IUIComponent;
import mx.core.IVisualElement;
import mx.core.IVisualElementContainer;
import mx.core.mx_internal;
import mx.managers.ILayoutManagerClient;
import mx.managers.LayoutManager;

import spark.components.Group;
import spark.components.MonthGrid;
import spark.components.calendarClasses.IMonthGridVisualElement;
import spark.components.supportClasses.GroupBase;
import spark.core.IGraphicElement;
import spark.formatters.DateTimeFormatter;
import spark.globalization.supportClasses.CalendarDate;
import spark.layouts.supportClasses.LayoutBase;

use namespace mx_internal;

[ExcludeClass]

/**
 *  FIXME: do we need GridLayers?
 *  FIXME: not sure cellPadding* calculatations are correct
 * 
 *  backgroundLayer - rowBackground if one is added and hoverIndicator
 *  selectionLayer - selectionIndicator at bottom and todayIndicator at top 
 *  rendererLayer - IR
 *  overlayLayer - column and row separators
 */
public class MonthGridLayout extends LayoutBase
{
    //--------------------------------------------------------------------------
    //
    //  Class variables
    //
    //--------------------------------------------------------------------------
    
    
    //--------------------------------------------------------------------------
    //
    //  Class methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  Return the number of days in the month of the specified date.
     */
    private static function getDaysInMonth(fullYear:int, month:int):int
    {
        // FIXME: replace with GAT method - CalendarDate.numDaysInMonth
        return new Date(fullYear, month + 1, 0).date;              
    }
    
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    public function MonthGridLayout()
    {
        super();

    }
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  Layers for header renderers and separators.
     */
    private var backgroundLayer:Group;
    private var selectionLayer:Group;
    private var rendererLayer:Group;
    private var overlayLayer:Group;
    
    private const dayRendererCache:Vector.<IDateItemRenderer> = new Vector.<IDateItemRenderer>(6 * 7);
    private const weekRendererCache:Vector.<IDateItemRenderer> = new Vector.<IDateItemRenderer>(7);    
    
    /**
     *  Globals updated by updateOrientationVars() at the start of measure and updateDisplayList.
     */
    private var horizontalLayout:Boolean;
    
    /**
     * The maximum number of rows and columns for the given weekOrientation.
     */
    private var maxRowCount:int;
    private var maxColumnCount:int;

    /**
     * Actual number of rows and columns for the given weekOrientation and sixWeekLayout mode.
     * If sixWeekLayoutMode="off" one of these will differ from its max value above.
     * Initialized at the begining of updateDisplayList. 
     */
    private var rowCount:int;
    private var columnCount:int;
    
    private var rowSeparators:Vector.<IVisualElement> = new Vector.<IVisualElement>(0);
    private var columnSeparators:Vector.<IVisualElement> = new Vector.<IVisualElement>(0);
    
    private var caretIndicator:IVisualElement = null;
    private var hoverIndicator:IVisualElement = null;
    private var todayIndicator:IVisualElement = null;

    private var todayRenderer:IDateItemRenderer;
                
    /**
     *  @private
     *  The elements available for reuse.  Maps from an IFactory to a list of the elements 
     *  that have been allocated by that factory and then freed.   The list is represented 
     *  by a Vector.<IVisualElement>.
     * 
     *  Updated by allocateGridElement().
     */
    private const freeElementMap:Dictionary = new Dictionary();
    
    /**
     *  @private
     *  Records the IFactory used to allocate a Element so that free(Element) can find it again.
     * 
     *  Updated by createGridElement().
     */
    private const elementToFactoryMap:Dictionary = new Dictionary();
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  layout
    //----------------------------------    
        
    /**
     *  @private
     */
    override public function set target(value:GroupBase):void
    {
        super.target = value;
        
        const monthGrid:MonthGrid = value as MonthGrid;
        
        if (monthGrid)
        {
            // Create layers
            backgroundLayer = new Group();
            backgroundLayer.layout = new LayoutBase();
            monthGrid.addElement(backgroundLayer);
            
            selectionLayer = new Group();
            selectionLayer.layout = new LayoutBase();
            monthGrid.addElement(selectionLayer);
            
            rendererLayer = new Group();
            rendererLayer.layout = new LayoutBase();
            monthGrid.addElement(rendererLayer);
            
            overlayLayer = new Group();
            overlayLayer.layout = new LayoutBase();
            monthGrid.addElement(overlayLayer);
        }
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden Methods: UIComponent
    //
    //--------------------------------------------------------------------------
    
    override public function measure():void
    {
        const monthGrid:MonthGrid = target as MonthGrid;
        if (!monthGrid)
            return;
             
        // Update maxRow/ColumnCount based on the weekOrientation.
        updateOrientationVars(monthGrid);
        
        const headerGap:Number = monthGrid.headerGap;
            
        const requestedCellWidth:Number = monthGrid.requestedCellWidth;
        const requestedCellHeight:Number = monthGrid.requestedCellHeight;
        const requestedHeaderSize:Number = monthGrid.requestedHeaderSize;
        
        // If set, these include the cell padding.
        var computedCellWidth:Number = Math.max(0, requestedCellWidth);
        var computedCellHeight:Number = Math.max(0, requestedCellHeight);
        var computedHeaderSize:Number = Math.max(0, requestedHeaderSize);
        
        var measuredHeaderWidth:Number = 0;
        var measuredHeaderHeight:Number = 0;
        
        const dateToMeasure:Date = monthGrid.typicalDate ? monthGrid.typicalDate : new Date();
                        
        // Measure the names of the days of the week using the given format.
        if (isNaN(requestedHeaderSize) || isNaN(requestedCellWidth) || isNaN(requestedCellHeight))
        {
            layoutDaysOfWeek(monthGrid, monthGrid.typicalDate);
            for (var index:int = 0; index < 7; index++)
            {
                var renderer:IDateItemRenderer = getDayOfTheWeekRenderer(index);
                if (renderer)
                {
                    if (renderer is IInvalidating)
                        IInvalidating(renderer).validateNow();
                    
                    measuredHeaderWidth = Math.max(measuredHeaderWidth, getPaddedWidth(renderer));
                    measuredHeaderHeight = Math.max(measuredHeaderHeight, getPaddedHeight(renderer));                
                }
            }
    
            if (isNaN(requestedHeaderSize))
                computedHeaderSize = horizontalLayout ? measuredHeaderHeight : measuredHeaderWidth;
            
            // Measure the typical day of the month.
            if (isNaN(requestedCellWidth) || isNaN(requestedCellHeight))
            {
                renderer = getDayOfTheMonthRenderer(0, 0);
                if (renderer)
                {
                    intializeDayOfTheMonthRenderer(renderer, 0, 0, dateToMeasure);
                    
                    renderer.setLayoutBoundsSize(NaN, NaN);
                    
                    if (renderer is IInvalidating)
                        IInvalidating(renderer).validateNow();
                    
                    if (isNaN(requestedCellWidth))
                    {
                        computedCellWidth = horizontalLayout ?
                            Math.max(getPaddedWidth(renderer), measuredHeaderWidth) :
                            getPaddedWidth(renderer);
                    }
                    if (isNaN(requestedCellHeight))
                    {
                        computedCellHeight = horizontalLayout ?
                            getPaddedHeight(renderer) :
                            Math.max(getPaddedHeight(renderer), measuredHeaderHeight);
                    }
                }
            }
        }
                
        // Save the computed values.
        monthGrid.setCellWidth(computedCellWidth);
        monthGrid.setCellHeight(computedCellHeight);
        monthGrid.setHeaderSize(computedHeaderSize);
        
        // Rows and columns including cell padding, gaps and padding.
        monthGrid.measuredWidth = Math.ceil(
            computedCellWidth * maxColumnCount +
            (monthGrid.horizontalGap * (maxColumnCount - 1)) + 
            monthGrid.paddingLeft + monthGrid.paddingRight +
            (horizontalLayout ? 0 : computedHeaderSize + headerGap));
        
        monthGrid.measuredHeight = Math.ceil(
            (computedCellHeight * maxRowCount) +
            (monthGrid.verticalGap * (maxRowCount - 1)) +
            monthGrid.paddingTop + monthGrid.paddingBottom + 
            (horizontalLayout ? computedHeaderSize + headerGap : 0));
                 
        trace("monthGrid measure", monthGrid.measuredWidth, monthGrid.measuredHeight);
        
        monthGrid.measuredMinWidth = monthGrid.measuredWidth;
        monthGrid.measuredMinHeight = monthGrid.measuredHeight;
    }
    
    /**
     *  @private
     *  To adjust the size of the MonthGrid the monthGrid properties should be set.  Setting an
     *  explicit width or height on the DateChooser will not change the layout of the MonthGrid.
     */
    override public function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    {
        trace("MonthGrid udl", unscaledWidth, unscaledHeight);
        
        const monthGrid:MonthGrid = target as MonthGrid;
        if (!monthGrid)
            return;        
                
        const fullYear:Number = monthGrid.displayedYear;
        const month:Number = monthGrid.displayedMonth;
        const daysInMonth:int = MonthGridLayout.getDaysInMonth(fullYear, month);
        const todayDate:Date = new Date();
        const lastDayInMonth:Date = new Date(fullYear, month, daysInMonth);        
        const weekFormatter:DateTimeFormatter = monthGrid.dayOfTheWeekFormatter;
        const sixWeekLayoutMode:String = monthGrid.sixWeekLayoutMode;
        
        const cellWidth:Number = monthGrid.cellWidth;
        const cellHeight:Number = monthGrid.cellHeight;                
        const rendererWidth:Number = getRendererWidth(cellWidth);
        const rendererHeight:Number = getRendererHeight(cellHeight);
        
        // Update maxRow/ColumnCount based on the weekOrientation.
        updateOrientationVars(monthGrid);
        
        // If there can be a variable number of weeks, then figure out how many there are in
        // this month and adjust rowCount/columnCount accordingly.
        if (sixWeekLayoutMode == SixWeekLayoutMode.OFF)
        {
            if (horizontalLayout)
                rowCount = getDateRowIndex(lastDayInMonth) + 1;    
            else
                columnCount = getDateColumnIndex(lastDayInMonth) + 1; 
        }

        const day1:Date = new Date(fullYear, month, 1);
        var rowIndex:int = getDateRowIndex(day1, weekFormatter);
        var columnIndex:int = getDateColumnIndex(day1, weekFormatter);
        
        const startX:Number = monthGrid.paddingLeft + monthGrid.cellPaddingLeft +
            ((horizontalLayout) ? 0 : monthGrid.headerSize + monthGrid.headerGap);
        const startY:Number = monthGrid.paddingTop + monthGrid.cellPaddingTop +
            ((horizontalLayout) ? monthGrid.headerSize + monthGrid.headerGap : 0);
        
        var completeLayoutNeeded:Boolean = monthGrid.isInvalidateDisplayListReason("grid");
        
        // If the current date changed, do a complete layout.
        if (!completeLayoutNeeded && todayRenderer && !DateUtil.datesEqual(todayDate, todayRenderer.date))
            completeLayoutNeeded = true;
        
        if (completeLayoutNeeded)
        {
            layoutDaysOfWeek(monthGrid);
                
            var x:Number = startX;
            var y:Number = startY;
            
            var renderer:IDateItemRenderer;
            var rendererDate:Date;
            var dayFromPreviousMonth:int;
            
            // Days before this month.
            if (horizontalLayout)
            {
                if (columnIndex == 0 && sixWeekLayoutMode == SixWeekLayoutMode.EXTRA_WEEK_BEFORE)
                    columnIndex = maxColumnCount;
                
                for (var leadingColumnIndex:int = 0; leadingColumnIndex < columnIndex; leadingColumnIndex++)
                {
                    renderer = getDayOfTheMonthRenderer(rowIndex, leadingColumnIndex);                
                    if (renderer)
                    {
                        if (!monthGrid.showDaysInOtherMonths)
                        {
                            renderer.visible = false;
                        }
                        else
                        {
                            dayFromPreviousMonth = leadingColumnIndex - columnIndex + 1;
                            rendererDate = new Date(fullYear, month, dayFromPreviousMonth);
                            intializeDayOfTheMonthRenderer(renderer, rowIndex, leadingColumnIndex, rendererDate, false, true);
                            
                            renderer.setLayoutBoundsSize(rendererWidth, rendererHeight);                     
                            renderer.setLayoutBoundsPosition(x, y);
                            renderer.visible = true;
                        }
                    }               
                    x += cellWidth + monthGrid.horizontalGap; 
                }
                
                // Inserted a week before.  Increment the rowIndex.
                if (columnIndex == maxColumnCount)
                {
                    columnIndex = 0;
                    rowIndex++;
                    x = startX;
                    y += cellHeight + monthGrid.verticalGap;
                }
            }
            else
            {    
                if (rowIndex == 0 && sixWeekLayoutMode == SixWeekLayoutMode.EXTRA_WEEK_BEFORE)
                    rowIndex = maxRowCount;
                
                for (var leadingRowIndex:int = 0; leadingRowIndex < rowIndex; leadingRowIndex++)
                {
                    renderer = getDayOfTheMonthRenderer(leadingRowIndex, columnIndex);                
                    if (renderer)
                    {
                        if (!monthGrid.showDaysInOtherMonths)
                        {
                            renderer.visible = false;
                        }
                        else
                        {
                            dayFromPreviousMonth = leadingRowIndex - rowIndex + 1;
                            rendererDate = new Date(fullYear, month, dayFromPreviousMonth);
                            intializeDayOfTheMonthRenderer(renderer, leadingRowIndex, columnIndex, rendererDate, false, true);
                            
                            renderer.setLayoutBoundsSize(rendererWidth, rendererHeight);                     
                            renderer.setLayoutBoundsPosition(x, y);
                            renderer.visible = true;
                        }
                    }
                    y += cellHeight + monthGrid.verticalGap;
                } 
                
                // Inserted a week before.  Increment the columnIndex.
                if (rowIndex == maxRowCount)
                {
                    rowIndex = 0;
                    columnIndex++;
                    x += cellWidth + monthGrid.horizontalGap;
                    y = startY;
                }    
            }
            
            // Days of the month.
            for (var day:int = 1; day <= daysInMonth; day++)
            {
                renderer = getDayOfTheMonthRenderer(rowIndex, columnIndex);
                if (renderer)
                {
                    rendererDate = new Date(fullYear, month, day);                    
                    const today:Boolean = DateUtil.datesEqual(todayDate, rendererDate);
                    
                    intializeDayOfTheMonthRenderer(renderer, rowIndex, columnIndex, rendererDate, today);
                                    
                    renderer.setLayoutBoundsSize(rendererWidth, rendererHeight); 
                    
                    renderer.setLayoutBoundsPosition(x, y);
                    renderer.visible = true;
                }            
                
                if (horizontalLayout)
                {
                    if ((++columnIndex % maxColumnCount) == 0)
                    {
                        rowIndex += 1;
                        columnIndex = 0;
                        x = startX;
                        y += cellHeight + monthGrid.verticalGap;
                    }
                    else
                    {
                        x += cellWidth + monthGrid.horizontalGap;
                    }
                }
                else
                {
                    if ((++rowIndex % maxRowCount) == 0)
                    {
                        rowIndex = 0;
                        columnIndex += 1;
                        y = startY;
                        x += cellWidth + monthGrid.horizontalGap;
                    }
                    else
                    {
                        y += cellHeight + monthGrid.verticalGap;
                    }                
                }
            }
            
            // Days after this month.
            day = 1;
            month++;
            if (horizontalLayout)
            {
                 for (; rowIndex < maxRowCount; rowIndex++)
                {
                    for (var trailingColumnIndex:int = columnIndex; trailingColumnIndex < columnCount; trailingColumnIndex++)
                    {
                        renderer = getDayOfTheMonthRenderer(rowIndex, trailingColumnIndex);
    
                        if (renderer)
                        {
                            if (!monthGrid.showDaysInOtherMonths || sixWeekLayoutMode == SixWeekLayoutMode.OFF)
                            {
                                renderer.visible = false; 
                            }
                            else
                            {
                                rendererDate = new Date(fullYear, month, day);
                                
                                intializeDayOfTheMonthRenderer(renderer, rowIndex, trailingColumnIndex, rendererDate, false, false, true);
                                
                                renderer.setLayoutBoundsSize(rendererWidth, rendererHeight); 
                                
                                renderer.setLayoutBoundsPosition(x, y);
                                renderer.visible = true;
                            }
                        }    
                        
                        x += cellWidth + monthGrid.horizontalGap;
                        day++;
                    }
                    columnIndex = 0;
                    x = startX;
                    y += cellHeight + monthGrid.verticalGap;
                }
            }
            else
            {
                // columnCount may be adjusted if sixWeekLayoutMode is off so use "6".  In this 
                // case, need to go thru and make sure renderers after the month are invisible.
                for (; columnIndex < maxColumnCount; columnIndex++)
                {
                    for (var trailingRowIndex:int = rowIndex; trailingRowIndex < rowCount; trailingRowIndex++)
                    {
                        renderer = getDayOfTheMonthRenderer(trailingRowIndex, columnIndex);
                        if (renderer)
                        {
                            if (!monthGrid.showDaysInOtherMonths || sixWeekLayoutMode == SixWeekLayoutMode.OFF)
                            {
                                renderer.visible = false;
                            }
                            else
                            {
                                rendererDate = new Date(fullYear, month, day);
                                
                                intializeDayOfTheMonthRenderer(renderer, trailingRowIndex, columnIndex, rendererDate, false, false, true);
                                
                                renderer.setLayoutBoundsSize(rendererWidth, rendererHeight); 
                                
                                renderer.setLayoutBoundsPosition(x, y);
                                renderer.visible = true;
                            }
                        }    
                        
                        y += cellHeight + monthGrid.verticalGap;
                        day++;
                    }
                    rowIndex = 0;
                    x += cellWidth + monthGrid.horizontalGap;
                    y = startY;
                }            
            }
            
            // For horizontalLayout, seperator after the header and every row but the last one.
            // For verticalLayout, seperator after every row but the last one.
            rowSeparators = layoutSeperators(
                monthGrid.rowSeparator, overlayLayer, 
                rowSeparators, layoutRowSeparator, 
                horizontalLayout ? rowCount : rowCount-1);
            
            // For horizontalLayout, seperator after every column but the last one.
            // For verticalLayout, seperator after the header and every column but the last one.
            columnSeparators = layoutSeperators(
                monthGrid.columnSeparator, overlayLayer, 
                columnSeparators, layoutColumnSeparator, 
                horizontalLayout ? columnCount-1 : columnCount);                        
        }

        // Layout the hoverIndicator, selectionIndicators, todayIndicator and caretIndicator.       
                
        if (completeLayoutNeeded || monthGrid.isInvalidateDisplayListReason("hoverIndicator"))
            layoutHoverIndicator(backgroundLayer);
        
        if (completeLayoutNeeded || monthGrid.isInvalidateDisplayListReason("selectionIndicator"))
            layoutSelectionIndicators(selectionLayer);
        
        if (completeLayoutNeeded || monthGrid.isInvalidateDisplayListReason("todayIndicator"))
            layoutTodayIndicator(selectionLayer, day1, todayDate);
        
        if (completeLayoutNeeded || monthGrid.isInvalidateDisplayListReason("caretIndicator"))
            layoutCaretIndicator(overlayLayer);
        
        if (!completeLayoutNeeded)
            updateDateRenderers();
        
        // To avoid flashing, force all of the layers to render now
        
        monthGrid.validateNow();
    }

    /**
     *  @private
     *  Clear everything.
     */
    override public function clearVirtualLayoutCache():void
    {
        freeItemRenderers(dayRendererCache);
        freeItemRenderers(weekRendererCache);
           
        freeGridElements(rowSeparators);        
        freeGridElements(columnSeparators);        
        
        clearSelectionIndicators();
        
        freeGridElement(hoverIndicator)
        hoverIndicator = null;
        
        freeGridElement(caretIndicator);
        caretIndicator = null;
        
        freeGridElement(todayIndicator);
        todayIndicator = null;        
    }      
    
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
    
    private function get monthGrid():MonthGrid
    {
        return target as MonthGrid;
    }
    
    // monthGrid must not be null
    private function updateOrientationVars(monthGrid:MonthGrid):void
    {
        horizontalLayout = (monthGrid.weekOrientation == WeekOrientation.ROWS);
        maxColumnCount = columnCount = horizontalLayout ? 7 : 6;
        maxRowCount = rowCount = horizontalLayout ? 6 : 7;
    }
        
    /**
     *  @private
     */
    mx_internal function getDateItemRenderer(rowIndex:int, columnIndex:int):IDateItemRenderer
    {
        return getDayOfTheMonthRenderer(rowIndex, columnIndex);
    }

    /**
     *  @private
     */
    mx_internal function getDateItemRendererAtPoint(point:Point):IDateItemRenderer
    {
        const x:Number = point.x;
        const y:Number = point.y;
        
        // ToDo:  optimize this, can find row first then column rather then looking at all of them
        for each (var renderer:IDateItemRenderer in dayRendererCache)
        {
            // Renderers are stored in row major order.  
            // Went past the row it could have been in so bail.
            if (y < renderer.y)
                return null;
            
            if (x >= renderer.x && x <= renderer.x + renderer.width &&
                y >= renderer.y && y <= renderer.y + renderer.height)
            {
                return renderer.enabled ? renderer : null;
            }
            
        }
        
        return null;        
    }

    /**
     *  @private
     */
    mx_internal function getDateItemRendererForDate(date:Date):IDateItemRenderer
    {
        const monthGrid:MonthGrid = target as MonthGrid;
        
        if (date == null || monthGrid == null)
            return null;
        
        if (date.fullYear != monthGrid.displayedYear || date.month != monthGrid.displayedMonth)
            return null;
        
        for each (var renderer:IDateItemRenderer in dayRendererCache)
        {
            const cellDate:Date = renderer.date;
            if (!renderer.date)
                continue;
            
            if (cellDate.date == date.date && cellDate.month == date.month && cellDate.fullYear == date.fullYear)
                return renderer;
        }
        
        return null;        
    }

    /**
     *  @private
     *  Return the displayed column index of the specfied date, given the formatter's first
     *  day of the week index.  Note that the value of date.getDay() is 0-6 where
     *  0 specifies Sunday, 1 specifies Monday, etc. The value of dtf.getFirstWeekday() 
     *  is similar.   For example if dtf.getFirstWeekday() = 6 (Saturday), then the 
     *  column indices for a horizontal layout would be:
     *  
     *      Saturday = 0    Sunday = 1    Monday = 2  ... Friday = 6
     * 
     *  In that case if date corresponded to a Sunday, i.e. if date.getDay() = 0, then this 
     *  function would return 1. 
     */
    private function getDateColumnIndex(date:Date, dtf:DateTimeFormatter=null):int
    {
        if (!dtf)
            dtf = monthGrid.dayOfTheWeekFormatter;
        
        if (horizontalLayout)
            return (date.getDay() - dtf.getFirstWeekday() + 7) % 7;
        
        // Note that getDate()'s value is 1 based, i.e. it ranges from 1-31.                    
        const day1:Date = new Date(date.getFullYear(), date.getMonth(), 1);
        return (date.getDate() - 1 + getDateRowIndex(day1, dtf)) / 7;
    }
    
    /**
     *  @private
     *  Return the rowIndex of the cell displaying date.getDate().   See above.
     */
    private function getDateRowIndex(date:Date, dtf:DateTimeFormatter=null):int
    {
        if (!dtf)
            dtf = monthGrid.dayOfTheWeekFormatter;
        
        if (horizontalLayout)
        {
            // Note that getDate()'s value is 1 based, i.e. it ranges from 1-31.                    
            const day1:Date = new Date(date.getFullYear(), date.getMonth(), 1);
            return (date.getDate() - 1 + getDateColumnIndex(day1, dtf)) / 7;
        }
        
        return (date.getDay() - dtf.getFirstWeekday() + 7) % 7;
        
    }    
    
    private function getDayOfTheMonthRenderer(rowIndex:int, columnIndex:int):IDateItemRenderer
    {
        if (rowIndex == -1 || columnIndex == -1)
            return null;
        
        const cacheIndex:int = (rowIndex * maxColumnCount) + columnIndex;
        var renderer:IDateItemRenderer = dayRendererCache[cacheIndex];
        if (renderer)
            return renderer;
        
        const monthGrid:MonthGrid = target as MonthGrid;
        const factory:IFactory = monthGrid.dayOfTheMonthRenderer;

        // FIXME: see GridItemRendererClassFactory which is a wrapper class for IRs that creates
        // the renderer instance with the grid's module factory.
        renderer = allocateGridElement(factory) as IDateItemRenderer;
        
        renderer.owner = monthGrid;  
        renderer.rowIndex = -1;
        renderer.columnIndex = -1;
        
        rendererLayer.addElement(renderer);
        dayRendererCache[cacheIndex] = renderer;
                
        return renderer;
    }
        
    private function getDayOfTheWeekRenderer(index:int):IDateItemRenderer
    {
        var renderer:IDateItemRenderer = weekRendererCache[index];
        if (renderer)
            return renderer;
        
        const monthGrid:MonthGrid = target as MonthGrid;
        const factory:IFactory = monthGrid.dayOfTheWeekRenderer;
        
        // FIXME: see GridItemRendererClassFactory which is a wrapper class for irs that creates
        // the renderer instance with the grid's module factory.
        renderer = allocateGridElement(factory) as IDateItemRenderer;
        
        renderer.owner = monthGrid; 
        renderer.rowIndex = -1;
        renderer.columnIndex = -1;
        
        rendererLayer.addElement(renderer);
        weekRendererCache[index] = renderer;
        
        return renderer;
    }
    
    private function getPaddedHeight(renderer:IDateItemRenderer):Number
    {
        const monthGrid:MonthGrid = target as MonthGrid;
        
        const paddedHeight:Number =
            renderer.getPreferredBoundsHeight() + monthGrid.cellPaddingTop + monthGrid.cellPaddingBottom; 
        
        return Math.max(0, paddedHeight);
    }
    
    private function getPaddedWidth(renderer:IDateItemRenderer):Number
    {
        const monthGrid:MonthGrid = target as MonthGrid;
        
        const paddedWidth:Number = 
            renderer.getPreferredBoundsWidth() + monthGrid.cellPaddingLeft + monthGrid.cellPaddingRight;
        
        return Math.max(0, paddedWidth);
    }
    
    private function getRendererHeight(paddedHeight:Number):Number
    {
        const monthGrid:MonthGrid = target as MonthGrid;
        
        return paddedHeight - monthGrid.cellPaddingTop - monthGrid.cellPaddingBottom;
    }
    
    private function getRendererWidth(paddedWidth:Number):Number
    {
        const monthGrid:MonthGrid = target as MonthGrid;
        
        return paddedWidth - monthGrid.cellPaddingLeft - monthGrid.cellPaddingRight;
    }
    
    /** 
     *  @private
     *  Reset the selected, showsCaret, and hovered properties for all visible item renderers.
     *  Run the prepare() method for renderers that have changed.
     * 
     *  This method is only called when the item renderers are not updated as part of a general
     *  redisplay, by layoutItemRenderers(). 
     */
    private function updateDateRenderers():void
    {
        const monthGrid:MonthGrid = monthGrid;  // avoid get method cost
        
        const today:Date = new Date();
        
        for each (var renderer:IDateItemRenderer in dayRendererCache)
        {
            if (renderer.rowIndex == -1 || renderer.columnIndex == -1)
                continue;
            
            var rowIndex:int = renderer.rowIndex;
            var columnIndex:int = renderer.columnIndex;
            
            var oldDown:Boolean = renderer.down;
            var oldSelected:Boolean  = renderer.selected;
            var oldToday:Boolean = renderer.today;
            var oldHovered:Boolean = renderer.hovered;
            
            // This should be keopt in sync with intializeDayOfTheMonthRenderer().
            
            renderer.down =
                renderer.rowIndex == monthGrid.mouseDownRowIndex && 
                renderer.columnIndex == monthGrid.mouseDownColumnIndex;
            renderer.hovered = (monthGrid.hoverRowIndex == rowIndex) && (monthGrid.hoverColumnIndex == columnIndex);                                
            renderer.selected = monthGrid.dateSelection.containsDate(renderer.date);            
            
            renderer.showsCaret = DateUtil.datesEqual(renderer.date,  monthGrid.caretDate);
            renderer.today = DateUtil.datesEqual(renderer.date, today);
            
            if (oldSelected != renderer.selected || oldToday != renderer.today ||
                oldHovered != renderer.hovered || oldDown != renderer.down)
            {
                renderer.prepare(true);
            }
        }
    }

    private function intializeDayOfTheMonthRenderer(renderer:IDateItemRenderer, 
                                                    rowIndex:int, columnIndex:int,
                                                    dataItem:Object=null,
                                                    today:Boolean=false,
                                                    previousMonth:Boolean=false,
                                                    nextMonth:Boolean=false,
                                                    visible:Boolean=false):void
    {
        const date:Date = dataItem as Date;
        const selectableDates:DateSet = monthGrid.selectableDates;
        
        renderer.visible = visible;
        
        renderer.rowIndex = rowIndex;
        renderer.columnIndex = columnIndex;
        
        const dateLabel:String = monthGrid.dateToDayOfTheMonthString(date);
        renderer.label = dateLabel;
        renderer.data = dataItem;

        if (monthGrid.dateChooser)
            renderer.owner = monthGrid.dateChooser;
        
        // FIXME: GAT method should replace this hard-coded weekend
        renderer.weekday = date.day != 0 && date.day != 6;       
        renderer.today = today;
    
        renderer.previousMonth = previousMonth;
        renderer.nextMonth = nextMonth;
        
        // FIXME: days from prev/next Month should still be enabled (with reduced alpha) and 
        // clicking on any of them should navigate to that month.
        renderer.enabled = !previousMonth && !nextMonth && 
                           (!selectableDates || selectableDates.isDateIncluded(date));
        
        // This should be kept in sync with updateDateRenderers();
        
        renderer.down = false;
        renderer.hovered = 
            (monthGrid.hoverRowIndex == rowIndex && monthGrid.hoverColumnIndex == columnIndex);        
        renderer.selected = 
            monthGrid.dateSelection ? monthGrid.dateSelection.containsDate(renderer.date) : false;
        renderer.showsCaret = DateUtil.datesEqual(renderer.date,  monthGrid.caretDate);
              
        renderer.prepare(!createdGridElement);
    }
    
    private function intializeDayOfTheWeekRenderer(renderer:IDateItemRenderer, 
                                                   rowIndex:int, columnIndex:int,
                                                   dataItem:Object,
                                                   visible:Boolean=false):void
    {
        const date:Date = dataItem as Date;
        
        renderer.visible = visible;
        
        renderer.rowIndex = rowIndex;
        renderer.columnIndex = columnIndex;
        
        renderer.label = monthGrid.dateToDayOfTheWeekString(date);
        renderer.data = dataItem;
        
        renderer.prepare(!createdGridElement);
    }

    // Specify a typical date to measure the days of the week, otherwise cellWidth, cellHeight and
    // headerSize will be used to set the size of the renderer.
    private function layoutDaysOfWeek(monthGrid:MonthGrid, dateToMeasure:Date=null):void
    {
        const dtf:DateTimeFormatter = monthGrid.dayOfTheWeekFormatter;
        const mgd:Date = dateToMeasure ? dateToMeasure : 
                         new Date(monthGrid.displayedYear, monthGrid.displayedMonth, 1);
        
        var day1:Date = new Date(mgd.fullYear, mgd.month, 1);
        var date:Date = new Date(mgd.fullYear, mgd.month, 1 - (day1.day - dtf.getFirstWeekday()));
        
        var rendererWidth:Number;
        var rendererHeight:Number;
        
        // Use the computed cell values less the cell padding.
        if (dateToMeasure == null)
        {
            rendererWidth = horizontalLayout ? 
                            getRendererWidth(monthGrid.cellWidth) : 
                            getRendererWidth(monthGrid.headerSize);
            rendererHeight = horizontalLayout ? 
                             getRendererHeight(monthGrid.headerSize) : 
                             getRendererHeight(monthGrid.cellHeight);
        }
        
        var x:Number = monthGrid.paddingLeft + monthGrid.cellPaddingLeft;
        var y:Number = monthGrid.paddingTop + monthGrid.cellPaddingTop;        
        
        for (var index:int = 0; index < 7; index++)
        {
            var renderer:IDateItemRenderer = getDayOfTheWeekRenderer(index);
            if (renderer)
            {
                intializeDayOfTheWeekRenderer(renderer, -1, index, date);
                
                renderer.setLayoutBoundsSize(rendererWidth, rendererHeight);
                
                if (dateToMeasure == null)
                {
                    renderer.setLayoutBoundsPosition(x, y);
                    renderer.visible = true;

                    x += horizontalLayout ? monthGrid.cellWidth + monthGrid.horizontalGap : 0;
                    y += horizontalLayout ? 0 : monthGrid.cellHeight + monthGrid.verticalGap;

                }
            }
            
            date.setDate(date.getDate() + 1);
        }

    }
    
    //--------------------------------------------------------------------------
    //
    //  Linear elements: row,column separators, backgrounds 
    //
    //-------------------------------------------------------------------------- 
    
    /**
     *  @private
     *  Common code for laying out the rowSeparator, columnSeparator visual elements.
     */
    private function layoutSeperators(
        factory:IFactory,
        layer:Group, 
        elements:Vector.<IVisualElement>,
        layoutFunction:Function,
        elementCount:int):Vector.<IVisualElement>
    {
        if (!layer)
            return new Vector.<IVisualElement>(0);
        
        // If a factory changed, free the old visual elements and set elements.length=0
        
        discardGridElementsIfFactoryChanged(factory, layer, elements);
        
        if (factory == null)
            return new Vector.<IVisualElement>(0);
        
        var elt:IVisualElement;
        
        // Set any extra seperators invisible.
        for (var i:int = elementCount; i < elements.length; i++)
        {
            elt = elements[i];
            if (elt)
                elt.visible = false;
        }

        // The vector should either be empty or contain the correct number of elements.
        
        if (elements.length < elementCount)
            elements.length = elementCount;
        
        // Create, layout, and return elements.
        
        for (var index:int = 0; index < elementCount; index++)
        {
            elt = elements[index];
            if (elt == null)
                elt = allocateGridElement(factory);
            
            // Initialize the element, and then delegate to the layout function
            
            elements[index] = elt;
            
            layer.addElement(elt);
            
            elt.visible = true;
            
            layoutFunction(elt, index);
        }
        
        return elements;
    }
 
    private function layoutCellElements(
        factory:IFactory,
        layer:Group,
        oldElements:Vector.<IVisualElement>,
        oldRowIndices:Vector.<int>, oldColumnIndices:Vector.<int>,
        newRowIndices:Vector.<int>, newColumnIndices:Vector.<int>,
        layoutFunction:Function):Vector.<IVisualElement>
    {
        if (!layer)
            return new Vector.<IVisualElement>(0);
        
        // If a factory changed, discard the old visual elements.
        
        if (discardGridElementsIfFactoryChanged(factory, layer, oldElements))
        {
            oldRowIndices.length = 0;
            oldColumnIndices.length = 0;
        }
        
        if (factory == null)
            return new Vector.<IVisualElement>(0);
        
        // Create, layout, and return newElements
        
        const newElementCount:uint = newRowIndices.length;
        const newElements:Vector.<IVisualElement> = new Vector.<IVisualElement>(newElementCount);
        
        // Free and clear oldVisibleElements that are no long visible.
        
        freeCellElements(oldElements, newElements,
            oldRowIndices, newRowIndices,
            oldColumnIndices, newColumnIndices);
        
        for (var index:int = 0; index < newElementCount; index++) 
        {
            var newEltRowIndex:int = newRowIndices[index];
            var newEltColumnIndex:int = newColumnIndices[index];
            
            // If an element already exists for visibleIndex then use it, 
            // otherwise create one.
            
            var elt:IVisualElement = newElements[index];
            if (elt === null)
            {
                // Initialize the element, and then delegate to the layout 
                // function.
                elt = allocateGridElement(factory);
                //elt = createGridElement(factory);
                newElements[index] = elt;
            }
            
            layer.addElement(elt);
            
            elt.visible = true;
            
            layoutFunction(elt, newEltRowIndex, newEltColumnIndex);
        }
        
        return newElements;
    }

    /** 
     *  @private
     *  If the factory has changed, or is now null, remove and free all the old
     *  visual elements, if there were any.
     * 
     *  @returns True if at least one visual element was removed.
     */
    private function discardGridElementsIfFactoryChanged(
        factory:IFactory,
        layer:Group,
        oldVisibleElements:Vector.<IVisualElement>):Boolean    
    {
        if ((oldVisibleElements.length) > 0 && (factory != elementToFactoryMap[oldVisibleElements[0]]))
        {
            for each (var oldElt:IVisualElement in oldVisibleElements)
            {
                layer.removeElement(oldElt);
                freeGridElement(oldElt);
            }
            oldVisibleElements.length = 0;
            return true;
        }
        
        return false;
    }
        
    private function freeCellElements (
        elements:Vector.<IVisualElement>, newElements:Vector.<IVisualElement>, 
        oldRowIndices:Vector.<int>, newRowIndices:Vector.<int>,
        oldColumnIndices:Vector.<int>, newColumnIndices:Vector.<int>):void
    {
        var freeElement:Boolean = true;
        
        // assumes newRowIndices.length == newColumnIndices.length
        const numNewCells:int = newRowIndices.length;
        var newIndex:int = 0;
        
        for (var i:int = 0; i < elements.length; i++)
        {
            const elt:IVisualElement = elements[i];
            if (elt == null)
                continue;
            
            // assumes oldIndices.length == elements.length
            const oldRowIndex:int = oldRowIndices[i];
            const oldColumnIndex:int = oldColumnIndices[i];
            
            for ( ; newIndex < numNewCells; newIndex++)
            {
                const newRowIndex:int = newRowIndices[newIndex];
                const newColumnIndex:int = newColumnIndices[newIndex];
                
                if (newRowIndex == oldRowIndex)
                {
                    if (newColumnIndex == oldColumnIndex)
                    {
                        // Same cell still selected so reuse the selection.
                        // Save it in the correct place in newElements.  That 
                        // way we know its location based on 
                        // newRowIndices[newIndex], newColumnIndices[newIndex].
                        newElements[newIndex] = elt;
                        freeElement = false;
                        break;
                    }
                    else if (newColumnIndex > oldColumnIndex)
                    {
                        // not found
                        break;
                    }
                }
                else if (newRowIndex > oldRowIndex)
                {
                    // not found
                    break;
                }
            }
            
            if (freeElement)
                freeGridElement(elt);
            
            freeElement = true;
        }
        
        elements.length = 0;
    }      
    
    private function layoutCellSelectionIndicator(indicator:IVisualElement, 
                                                  rowIndex:int,
                                                  columnIndex:int):void
    {
        const renderer:IDateItemRenderer = getDayOfTheMonthRenderer(rowIndex, columnIndex);

        // Initialize this visual element
        if (renderer)
        {
            initializeMonthGridVisualElement(indicator, rowIndex, columnIndex);
            
            layoutMonthGridElement(indicator, renderer.x, renderer.y, 
                                      renderer.width, renderer.height);
        }
    }    
    
    private function clearSelectionIndicators():void
    {
        freeGridElements(selectionIndicators);
        rowSelectionIndices.length = 0;
        columnSelectionIndices.length = 0;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Selection Indicators
    //
    //--------------------------------------------------------------------------
    
    private var selectionIndicators:Vector.<IVisualElement> = new Vector.<IVisualElement>(0);
    private var rowSelectionIndices:Vector.<int> = new Vector.<int>(0);    
    private var columnSelectionIndices:Vector.<int> = new Vector.<int>(0);
    
    private function layoutSelectionIndicators(layer:Group):void
    {
        const selectionIndicatorFactory:IFactory = monthGrid.selectionIndicator;
        
        // layout and update selectionIndicators, row/ColumnSelectionIndices 
        
        const oldRowSelectionIndices:Vector.<int> = rowSelectionIndices;
        const oldColumnSelectionIndices:Vector.<int> = columnSelectionIndices;
        
        // Load up the vectors with the row/column of each selected cell.
        
        rowSelectionIndices = new Vector.<int>();
        columnSelectionIndices = new Vector.<int>();
        
        // FIXME: should these be maxRowCount/columnCount
        for (var rowIndex:int = 0; rowIndex < rowCount; rowIndex++)
        {
            for (var columnIndex:int = 0; columnIndex < columnCount; columnIndex++)
            {
                var renderer:IDateItemRenderer = getDayOfTheMonthRenderer(rowIndex, columnIndex);
                if (!renderer)
                    continue;
                
                if (renderer.enabled && monthGrid.dateSelection &&
                    monthGrid.dateSelection.containsDate(renderer.date))
                {
                    // FIXME: is this the right ds or can we do the same thing we do for the renderers
                    renderer.selected = true;
                    rowSelectionIndices.push(rowIndex);
                    columnSelectionIndices.push(columnIndex);
                }
                else
                {
                    renderer.selected = false;
                }
            }
        } 
        
        // Display the date selections.
        selectionIndicators = layoutCellElements(
            selectionIndicatorFactory,
            layer,
            selectionIndicators, 
            oldRowSelectionIndices, oldColumnSelectionIndices,
            rowSelectionIndices, columnSelectionIndices,
            layoutCellSelectionIndicator);
        
        return;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Indicators: hover, today
    //
    //--------------------------------------------------------------------------
    
    private function layoutIndicator(
        layer:Group,
        indicatorFactory:IFactory,
        indicator:IVisualElement,
        renderer:IDateItemRenderer):IVisualElement
    {
        if (!layer)
            return null;
        
        // If the indicatorFactory has changed for the specified non-null indicator, 
        // then free the old indicator.
        
        if (indicator && (indicatorFactory != elementToFactoryMap[indicator]))
        {
            removeGridElement(indicator);
            indicator = null;
            if (indicatorFactory == null)
                return null;
        }
        
        const rowIndex:int = renderer ? renderer.rowIndex : -1;
        const columnIndex:int = renderer ? renderer.columnIndex : -1;
        
        if (rowIndex == -1 || columnIndex == -1)
        {
            if (indicator)
                indicator.visible = false;
            return indicator;
        }
        
        if (!indicator && indicatorFactory)
            indicator = createGridElement(indicatorFactory);
            //indicator = indicatorFactory.newInstance() as IVisualElement;

        if (indicator)
        {
            // Initialize this visual element
            initializeMonthGridVisualElement(indicator, rowIndex, columnIndex);
                        
            layoutMonthGridElement(indicator, renderer.x, renderer.y, 
                                      renderer.width, renderer.height);
            
            layer.addElement(indicator);
            indicator.visible = true;
        }
        
        return indicator;
    }
    
    private function layoutCaretIndicator(layer:Group):void
    {
        const factory:IFactory = monthGrid.caretIndicator;
        
        var renderer:IDateItemRenderer;
        renderer = getDateItemRendererForDate(monthGrid.caretDate);
        if (renderer && !renderer.enabled)
            renderer = null;       
        
        caretIndicator = layoutIndicator(layer, factory, caretIndicator, renderer);
        
        // Hide caret based on the showCaret property. Don't show caret
        // if its already hidden by layoutIndicator() because isn't in this month.
        if (caretIndicator && caretIndicator.visible && !monthGrid.showCaret)
            caretIndicator.visible = false;
    }
    

    private function layoutHoverIndicator(layer:Group):void
    {        
        const rowIndex:int = monthGrid.hoverRowIndex;
        const columnIndex:int = monthGrid.hoverColumnIndex;
        
        const factory:IFactory = monthGrid.hoverIndicator;
        
        var renderer:IDateItemRenderer = getDateItemRenderer(rowIndex, columnIndex);
        if (renderer && !renderer.enabled)
            renderer = null;
        
        hoverIndicator = layoutIndicator(layer, factory, hoverIndicator, renderer); 
    }
    
    private function layoutTodayIndicator(layer:Group, day1:Date, todayDate:Date):void
    {        
        // Check if today is in the month being displayed and the today indicator should be shown.
        if (day1.fullYear == todayDate.fullYear && day1.month == todayDate.month && 
            monthGrid.showTodayIndicator)
        {    
            var rowIndex:int = getDateRowIndex(todayDate);
            var columnIndex:int = getDateColumnIndex(todayDate);        
            todayRenderer = getDateItemRenderer(rowIndex, columnIndex);
        }
        else
        {
            todayRenderer = null;
        }

        const factory:IFactory = monthGrid.todayIndicator;
        
        // If the renderer is null, the indicator, if it exists, will be set to !visible.
        todayIndicator = layoutIndicator(layer, factory, todayIndicator, todayRenderer);         
    }
   

    /**
     *  @private
     *  The seperator at columnIndex 0 is before the renderers in column 0.
     *  The seperator at columnIndex 1 is after the renderers in column 0.
     */
    private function layoutColumnSeparator(separator:IVisualElement, num:int):void
    {
        var columnIndex:int = num;
        
        // For horizontalLayout, the first seperator goes after the first column of renderers.
        if (horizontalLayout)
            columnIndex++;       
        
        // Initialize this visual element
        initializeMonthGridVisualElement(separator, -1, columnIndex);
        
        var startX:Number = monthGrid.paddingLeft;
        
        // The calculation for verticalLayout implies the headerGap should be >= horizontalGap.
        if (horizontalLayout)
            startX += monthGrid.cellWidth + monthGrid.horizontalGap/2;
        else
            startX += monthGrid.headerSize + monthGrid.headerGap - monthGrid.horizontalGap/2;
                
        const x:Number = startX + ((monthGrid.cellWidth + monthGrid.horizontalGap) * num); 
        const y:Number = monthGrid.x + monthGrid.paddingTop;
        const width:Number = separator.getPreferredBoundsWidth();
                
        // For a horizontalLayout, measurdHeight always includes 6 weeks so recalculate so
        // the height is correct for all cases of sixWeekLayoutMode.
        var height:Number = Math.ceil(
            (monthGrid.cellHeight * rowCount) +
            (monthGrid.verticalGap * (rowCount - 1)) +
            (horizontalLayout ? monthGrid.headerSize + monthGrid.headerGap : 0));
        

        layoutMonthGridElement(separator, x, y, width, height);
    }

    /**
     *  @private
     *  The seperator at rowIndex 0 is before the renderers in row 0.
     *  The seperator at rowIndex 1 is after the renderers in row 0.
     */
    private function layoutRowSeparator(separator:IVisualElement, num:int):void
    {
        var rowIndex:int = num;
        
        // For verticalLayout, the first seperator goes before the after the first row of renderers.
        if (!horizontalLayout)
            rowIndex++;
        
        // Initialize this visual element
        initializeMonthGridVisualElement(separator, rowIndex, -1);
        
        var startY:Number = monthGrid.paddingTop;
        
        // The calculation for horizontalLayout implies the headerGap should be >= verticalGap.
        if (horizontalLayout)
            startY += monthGrid.headerSize + monthGrid.headerGap - monthGrid.verticalGap/2;
        else
            startY += monthGrid.cellHeight + monthGrid.verticalGap/2;
                
        const x:Number = monthGrid.x + monthGrid.paddingLeft; 
        const y:Number = startY + ((monthGrid.cellHeight + monthGrid.verticalGap) * num);
        const height:Number = separator.getPreferredBoundsHeight();
        
        // For a verticalLayout, measurdWidth always includes 6 weeks so recalculate so
        // the width is correct for all cases of sixWeekLayoutMode.
        var width:Number = Math.ceil(
            monthGrid.cellWidth * columnCount +
            (monthGrid.horizontalGap * (columnCount - 1)) + 
            (horizontalLayout ? 0 : monthGrid.headerSize + monthGrid.headerGap));

        layoutMonthGridElement(separator, x, y, width, height);
    }

    private function layoutMonthGridElement(elt:IVisualElement, 
                                               x:Number, y:Number, 
                                               width:Number, height:Number):void
    {   
        elt.setLayoutBoundsSize(width, height);
        elt.setLayoutBoundsPosition(x, y);
    }

    /**
     *  @private
     *  Calls <code>prepareMonthGridVisualElement()</code> on the element if it is an
     *  IMonthGridVisualElement.
     */
    private function initializeMonthGridVisualElement(elt:IVisualElement, rowIndex:int = -1, columnIndex:int = -1):void
    {
        const monthGridVisualElement:IMonthGridVisualElement = elt as IMonthGridVisualElement;
        if (monthGridVisualElement)
            monthGridVisualElement.prepareMonthGridVisualElement(monthGrid, rowIndex, columnIndex);
    }
    
    private function freeItemRenderer(renderer:IDateItemRenderer):void
    {
        if (!renderer)
            return;
        
        freeGridElement(renderer);
        renderer.discard(true);          
    }
    
    /**
     *  The renderers are freed but the Vector, itself is not.
     */     
    private function freeItemRenderers(renderers:Vector.<IDateItemRenderer>):void
    {
        var length:int = renderers.length;
        for (var i:int=0; i < length; i++)
        {
            var renderer:IDateItemRenderer = renderers[i];
            freeItemRenderer(renderer);
            renderers[i] = null;
        }
    }
    
    //--------------------------------------------------------------------------
    //
    //  Grid Elements - these all come from GridLayout - can we refactor to share?
    //
    //-------------------------------------------------------------------------- 

    /**
     *  @private
     *  Let the allocateGridElement() caller know if the returned element was 
     *  created or recycled.
     */
    private var createdGridElement:Boolean = false;
    
    private function createGridElement(factory:IFactory):IVisualElement
    {
        createdGridElement = true;
        const element:IVisualElement = factory.newInstance() as IVisualElement;
        elementToFactoryMap[element] = factory;
        return element;
    }
     
    /** 
     *  @private
     *  Return an element from the factory-specific free-list, or create a new element,
     *  with createGridElement, if a free element isn't available.
     */
    private function allocateGridElement(factory:IFactory):IVisualElement
    {
        createdGridElement = false;
        const elements:Vector.<IVisualElement> = freeElementMap[factory] as Vector.<IVisualElement>;
        if (elements)
        {
            const element:IVisualElement = elements.pop();
            if (elements.length == 0)
                delete freeElementMap[factory];
            if (element)
                return element;
        }
        
        return createGridElement(factory);
    }
    
    /**
     *  @private
     *  Move the specified element to the free list after hiding it.  Return true if the 
     *  element was added to the free list (freeElements).   Note that we do not remove
     *  the element from its parent.
     */
    private function freeGridElement(element:IVisualElement):Boolean
    {
        if (!element)
            return false;
        
        element.visible = false;
        
        const factory:IFactory = elementToFactoryMap[element]; 
        if (!factory)
            return false;
        
        // Add the renderer to the freeElementMap
        
        var freeElements:Vector.<IVisualElement> = freeElementMap[factory];
        if (!freeElements)
        {
            freeElements = new Vector.<IVisualElement>();
            freeElementMap[factory] = freeElements;            
        }
        freeElements.push(element);
        
        return true;
    }
    
    private function freeGridElements(elements:Vector.<IVisualElement>):void
    {
        for each (var elt:IVisualElement in elements)
        {
            freeGridElement(elt);
        }
        elements.length = 0;
    }
    
    /** 
     *  @private
     *  Remove the element from the elementToFactory map and from the per-factory free list and, finally,
     *  from its container.   On the off chance that someone is monitoring the visible property,
     *  we set that to false, just for good measure.
     */
    private function removeGridElement(element:IVisualElement):void
    {
        const factory:IFactory = elementToFactoryMap[element];
        const freeElements:Vector.<IVisualElement> = (factory) ? freeElementMap[factory] : null;
        if (freeElements)
        {
            const index:int = freeElements.indexOf(element);
            if (index != -1)
                freeElements.splice(index, 1);
            if (freeElements.length == 0)
                delete freeElementMap[factory];      
        }
        
        delete elementToFactoryMap[element];
        
        element.visible = false;
        const parent:IVisualElementContainer = element.parent as IVisualElementContainer;
        if (parent)
            parent.removeElement(element);
    }
            
    //--------------------------------------------------------------------------
    //
    //  Event handlers
    //
    //--------------------------------------------------------------------------
        
}
}