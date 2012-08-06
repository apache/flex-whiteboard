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
import flash.geom.Rectangle;

import mx.core.mx_internal;
import mx.utils.ObjectUtil;

import spark.components.calendarClasses.DateRange;
import spark.components.supportClasses.Range;

use namespace mx_internal;
  
[ExcludeClass]

/**
 *  Te DateSelection class tracks a date selector's set of selected date.
 * 
 *  @see spark.components.DateChooser
 *  
 *  @langversion 3.0
 *  @playerversion Flash 11
 *  @playerversion AIR 3
 *  @productversion Flex 5.0
 */
public class DateSelection
{
    include "../../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Class variables
    //
    //--------------------------------------------------------------------------
    /**
     * The number of milliseconds in one day
     */     
    public static const MILLISECONDS_IN_DAY : Number = 86400000;

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
    public function DateSelection()
    {
        super();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    
    
    /**
     *  Ordered List of selected DateRanges.  There should not be any overlapping
     *  ranges or contiguous ranges.
     */    
    private var dateRanges:Vector.<DateRange> = new Vector.<DateRange>();
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
   
    //----------------------------------
    //  count
    //----------------------------------
    
    /**
     *  The number of selected ranges.  A range can may contain one or more consecutive dates.
     *   
     *  @default 0
     * 
     *  @return Number of selected ranges.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3
     *  @productversion Flex 5.0
     */
    public function get count():int
    {
        return dateRanges.length;        
    }
    
    //----------------------------------
    //  lastSelectedDate
    //----------------------------------
    
    private var _lastSelectedDate:Date = null;
    
    /**
     *  The last date that was selected.  
     *  If the last selection was a range this will be the last date in the range.
     *  This is reset if the selection is reset or a date is removed from the selection.
     *   
     *  @default null
     * 
     *  @return The last selected Date.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3
     *  @productversion Flex 5.0
     */
    public function get lastSelectedDate():Date
    {
        return _lastSelectedDate ? new Date(_lastSelectedDate.time) : null;        
    }
    
    /**
     *  Returns a list of all the selected dates.
     * 
     *  @return Vector of selected dates or, if none are selected, a Vector of length 0.  
     *
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3
     *  @productversion Flex 5.0
     */
    public function allDates():Vector.<Date>
    {
        var dateList:Vector.<Date> = new Vector.<Date>;
        
        for each (var range:DateRange in dateRanges)
        {
            var nextDate:Date = new Date(range.startDate.getTime());
            var endTime:Number = range.endDate.getTime();
            
            while (nextDate.getTime() <= endTime)
            {
                dateList.push(new Date(nextDate.getTime()));
                nextDate.date++;
            }            
        }
                
        return dateList;
    }
        
    /**
     *  Returns a list of all the selected date ranges.
     * 
     *  @return Vector of selected date ranges or, if none, a Vector of length 0.  
     * 
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3
     *  @productversion Flex 5.0
     */
    public function allDateRanges():Vector.<DateRange>
    {        
        var rangeList:Vector.<DateRange> = new Vector.<DateRange>(0);
        
        for each (var range:DateRange in dateRanges)
        {
            rangeList.push(range.clone());
        }
       
        return rangeList;
    }

    /**
     *  Removes the current selection.  
     * 
     *  @return true if the list of selected items has changed.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3
     *  @productversion Flex 5.0
     */
    public function removeAll():Boolean
    {
        var selectionChanged:Boolean = count > 0;
        
        dateRanges.length = 0;
        _lastSelectedDate = null;
        
        return selectionChanged;
    }
                 
    /**
     *  Determines if the date is in the current selection.
     * 
     *  @param date The date.
     * 
     *  @return true if the date is in the selection.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3
     *  @productversion Flex 5.0
     */
    public function containsDate(date:Date):Boolean
    {   
        if (date == null)
            return false;
                
        return isDateSelected(DateUtil.scrubTimeValue(date));
    }
        
    /**
     *  Determines if all the dates between <code>startDate</code> and <code>endDate</code, 
     *  exclusive, are contained in the current selection.
     *  The <code>startDate</code> must be less than or equal to the <code>endDate/<code>.
     * 
     *  @param startDate The start date.
     * 
     *  @param endDate The end date.
     * 
     *  @return true if the dates are in the selection.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3
     *  @productversion Flex 5.0
     */
    public function containsDateRange(startDate:Date, endDate:Date):Boolean
    {
        if (!validateDateRange(startDate, endDate))
            return false;
        
        const scrubbedStartDate:Date = DateUtil.scrubTimeValue(startDate)
        const scrubbedEndDate:Date = DateUtil.scrubTimeValue(endDate);
        
        for each (var range:DateRange in dateRanges)
        {
            if (range.isRangeIncluded(scrubbedStartDate, scrubbedEndDate))
                return true;
        }
                
        return false;
    }
        
    /**
     *  Determines if all the dates between <code>startDate</code> and <code>endDate</code, 
     *  exclusive, are the only dates contained in the current selection.
     * 
     *  @param startDate The start date.
     * 
     *  @param endDate The end date.
     * 
     *  @return true if the dates are the only dates in the selection.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3
     *  @productversion Flex 5.0
     */
    public function containsOnlyDateRange(startDate:Date, endDate:Date):Boolean
    {
        if (!validateDateRange(startDate, endDate))
            return false;
        
        const scrubbedStartDate:Date = DateUtil.scrubTimeValue(startDate)
        const scrubbedEndDate:Date = DateUtil.scrubTimeValue(endDate);
        
        if (dateRanges.length == 1)
        {
            var range:DateRange = dateRanges[0];
            if (range.startDate.time == scrubbedStartDate.time && 
                range.endDate.time == scrubbedEndDate.time)
            {
                return true;
            }
        }
        
        return false;
    }
    
    /**
     *  Selects the given date.
     * 
     *  @param date The date to select.
     * 
     *  @return true if the date is selected.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3
     *  @productversion Flex 5.0
     */    
    public function setDate(date:Date):Boolean
    {
        if (date == null)
            return false;
        
        internalSetDateRange(DateUtil.scrubTimeValue(date), DateUtil.scrubTimeValue(date));
        _lastSelectedDate = date;
        
        return true;
    }
        
    /**
     *  Adds the date to the selection.
     * 
     *  @param date The date to add to the selection.
     * 
     *  @return true if the date is added to the selection.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3
     *  @productversion Flex 5.0
     */    
    public function addDate(date:Date):Boolean
    {   
        if (date == null)
            return false;
        
        const changed:Boolean = internalAddDateRange(DateUtil.scrubTimeValue(date));
        if (changed)
            _lastSelectedDate = date;
        
        return changed;
    }

    /**
     *  Removes the date from the selection.
     * 
     *  @param date The date to remove from the selection.
     * 
     *  @return true if the date is removed from the selection.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3
     *  @productversion Flex 5.0
     */    
    public function removeDate(date:Date):Boolean
    {
        if (date == null)
            return false;

        const changed:Boolean = internalRemoveDate(DateUtil.scrubTimeValue(date));
        if (changed)
            _lastSelectedDate = null;
        
        return changed;
    }

    /**
     *  Sets the selection to the dates between <code>startDate</code> and <code>endDate</code>, 
     *  inclusive.
     * 
     *  @param startDate The earliest date in the selection.
     * 
     *  @param endDate The latest date in the selection.
     * 
     *  @return true if the selection is set to the dates in the range.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3
     *  @productversion Flex 5.0
     */    
    public function setDateRange(startDate:Date, endDate:Date):Boolean
    {
        // This assumes caller checks whether dates are selectable.
        
        if (!validateDateRange(startDate, endDate))
            return false;

        dateRanges.length = 0;    
        
        const changed:Boolean =
            internalAddDateRange(DateUtil.scrubTimeValue(startDate), 
                                 DateUtil.scrubTimeValue(endDate));
        
        if (changed)
            _lastSelectedDate = endDate;
        
        return changed;
    }
    
    /**
     *  Adds the dates between <code>startDate</code> and <code>endDate</code>, 
     *  inclusive, to the selection.
     * 
     *  @param startDate The earliest date in the selection.
     * 
     *  @param endDate The latest date in the selection.
     * 
     *  @return true if the dates in the range are added to the selection.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3
     *  @productversion Flex 5.0
     */    
    public function addDateRange(startDate:Date, endDate:Date):Boolean
    {
        // This assumes caller checks whether dates are selectable.
        
        if (!validateDateRange(startDate, endDate))
            return false;

        const changed:Boolean =
            internalAddDateRange(DateUtil.scrubTimeValue(startDate), 
                                 DateUtil.scrubTimeValue(endDate));
        if (changed)
            _lastSelectedDate = endDate;
        
        return changed;
    }

    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
                
    /**
     *  Check the range.  Both start and end dates must be specified and 
     *  startDate <= endDate.
     */    
    protected function validateDateRange(startDate:Date, endDate:Date):Boolean
    {
        return (startDate && endDate && DateUtil.dateCompare(startDate, endDate) != 1);
    }

    /**
     *  True if the given date is contained in the list of selected dates.
     */
    private function isDateSelected(date:Date):Boolean
    {   
        // This assumes times are are scrubbed.
        
        for each (var range:DateRange in dateRanges)
        {
            if (range.isDateIncluded(date))
                return true;
        }
        
        return false;
    }
    
    /**
     *  @private
     *  Initalize the list of dateRanges with this one.
     */
    private function internalSetDateRange(startDate:Date, endDate:Date):void
    {
        // This assumes times are scrubbed.
        
        dateRanges.length = 0;
        dateRanges.push(new DateRange(startDate, endDate));
    }

    /**
     *  Adds the range to the selection.  Overlapping and continguous ranges are combined.
     */
    private function internalAddDateRange(startDate:Date, endDate:Date=null):Boolean
    {
        // Assumes the time values have been scrubbed.
        
        if (endDate == null)
            endDate = startDate;
        
        var newRange:DateRange;
        var previousRange:DateRange;
        var range:DateRange;
   
        // Find the insertion point based on start date.       

        for (var i:int = 0; i < dateRanges.length; i++)
        {
            range = dateRanges[i];
            
            if (range.isRangeIncluded(startDate, endDate))
                return false;

            // The new entry belongs here.
            if (startDate.time <= range.startDate.time)
                break;                                        
                                   
            previousRange = range;
        }
        
        // If this range overlaps or is adjacent to the previous range, 
        // just extend the previous range.
        if (previousRange &&
            (previousRange.endDate.time >= startDate.time ||
            previousRange.endDate.time + MILLISECONDS_IN_DAY == startDate.time))
        {
            newRange = previousRange;
            newRange.requestedEndDate = endDate;
            // i is already at the next entry
        }
        else
        {
            // Insert this range. 
            newRange = new DateRange(startDate, endDate);
            dateRanges.splice(i, 0, newRange);
            i++;
        }
           
        // Look at the remaining entries for overlaps/intersections and adjacencies.  As soon as 
        // there aren't any, we're done.
        for (i = i; i < dateRanges.length; )
        {
            range = dateRanges[i];
            
            if (newRange.isRangeIncluded(range.startDate, range.endDate))
            {
                // remove this range since it is contained in newRange
                dateRanges.splice(i, 1);                    
            }
            else if (newRange.intersects(range))
            {
                // combine newRange and this range and remove this range
                if (ObjectUtil.dateCompare(newRange.endDate, range.endDate) < 0)
                    newRange.requestedEndDate = range.endDate;
                dateRanges.splice(i, 1);
            }
            else if (newRange.endDate.time + MILLISECONDS_IN_DAY == range.startDate.time)
            {
                // new range is before and adjacent to existing range so combine them in newRange
                // and remove this range
                newRange.requestedEndDate = range.endDate;
                dateRanges.splice(i, 1);
            }
            else
            {
                break;
            }
        }
        
        return true;
    }

    /**
     *  @private
     *  Remove the given date from the list of dateRanges.
     */
    private function internalRemoveDate(date:Date):Boolean
    {
        // Assumes the time values have been scrubbed.
        
        var dateRangesLength:int = dateRanges.length;
        for (var i:int = 0; i < dateRangesLength; i++)
        {
            var range:DateRange = dateRanges[i];
            
            // Ranges sorted by start time.  If range start time greater than date it means the
            // date isn't in the selection.
            if (ObjectUtil.dateCompare(range.startDate, date) > 0)
                break;
            
            // Date not in this range.
            if (!range.isDateIncluded(date))
                continue;
            
            // Ok, we know the date is in this range.
            
            if (ObjectUtil.dateCompare(range.startDate, date) == 0)
            {
                if (ObjectUtil.dateCompare(range.startDate, range.endDate) == 0)
                {
                    // Single date.  Removing date means removing range.
                    dateRanges.splice(i, 1);
                    return true;
                }
                else
                {
                    // Move range start to the next day.  Position of range in list not changed.
                    range.requestedStartDate = new Date(range.startDate.time + MILLISECONDS_IN_DAY);
                    return true;
                }
            }
            else if (ObjectUtil.dateCompare(range.endDate, date) == 0)
            {
                // Move range end back one day.  Position of range in list not changed.
                range.requestedEndDate = new Date(range.endDate.time - MILLISECONDS_IN_DAY);
                return true;
            }
            else
            {
                // Remove date from the middle of the range.  Split range into two ranges.
                var newStartDate:Date = new Date(date);
                newStartDate.date++;
                var newRange:DateRange = new DateRange(newStartDate, range.endDate);
                
                date.date--;
                range.requestedEndDate = date;
                
                // Insert the new range after this range.
                dateRanges.splice(i + 1, 0, newRange);
                return true;
            }
        }
        
        return false;
    }     
}
}
