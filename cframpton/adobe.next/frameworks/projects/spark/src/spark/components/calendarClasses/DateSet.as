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
import flash.events.Event;
import flash.events.EventDispatcher;

import mx.core.mx_internal;
import mx.events.FlexEvent;

import spark.components.DateChooser;

use namespace mx_internal;

/**
 *  The DateSet class is used to represent a set of dates.
 *  The time portion of each Date is ignored.
 *
 *  <p>To include all dates after, set <code>minDate</code> to today's date.
 *  To include all dates before today, set <code>maxDate</code> to today's date.
 *  </p>
 * 
 *  @see spark.components.DateChooser#selectableDates
 * 
 *  @langversion 3.0
 *  @playerversion Flash 11
 *  @playerversion AIR 3.0
 *  @productversion Flex 5.0
 */

/**
 *  @private
 *  Usage examples:
 *  1.  Select a single date.
 *  2.  Select only dates within a given range.
 *  3.  Select from a list of dates and/or date ranges, for example 5/7/11, 5/12/11-5/16/11, 5/21/11, etc.
 *  4.  Disable a list of dates and/or date ranges, for example, 7/2/11, 7/5/11, 7/10/11.
 *  5.  Disable all dates before a certain date or after a certain date.
 *  6.  Disable all dates before today (special case of #5).  Enable all dates from today forward.
 *  7.  Only dates in the displayed month are selectable.
 *  8.  Only certain day(s) of the week are selectable or disable certain day(s) of the week.
 *  9.  Only certain day(s) within a date range are selectable, for example, Mondays between 7/1/11 and 8/31/11.
 *  10. Select all dates within x days +/- of a given date.
 */

public class DateSet extends EventDispatcher
{    
    include "../../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Constructor.  
     *  By default all days between <code>minDate</code> and <code>maxDate</code> are included.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5.0
     */
    public function DateSet()
    {
        super();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  excludedDateRanges
    //----------------------------------
    
    private var _excludedDateRanges:Vector.<DateRange>;
    private var excludedDateRangesChanged:Boolean = false;
    
    [Bindable("excludedDateRangesChanged")]
    
    /**
     *  The date ranges that are excluded from the set.  
     *  This is an Vector of <code>DateRange</code>.
     * 
     *  <p>If you get the the vector of excluded dates it will be normalized.
     *  This means it will be sorted based on the startDate of each DateRange and overlapping
     *  DateRanges will be combined.</p> 
     * 
     *  @default null
     * 
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5.0
     */
    public function get excludedDateRanges():Vector.<DateRange>
    {
        if (excludedDateRangesChanged)
        {           
            _excludedDateRanges = DateRange.normalizeDateRanges(_excludedDateRanges);
            excludedDateRangesChanged = false;    
        }
        
        return _excludedDateRanges;
    }
    
    /**
     *  @private
     */
    public function set excludedDateRanges(value:Vector.<DateRange>):void
    {
        if (_excludedDateRanges == value)
            return;
        
        _excludedDateRanges = value;
        excludedDateRangesChanged = true;
        
        dispatchChangeEvent("excludedDateRangesChanged");
    }
    
    //----------------------------------
    //  excludedDays
    //----------------------------------
    
    private var _excludedDays:Vector.<int>;
    
    [Bindable("excludedDaysChanged")]
    
    /**
     *  The list of days of the week (0 for Sunday, 1 for Monday, and so on) that are
     *  excluded from the set.
     *  This is an Vector of <code>int</code>.
     * 
     *  @default null
     * 
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5.0
     */
    public function get excludedDays():Vector.<int>
    {
        return _excludedDays;
    }
    
    /**
     *  @private
     */
    public function set excludedDays(value:Vector.<int>):void
    {
        if (_excludedDays == value)
            return;
        
        _excludedDays = value;
        
        dispatchChangeEvent("excludedDaysChanged");
    }
    
    //----------------------------------
    //  excludeWeekends
    //----------------------------------
    
    // Removed by PARB to reduce complexity of API.  Can use exludedDays.
    
    //----------------------------------
    // includedDateRanges
    //----------------------------------
        
    private var _includedDateRanges:Vector.<DateRange>;
    private var includedDateRangesChanged:Boolean = false;
    
    [Bindable("includedDateRangesChanged")]
    
    /**
     *  The date ranges that are included in the set. 
     *  This is an Vector of <code>DateRange</code>.
     *  Any dates ealier than <code>minDate</code> and later than <code>maxDate</code> are
     *  ignored and not included in the set.
     * 
     *  <p>If this is not set, then all dates between <code>minDate</code> and <code>maxDate</code>,
     *  inclusive, are implicitly included in the set.</p>
     * 
     *  <p>If you get the the vector of excluded dates it will be normalized.
     *  This means it will be sorted based on the startDate of each DateRange and overlapping
     *  DateRanges will be combined.</p> 
     * 
     *  @default null
     *  
     *  @see #minDate
     *  @see #maxDate
     * 
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5.0
     */
    public function get includedDateRanges():Vector.<DateRange>
    {
        if (includedDateRangesChanged)
        {
            _includedDateRanges = DateRange.normalizeDateRanges(_includedDateRanges);
            includedDateRangesChanged = false;    
        }
        
        return _includedDateRanges;
    }
    
    /**
     *  @private
     */
    public function set includedDateRanges(value:Vector.<DateRange>):void
    {
        if (_includedDateRanges == value)
            return;
        
        _includedDateRanges = value;
        includedDateRangesChanged = true;
        
        dispatchChangeEvent("includedDateRangesChanged");
    }

    //----------------------------------
    //  includedDays
    //----------------------------------
    
    // Removed by PARB to reduce complexity of API.  Can include range and then specify excludedDays.
    
    //----------------------------------
    //  filterFunction
    //----------------------------------
    
    private var _filterFunction:Function;
    
    [Inspectable(category="Advanced")]
    
    /**
     *  Specifies a callback function used to determine if a given date that is in the computed
     *  set of included dates should be excluded from the set.
     *  This function allows you to refine the computed set of included dates by excluding
     *  additional dates.
     *  If defined, the <code>isDateIncluded</code> method calls this function if the date is
     *  in the set of computed included dates.
     * 
     *  <p>The signature of the <code>filterFunction</code> function must match the 
     *  following:
     * 
     *      <pre>filterFunction(date:Date):Boolean</pre>
     *  </p>
     * 
     *  <p>The filterFunction should return <code>true</code> if the date is to be included in the
     *  set and it should return <code>false</code> if the date should be excluded from the set.</p>
     * 
     *  <p>For example, you could use this function if you want to include every third Wednesday 
     *  of the month.  You would exclude all days but Wednesday with <code>excludedDays</code>
     *  and then you would write this function to return true if the date is the third
     *  Wednesday of the month.</p>
     *  
     *  @default null
     * 
     *  @see #isDateIncluded()
     * 
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5.0
     */
    public function get filterFunction():Function
    {
        return _filterFunction;
    }
    
    /**
     *  @private
     */
    public function set filterFunction(value:Function):void
    {
        _filterFunction = value;
    }
     
    //----------------------------------
    //  minDate
    //----------------------------------
    
    private var _minDate:Date = new Date(DateChooser.MIN_DATE_DEFAULT.time);

    [Bindable("minDateChanged")]

    /**
     *  The earliest date that can be included in the set.
     *  If you limit the range it will reduce the search time for selectable dates.
     *  The earliest valid date is January 1, 1601.
     * 
     *  <p>If <code>includedDateRanges</code> is not set, then all dates between 
     *  <code>minDate</code> and <code>maxDate</code>, inclusive, are implicitly included in the 
     *  set.</p>
     * 
     *  @default January 1, 1900
     * 
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5.0
     */
    public function get minDate():Date
    {
        return _minDate ? new Date(_minDate.time) : null;
    }
    
    /**
     *  @private
     */
    public function set minDate(value:Date):void
    {
        if (_minDate == value)
            return;
        
        if (value == null || value.time < DateChooser.MIN_DATE.time)
            value = new Date(DateChooser.MIN_DATE.time);
        
        _minDate = new Date(value.time);
        
        dispatchChangeEvent("minDateChanged");
    }
    
    //----------------------------------
    //  maxDate
    //----------------------------------
    
    private var _maxDate:Date = new Date(DateChooser.MAX_DATE_DEFAULT.time);
    
    [Bindable("maxDateChanged")]

    /**
     *  The latest date that can be included in the set.
     *  If you limit the range it will reduce the search time for selectable dates.
     *  The latest valid date is December 31, 9999.
     * 
     *  <p>If <code>includedDateRanges</code> is not set, then all dates between 
     *  <code>minDate</code> and <code>maxDate</code>, inclusive, are implicitly included in the 
     *  set.</p>
     * 
     *  @default December 31, 2100
     * 
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5.0
     */
    public function get maxDate():Date
    {
        return _maxDate ? new Date(_maxDate.time) : null;
    }
    
    /**
     *  @private
     */
    public function set maxDate(value:Date):void
    {
        if (_maxDate == value)
            return;
        
        if (value == null || value.time > DateChooser.MAX_DATE.time)
            value = new Date(DateChooser.MAX_DATE.time);
        
        _maxDate = new Date(value.time);
        
        dispatchChangeEvent("maxDateChanged");
    }

    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------  
    
    override public function toString():String
    {
        return "[DateSet" +
            (minDate ? " minDate=" + minDate.toLocaleString() : "") + 
            (maxDate ? " maxDate=" + maxDate.toLocaleString() : "") + 
            (includedDateRanges ? " includedDateRanges=" + includedDateRanges : "") + 
            (excludedDateRanges ? " excludedDateRanges=" + excludedDateRanges : "") + 
            (excludedDays ? " excludedDays=" + excludedDays : "") + 
            "]";
    }

    //--------------------------------------------------------------------------
    //
    //  Public Methods
    //
    //--------------------------------------------------------------------------   
       
    /**
     *   Returns true if the <code>date</code> is included in the computed set of included
     *   dates.
     *   The computed set incorporates the DateSet properties,  
     *   <code>includedDates</code>, <code>excludedDates</code>, <code>excludedDays</code>,
     *   <code>minDate</code>, <code>maxDate/code and the <code>filterFunction</code>.
     * 
     *   <p>The set of included dates is computed in the following order:</p>
     * 
     *   <ol>
     *   <li>Include all dates in <code>includedDateRanges</code> between <code>minDate</code>
     *   and <code>maxDate</code>, inclusive.</li>
     *   <li>If <code>includedDateRanges</code> is not specified, 
     *   include all dates between <code>minDate</code> and <code>maxDate</code>, inclusive.</li>
     *   <li>Exclude all dates in <code>excludedDateRanges</code>.</li>
     *   <li>Exclude all <code>excludedDays</code></li>
     *   </ol>
     * 
     *   <p>If <code>date</code> is in the set of computed dates, and the 
     *   <code>filterFunction</code></p> is defined, the <code>filterFunction</code> is executed to 
     *   determine if the <code>date</code> should remain in the set.</p>
     * 
     *   @param date The date to test for inclusion in the computed set.
     * 
     *   @returns <code>true</code> if the date is included in the computed set.
     * 
     *   @langversion 3.0
     *   @playerversion Flash 11
     *   @playerversion AIR 3.0
     *   @productversion Flex 5.0
     */
    public function isDateIncluded(date:Date):Boolean
    {
        if (date == null)
            return false;
        
        // If minDate/maxDate specified, is date within that range.
        if (_minDate && DateUtil.dateCompare(_minDate, date) > 0)
            return false;

        if (_maxDate && DateUtil.dateCompare(date, _maxDate) > 0)
            return false;
        
        // If there are any included date ranges then this date must be explicitly included to be
        // in the set.
        if (includedDateRanges && !isDateExplicitlyIncluded(date))
            return false;
        
        //  This date passed all the inclusion tests.  Check that it is not specifically excluded.
        if (isDateExplicitlyExcluded(date))
            return false;
        
        // If function specified, let it decide any final exclusions.
        if (filterFunction != null)
            return filterFunction(date);
        
        return true;
    }
    
    /**
     *  Returns true if all the dates in <code>range</code>, are included in computed set of 
     *  included dates.
     *  The <code>isDateIncluded</code> method is used to determine if each date in 
     *  <code>range</code> is included.
     *  
     *  @see #isDateIncluded
     * 
     *  @param range The range of dates to test for inclusion in the computed set.
     * 
     *  @returns <code>true</code> all the date in the date range are included in the computed set.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5.0
     */
    public function isDateRangeIncluded(range:DateRange):Boolean
    {
        if (!range)
            return false;
        
        var nextDate:Date = DateUtil.scrubTimeValue(range.startDate);
        var endTime:Number = DateUtil.scrubTimeValue(range.endDate).time;
        
        while (nextDate.getTime() <= endTime)
        {
            if (!isDateIncluded(nextDate))
                return false;

            nextDate.date += 1;
        }
        
        return true;
    }
    
    /**
     *  Get the next included date after <code>date</code>.
     *  The <code>isDateIncluded</code> method is used to test dates for inclusion.
     * 
     *  @returns the next included date or null if one is not found between date and maxDate.
     * 
     *  @see #isDateIncluded
     * 
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5.0
     */
    public function getNextIncludedDate(date:Date):Date
    {
        if (date == null)
            return null;
        
        // FIXME: replace with GAT method
        date = new Date(date.fullYear, date.month, date.date + 1);
        
        while (!isDateIncluded(date) && DateUtil.dateCompare(date, _maxDate) <= 0)
        {
            date.date++;    
        }
        
        return DateUtil.dateCompare(date, _maxDate) <= 0 ? date : null;            
    }
    
    /**
     *  Get the previous included date before <code>date</code>.
     *  The <code>isDateIncluded</code> method is used to test dates for inclusion.
     * 
     *  @returns the previous included date or null if one is not found between date and minDate.
     * 
     *  @see #isDateIncluded
     * 
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5.0
     */
    public function getPreviousIncludedDate(date:Date):Date
    {
        if (date == null)
            return null;
        
        // FIXME: replace with GAT method
        date = new Date(date.fullYear, date.month, date.date - 1);
        
        while (!isDateIncluded(date) && DateUtil.dateCompare(_minDate, date) <= 0)
        {
            date.date--;    
        }
        
        return DateUtil.dateCompare(date, _minDate) >= 0 ? date : null;            
    }
    
    //--------------------------------------------------------------------------
    //
    //  Private Methods
    //
    //--------------------------------------------------------------------------   
    
    private function dispatchChangeEvent(type:String):void
    {
        if (hasEventListener(type))
            dispatchEvent(new Event(type));
    }
    
    /**
     *  Return true if the given date is explicitly excluded
     *  from the set.
     */
    private function isDateExplicitlyExcluded(date:Date):Boolean
    {
        if (excludedDays)
        {
            var dayOfTheWeek:int = date.getDay();            
            for each (var d:int in excludedDays) 
            {
                if (dayOfTheWeek == d)
                    return true;
            }
        }
        
        if (excludedDateRanges)
        {
            for each (var dateRange:DateRange in excludedDateRanges) 
            {
                if (dateRange.isDateIncluded(date))
                    return true;
                
                if (DateUtil.dateCompare(dateRange.startDate, date) > 0)
                    break;
            }
        }
        
        return false;
    }
    
    /**
     *  Return true if the given date is explicitly included
     *  in the set.
     */
    private function isDateExplicitlyIncluded(date:Date):Boolean
    {           
        if (includedDateRanges)
        {
            for each (var dateRange:DateRange in includedDateRanges) 
            {
                if (dateRange.isDateIncluded(date))
                    return true;
                
                if (DateUtil.dateCompare(dateRange.startDate, date) > 0)
                    break;
            }
        }
        
        return false;
    }  
}
}