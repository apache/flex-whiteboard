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
import mx.utils.ObjectUtil;

import spark.components.DateChooser;
import spark.components.calendarClasses.DateUtil;
    
use namespace mx_internal;

    //--------------------------------------
    //  Other metadata
    //--------------------------------------
    
    [DefaultProperty("requestedStartDate")]

    /**
     *  The DateRange class defines a data structure 
     *  used by the Spark date classes to represent a period of time.  It can be used to
     *  represent dates.  The time properties of each Date object are scrubbed, i.e. set to zeros.
     *  
     *  Usages:
     *  - a date (a single point in time)
     *  - a range of dates with an explicit start date and end date (startDate <= date <= endDate)
     *  - a start date and a delta of the number of days to the end date 
     *      (ex. range is today to today + 3 days or today + -3 days)
     *  - all dates, before a given date (< startDate)
     *  - all dates, after a given date (> startDate)
     *  
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5.0
     */
    public class DateRange extends EventDispatcher
    {    
        include "../../core/Version.as";
    
        //--------------------------------------------------------------------------
        //
        //  Class methods
        //
        //--------------------------------------------------------------------------
        
        /**
         *  Normalize the vector.
         *  Sort ranges. 
         *  Look for intersections of adjacent ranges and combine ranges.
         */
        static public function normalizeDateRanges(dateRangeVector:Vector.<DateRange>):Vector.<DateRange>
        {        
            // Return -1 if date1 < date2, 0 if equal, and 1 if date1 > date2 in sort order.
            function sortFunction(date1:DateRange, date2:DateRange):Number 
            {
                return DateUtil.dateCompare(date1.startDate, date2.startDate);
            }

            if (!dateRangeVector)
                return null;
            
            // Sort based on startDate.
            dateRangeVector = dateRangeVector.sort(sortFunction);
            
            // Combine overlapping and adjacent date ranges.
            var i:int = 0;
            while(i < dateRangeVector.length)
            {
                const previousItem:DateRange = i == 0 ? null : dateRangeVector[i-1]; 
                const item:DateRange = dateRangeVector[i];
                if (previousItem && (previousItem.intersects(item) || previousItem.adjacent(item)))
                {
                    dateRangeVector[i - 1] = previousItem.union(item);
                    dateRangeVector.splice(i, 1);
                }
                else
                {
                    i++;
                }
            }
            
            return dateRangeVector;
        }

        //--------------------------------------------------------------------------
        //
        //  Constructor
        //
        //--------------------------------------------------------------------------
        
        /**
         *  Constructor.
         * 
         *  If you specify only <code>requestedStartDate</code>, then this range represents a 
         *  single date.
         *  If you specify <code>requestedStartDate</code> and <code>requestedEndDate</code>, and
         *  code>requestedStartDate</code> is less than or equal to <code>requestedEndDate</code>, 
         *  all dates between, and including, <code>requestedStartDate</code> and 
         *  <code>requestedEndDate</code> will be included in the range.
         * 
         *  <p>You may also specify a range with a <code>requestedStartDate</code> and 
         *  <code>deltaDays</code>.</p>
         * 
         *  <p>You may also limit the span of the range by setting <code>minDate</code> and/or
         *  <code>maxDate</code>.  Use <code>startDate</code> and <code>endDate</code> to get
         *  the actual range.</p>
         * 
         *  @see #deltaDays
         *  @see #endDate
         * 
         *  @langversion 3.0
         *  @playerversion Flash 11
         *  @playerversion AIR 3.0
         *  @productversion Flex 5.0
         */
        public function DateRange(requestedStartDate:Date=null, requestedEndDate:Date=null)
        {
            super();
            
            if (requestedStartDate)
            {
                this.requestedStartDate = new Date(requestedStartDate.fullYear, 
                                                   requestedStartDate.month, 
                                                   requestedStartDate.date);
            }
            else
            {
                const now:Date = new Date();
                this.requestedStartDate = new Date(now.fullYear, now.month, now.date);                
            }
            
            if (requestedEndDate)
            {
                this.requestedEndDate = new Date(requestedEndDate.fullYear, 
                                                 requestedEndDate.month, 
                                                 requestedEndDate.date);
            }
        }
        
        //--------------------------------------------------------------------------
        //
        //  Variables
        //
        //--------------------------------------------------------------------------
        
        // Set to true to recalculate the start and end dates.
        private var datesInRangeChanged:Boolean = true;
        
        //--------------------------------------------------------------------------
        //
        //  Properties
        //
        //--------------------------------------------------------------------------
 
                        
        //----------------------------------
        //  includeDatesAfterStartDate
        //----------------------------------
        
        // Removed by PARB to simplify the interface.  Change minDate to startDate.
        
        //----------------------------------
        //  includeDatesBeforeStartDate
        //----------------------------------
        
        // Removed by PARB to simplify the interface.  Change maxDate to startDate.
        
        //----------------------------------
        //  deltaDays
        //----------------------------------
        
        private var _deltaDays:int = 0;
        
        [Bindable("deltaDaysChanged")]

        /**
         *  If set, the range will be include all dates between <code>startDate</code> to 
         *  <code>startDate</code> + <code>deltaDays</code>.  If <code>deltaDays</code> is negative,
         *  the range extends from <code>startDate</code> - <code>deltaDays</code> to 
         *  <code>startDate</code>.
         * 
         *  @default 0
         * 
         *  @langversion 3.0
         *  @playerversion Flash 11
         *  @playerversion AIR 3.0
         *  @productversion Flex 5.0
         */
        public function get deltaDays():int
        {
            return _deltaDays;
        }
        
        /**
         *  @private
         */
        public function set deltaDays(value:int):void
        {
            if (value == _deltaDays)
                return;
            
            resetEndDateProperties();
            
            _deltaDays = value;
            datesInRangeChanged = true;
                        
            dispatchChangeEvent("deltaDaysChanged");
        }
        
        //----------------------------------
        //  endDate
        //----------------------------------
        
        private var _endDate:Date;
        
        /**
         *  The actual latest date in the range.
         */
        public function get endDate():Date
        {
            commitDateRange();
            
            return new Date(_endDate.time);
        }
                
        //----------------------------------
        //  minDate
        //----------------------------------
                
        private var _minDate:Date = new Date(DateChooser.MIN_DATE_DEFAULT.time);
        
        [Bindable("minDateChanged")]
        
        /**
         *  The earliest date that can be included in the range.
         *  The earliest valid date is January 1, 1601.
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
            return new Date(_minDate.time);
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
            
            _minDate = value;
            datesInRangeChanged = true;
            
            dispatchChangeEvent("minDateChanged");
        }
        
        //----------------------------------
        //  maxDate
        //----------------------------------
        
        private var _maxDate:Date = new Date(DateChooser.MAX_DATE_DEFAULT.time);
               
        [Bindable("maxDateChanged")]
        
        /**
         *  The latest date that can be included in the range.
         *  The latest valid date is December 31, 9999.
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
            return new Date(_maxDate.time);
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
            
            _maxDate = value;
            datesInRangeChanged = true;
            
            dispatchChangeEvent("maxDateChanged");
        }
        
        //----------------------------------
        //  requestedEndDate
        //----------------------------------
        
        private var _requestedEndDate:Date = null;
        
        [Bindable("requestedEndDateChanged")]
        
        /**
         *  If set, the range will be include all dates between, and including, 
         *  <code>startDate</code> and <code>endDate</code>.
         *  <code>endDate</code> must be greater than or equal to <code>startDate</code>.
         *  This value may be adjusted for <code>maxDate</code>.
         * 
         *  @see #endDate
         * 
         *  @langversion 3.0
         *  @playerversion Flash 11
         *  @playerversion AIR 3.0
         *  @productversion Flex 5.0
         */
        public function get requestedEndDate():Date
        {
            return _requestedEndDate;
        }
        
        /**
         *  @private
         */
        public function set requestedEndDate(value:Date):void
        {
            if (value == _requestedEndDate)
                return;
            
            resetEndDateProperties();
            
            _requestedEndDate = value ? new Date(value.fullYear, value.month, value.date) : null;
            datesInRangeChanged = true;
            
            dispatchChangeEvent("endDateChanged");
        }
        
        //----------------------------------
        //  requestedStartDate
        //----------------------------------
        
        private var _requestedStartDate:Date  = null;
        
        [Bindable("requestedStartDateChanged")]
        
        /**
         *  The requested starting date for the range. 
         *  This must be specified to have a valid range.
         * 
         *  @see #startDate
         * 
         *  @langversion 3.0
         *  @playerversion Flash 11
         *  @playerversion AIR 3.0
         *  @productversion Flex 5.0
         */
        public function get requestedStartDate():Date
        {
            return _requestedStartDate;
        }
        
        /**
         *  @private
         */
        public function set requestedStartDate(value:Date):void
        {
            if (value == _requestedStartDate)
                return;
            
            _requestedStartDate = value ? new Date(value.fullYear, value.month, value.date) : null;
            datesInRangeChanged = true;
            
            dispatchChangeEvent("startDateChanged");
        }
        
        //----------------------------------
        //  startDate
        //----------------------------------
        
        private var _startDate:Date;
        
        /**
         *  The actual earliest date in the range. 
         * 
         *  @langversion 3.0
         *  @playerversion Flash 11
         *  @playerversion AIR 3.0
         *  @productversion Flex 5.0
         */
        public function get startDate():Date
        {
            commitDateRange();
            
            return new Date(_startDate.time);
        }
        
        //--------------------------------------------------------------------------
        //
        //  Overridden methods
        //
        //-------------------------------------------------------------------------- 
    
        override public function toString():String
        {
            return "[DateRange" + 
                   " startDate=" + startDate.toLocaleDateString() + 
                   " endDate=" + endDate.toLocaleDateString() +
                   "]";
        }
        
        //--------------------------------------------------------------------------
        //
        //  Public Methods
        //
        //--------------------------------------------------------------------------   

        /**
         *  Returns a new <code>DateRange</code> which is a copy of this.
         * 
         *  @return DateRange Returns a copy of this DateRange. 
         * 
         *  @langversion 3.0
         *  @playerversion Flash 11
         *  @playerversion AIR 3.0
         *  @productversion Flex 5.0
         */
        public function clone():DateRange
        {
            var range:DateRange = new DateRange(_requestedStartDate);
            
            range.requestedEndDate = _requestedEndDate;
            
            range.deltaDays = _deltaDays;
            
            return range;
        }
        
        /**
         *  Determines whether the date range specified by the <code>startDate</code>
         *  and <code>endDate</code> parameters is contained within this DateRange object.
         * 
         *  <p>The time properties in the <code>startDate</code> and <code>endDate</code> parameters 
         *  are ignored when the comparison is done.</p>
         *
         *  @param startDate The starting  date of the range being checked.
         *  @param endDate The ending of the range being checked.
         * 
         *  @return true if the range that you specify is contained by this DateRange object; 
         *  otherwise false. 
         * 
         *  @langversion 3.0
         *  @playerversion Flash 11
         *  @playerversion AIR 3.0
         *  @productversion Flex 5.0
         */
        public function isRangeIncluded(startDate:Date, endDate:Date):Boolean
        {
            return isDateIncluded(startDate) && isDateIncluded(endDate);    
        }
                
        /**
         *  Determines if the specified <code>date</code> is within this date range.
         *  The time value in the <code>date</code> object is ignored when the comparison is done.
         *
         *  @param date The date to check.
         * 
         *  @return true if date is in this range
         * 
         *  @langversion 3.0
         *  @playerversion Flash 11
         *  @playerversion AIR 3.0
         *  @productversion Flex 5.0
         */
        public function isDateIncluded(date:Date):Boolean
        {
            return ObjectUtil.dateCompare(startDate, date) <= 0 &&
                   ObjectUtil.dateCompare(endDate, date) >= 0;            
        }
           
        /**
         *  Determines whether <code>dateRange</code> is adjacent to this 
         *  DateRange object.
         *  Two ranges are adjacent if the start day of one range is the day after
         *  the last day of the other range.
         * 
         *  <p>The time properties in the <code>dateRange</code> parameter
         *  are ignored when the comparison is done.</p>
         *
         *  @param dateRange The DateRange object to compare against this DateRange object. 
         * 
         *  @return Boolean A value of true if the range that you specify is adjacent to this 
         *  DateRange object; otherwise false. 
         * 
         *  @langversion 3.0
         *  @playerversion Flash 11
         *  @playerversion AIR 3.0
         *  @productversion Flex 5.0
         */
        public function adjacent(dateRange:DateRange):Boolean
        {
            if (!dateRange)
                return false;
            
            // r1 has the earlier (or same) start date of the two ranges.
            const r1:DateRange = DateUtil.dateCompare(startDate, dateRange.startDate) <= 0 ?
                this : dateRange;
            const r2:DateRange = DateUtil.dateCompare(startDate, dateRange.startDate) <= 0 ?
                dateRange : this;
            
            if (!r1.intersects(r2))
            {
                const nextDay:Date = new Date(r1.endDate.fullYear, r1.endDate.month, r1.endDate.date + 1);
                return DateUtil.datesEqual(nextDay, r2.startDate);
            }
            
            return false;
        }

        /**
         *  Determines whether the date range <code>toInteresect</code> interesects this 
         *  DateRange object.
         * 
         *  <p>The time properties in the <code>toIntersect</code> parameter is
         *  are ignored when the comparison is done.</p>
         *
         *  @param toIntersect The DateRange object to compare against this DateRange object. 
         * 
         *  @return Boolean A value of true if the range that you specify interesects this 
         *  DateRange object; otherwise false. 
         * 
         *  @langversion 3.0
         *  @playerversion Flash 11
         *  @playerversion AIR 3.0
         *  @productversion Flex 5.0
         */
        public function intersects(toIntersect:DateRange):Boolean
        {
            if (!toIntersect)
                return false;
            
            // r1 has the earlier (or same) start date of the two ranges.
            const r1:DateRange = DateUtil.dateCompare(startDate, toIntersect.startDate) <= 0 ?
                this : toIntersect;
            const r2:DateRange = DateUtil.dateCompare(startDate, toIntersect.startDate) <= 0 ?
                toIntersect : this;

            // The ranges are ordered.  If the 2nd range starts before the 1st range ends there
            // is an intersection.
            return r2.startDate <= r1.endDate;
        }
       
        /**
         *  If the DateRange object specified in the toIntersect parameter intersects with this 
         *  DateRange object, returns the area of intersection as a DateRange object. 
         *  If the DateRanges do not intersect, this method returns <code>null</code>.
         * 
         *  <p>The time properties in the <code>toIntersect</code> paraemeter is
         *  are ignored when the comparison is done.</p>
         *
         *  @param toIntersect The DateRange object to compare against this DateRange object. 
         * 
         *  @return DateRange A DateRange object that equals the area of intersection. 
         *  If the DateRanges do not intersect, this method returns null. 
         * 
         *  @langversion 3.0
         *  @playerversion Flash 11
         *  @playerversion AIR 3.0
         *  @productversion Flex 5.0
         */
        public function intersection(toIntersect:DateRange):DateRange
        {
            // The intersection is the later (or same) startDate and the earlier (or same) endDate
            // and startDate is less than or equal the endDate.
            const newStartDate:Date = DateUtil.dateCompare(startDate, toIntersect.startDate) >= 0 ?
                startDate : toIntersect.startDate;
            
            const newEndDate:Date = DateUtil.dateCompare(endDate, toIntersect.endDate) <= 0 ?
                endDate : toIntersect.endDate;
           
            return DateUtil.dateCompare(newStartDate, newEndDate) <= 0 ?
                   new DateRange(newStartDate, newEndDate) : null;
        }

        /**
         *  Adds two date ranges together to create a new DateRange object, by setting the
         *  <code>startDate</code> of the new range to the earlier start date of the two ranges and 
         *  by setting the <code>endDate</code> of the new range to the later end date of the two 
         *  ranges.
         * 
         *  <p>If <code>toUnion</code> is <code>null</code> the new DateRange will be the same
         *  as this DateRange.</p>
         * 
         *  <p>The time properties in the <code>startDate</code> and <code>endDate</code> parameters 
         *  are ignored.</p>
         *
         *  @param range The date range to union with this date range.
         * 
         *  @return DateRange A new DateRange object that is the union of the two date ranges.
         * 
         *  @langversion 3.0
         *  @playerversion Flash 11
         *  @playerversion AIR 3.0
         *  @productversion Flex 5.0
         */
        public function union(toUnion:DateRange):DateRange
        {
            if (!toUnion)
                return new DateRange(startDate, endDate);
            
            // Find the earliest start date.
            var compareResult:int = DateUtil.dateCompare(startDate, toUnion.startDate);
            const earliestStartDate:Date = compareResult <= 0 ? startDate : toUnion.startDate;
            
            // Find the latest end date.
            compareResult = DateUtil.dateCompare(endDate, toUnion.endDate);
            const latestEndDate:Date = compareResult >= 0 ? endDate : toUnion.endDate;
                        
            return new DateRange(earliestStartDate, latestEndDate);
        }

        //--------------------------------------------------------------------------
        //
        //  Private Methods
        //
        //--------------------------------------------------------------------------   
        
        /**
         *  Only one of these properties should be set at a time.
         */
        private function resetEndDateProperties():void
        {
            _endDate = null;
            _deltaDays = 0;
        }
                        
        private function commitDateRange():void
        {
            if (!datesInRangeChanged)
                return;
            
            datesInRangeChanged = false;
                
            _startDate = _requestedStartDate;
            
            if (_requestedEndDate != null)
            {
                // FIXME: endDate < startDate
                _endDate = _requestedEndDate;
            }
            else 
            {
                var deltaDate:Date = new Date(
                    _requestedStartDate.fullYear, _requestedStartDate.month, _requestedStartDate.date + deltaDays, 
                    _requestedStartDate.hours, _requestedStartDate.minutes, _requestedStartDate.seconds, _requestedStartDate.milliseconds);
                
                if ( deltaDays >= 0)
                {
                    _startDate = _requestedStartDate;
                    _endDate = deltaDate;
                }
                else
                {
                    _startDate = deltaDate;
                    _endDate = _requestedStartDate;
                }
            }
            
            // Check the range falls within the bounds.

            if (minDate.time > maxDate.time)
                minDate.time = maxDate.time;
            
            if (_startDate.time < minDate.time)
                _startDate.time = minDate.time;
            
            if (_endDate.time > maxDate.time)
                _endDate.time = maxDate.time;          
        }
                
        /**
         *  @private
         */
        private function dispatchChangeEvent(type:String):void
        {
            if (hasEventListener(type))
                dispatchEvent(new Event(type));
        }        
    }
}