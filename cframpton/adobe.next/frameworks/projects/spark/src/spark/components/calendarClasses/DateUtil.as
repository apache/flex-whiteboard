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
    [ExcludeClass]
    
    import flash.events.Event;
    import flash.events.EventDispatcher;
    
    import mx.events.FlexEvent;
    import mx.utils.ObjectUtil;
    
    /**
     *  The DateUtil class contains date and time utility functions.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5.0
     */
    public class DateUtil
    {    
        include "../../core/Version.as";
    
        //--------------------------------------------------------------------------
        //
        //  Class methods
        //
        //--------------------------------------------------------------------------
        
        /**
         *  Compares the fullYear, month and date properties of two dates, returning -1 if the 
         *  first date is before the second, 0 if the dates are equal, or 1 if the first date 
         *  is after the second.
         *  The time portion of both date is ignored.
         *
         *  @param date1 The first date.
         *  @param date2 The second date.
         * 
         *  @returns -1 if date1 < date2, 0 if date1 = date2, 1 if date1 > date2.
         * 
         *  @langversion 3.0
         *  @playerversion Flash 11
         *  @playerversion AIR 3.0
         *  @productversion Flex 5.0
         */
        public static function dateCompare(date1:Date, date2:Date):Number
        {
            if (date1 == null && date2 == null)
                return 0;
            
            if (date1 == null)
                return 1;
            
            if (date2 == null)
                return -1;
            
            if (date1.fullYear < date2.fullYear)
                return -1;            
            if (date1.fullYear > date2.fullYear)
                return 1;
            
            // Years are the same.
            if (date1.month < date2.month)
                return -1;
            if (date1.month > date2.month)
                return 1;
            
            // Months are the same.
            if (date1.date < date2.date)
                return -1;
            if (date1.date > date2.date)
                return 1;
            
            // Dates are the same.
            return 0;
        } 

        /**
         *  Returns <code>true</code> if day, month and fullYear of date1 are equal to day, 
         *  month and fullYear of date2.  
         *  The time portion of both date is ignored.
         *  
         *  @param date1 The first date.
         *  @param date2 The second date.
         * 
         *  @returns true if the dates are equal (times are ignored).
         * 
         *  @langversion 3.0
         *  @playerversion Flash 11
         *  @playerversion AIR 3.0
         *  @productversion Flex 5.0
         */
        public static function datesEqual(date1:Date, date2:Date):Boolean
        {
            return (date1 == null && date2 == null) || 
                   (date1 && date2 &&
                        date1.date == date2.date && date1.month == date2.month && 
                            date1.fullYear == date2.fullYear);   
        }
        
        /**
         *  Creates a new Date with the same date fields as <code>value</code> but the time 
         *  fields (hours, minutes, seconds, milliseconds) are set to zero.
         *  This is useful if you want to compare dates.
         *  
         *  @default "now"
         * 
         *  @param value The Date.
         * 
         *  @returns A new date object with the time fields zeroed out.
         * 
         *  @langversion 3.0
         *  @playerversion Flash 11
         *  @playerversion AIR 3.0
         *  @productversion Flex 5.0
         */
        public static function scrubTimeValue(value:Date):Date
        {
            if (value == null)
                value = new Date();
            
            return new Date(value.getFullYear(), value.getMonth(), value.getDate(), 0, 0, 0, 0);
        }        
    }
}