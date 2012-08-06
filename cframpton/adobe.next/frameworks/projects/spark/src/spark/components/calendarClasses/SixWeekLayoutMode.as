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

/**
 *  The DateChooserSelectionMode class defines the valid constant values for the 
 *  <code>selectionMode</code> property of the Spark DateChooser controls.
 *  
 *  <p>Use the constants in ActionsScript, as the following example shows: </p>
 *  <pre>
 *    myDateChooser.selectionMode = DateChooserSelectionMode.MULTIPLE_RANGES;
 *  </pre>
 *
 *  <p>In MXML, use the String value of the constants, 
 *  as the following example shows:</p>
 *  <pre>
 *    &lt;s:DateChooser id="myDateChooser" 
 *        selectionMode="multipleRanges"&gt; 
 *        ...
 *    &lt;/s:DateChooser&gt; 
 *  </pre>
 * 
 *  @see spark.components.DateChooser#selectionMode
 *  
 *  @langversion 3.0
 *  @playerversion Flash 11
 *  @playerversion AIR 3.0
 *  @productversion Flex 5.0         
 */
public final class SixWeekLayoutMode
{
    
    /**
     *  Constructor.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5.0         
     */
    public function SixWeekLayoutMode()
    {
        super();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Specifies only weeks for the current month will be shown.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5.0         
     */
    public static const OFF:String = "off";

    /**
     *  Specifies if extra week(s) are added so that six weeks are shown,
     *  and the first day of the month is at the start of the week, an extra week
     *  will be added before the weeks in the current month.  
     *  Any additional weeks will be added after the weeks in the current month.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5.0         
     */
    public static const EXTRA_WEEK_BEFORE:String = "extraWeekBefore";

    /**
     *  Specifies if extra week(s) are added so that six weeks are shown,
     *  the extra weeks(s) are added after the weeks in the current current month.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5.0         
     */
    public static const EXTRA_WEEK_AFTER:String = "extraWeekAfter";
}
}