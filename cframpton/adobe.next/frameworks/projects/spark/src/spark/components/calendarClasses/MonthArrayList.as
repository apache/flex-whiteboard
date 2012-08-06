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
    import mx.collections.ArrayList;
    import mx.collections.IList;
    import mx.core.mx_internal;
    
    import spark.components.DateChooser;
    import spark.components.calendarClasses.*;
    import spark.globalization.supportClasses.DateTimeFormatterEx;
    
    use namespace mx_internal;
    
    [ExcludeClass]
    
    /**
     *  The MonthArrayList class is a customized subclass of ArrayList is
     *  used as the dataProvider for the DateChooser's dataGroup.
     *  It enables the dataGroup to virtualize the displayable months by mapping between
     *  the month and fullYear of a Date and an index in the ArrayList.
     * 
     *  This class should not be accessed directly.
     *  All accesses should be through the DateChooser's dataGroup.
     */ 
    public class MonthArrayList extends ArrayList implements IList
    {
        public function MonthArrayList(source:Array=null)
        {            
            super(source);
        }
        
        private static const minDate:Date = DateChooser.MIN_DATE;
        private static const maxDate:Date = DateChooser.MAX_DATE;
        private static const minYear:int = DateChooser.MIN_DATE.fullYear;
        private static const maxYear:int = DateChooser.MAX_DATE.fullYear;
        
        /**
         *  @private
         *  Assumes Gregorian calendar with 12 months.
         */       
        static public function indexToDate(index:int):Date
        {
            var year:int = index / 12 + minYear;
            var month:int = index - ((year - minYear) * 12);
            
            return new Date(year, month);   
        }
        
        /**
         *  @private
         *  Assumes Gregorian calendar with 12 months.
         */
        static public function dateToIndex(date:Date):int
        {
            if (date == null || date.time < minDate.time || date.time > maxDate.time)
                return -1;
            
            return (date.fullYear - minYear) * 12 + date.month;
        }
        
        [Bindable("collectionChange")]
        
        /**
         *  @private
         *  Assumes Gregorian calendar with 12 months.
         */
        override public function get length():int
        {
            return (maxYear - minYear + 1) * 12;
        }
        
        //--------------------------------------------------------------------------
        //
        // Overridden Methods
        // 
        //--------------------------------------------------------------------------
        
        /**
         *  @private
         */
        override public function getItemAt(index:int, prefetch:int = 0):Object
        {
            if (index < 0 || index >= length)
                return super.getItemAt(index, prefetch);
            
            if (source[index] === undefined)
                source[index] = indexToDate(index);
            
            return source[index];
        }        
    }    
    
}