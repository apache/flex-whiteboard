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
public final class DateChooserSelectionMode
{
    
    /**
     *  Constructor.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5.0         
     */
    public function DateChooserSelectionMode()
    {
        super();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Specifies that one date can be selected.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5.0         
     */
    public static const SINGLE_DATE:String = "singleDate";

    /**
     *  Specifies that a single range of contiguous dates can be selected.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5.0         
     */
    public static const SINGLE_RANGE:String = "singleRange";

    /**
     *  Specifies that multiple ranges of dates can be selected.
     *  A range can be one or more days.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5.0         
     */
    public static const MULTIPLE_RANGES:String = "multipleRanges";
}
}