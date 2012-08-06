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
package spark.events
{
    
    import flash.events.Event;
    
    /**
     *  The DateChooser control dispatch these events when its displayed state changes due to 
     *  user interaction.
     *
     *  @see spark.components.DateChooser
     *  
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5.0
     */
    public class DateChooserEvent extends Event
    {
        include "../core/Version.as";
        
        //--------------------------------------------------------------------------
        //
        //  Class constants
        //
        //--------------------------------------------------------------------------
        
        /**
         *  The <code>DateChooserEvent.CARET_CHANGE</code> constant defines 
         *  the value of the <code>type</code> property of the event object for a 
         *  <code>caretChange</code> event, which indicates that the current 
         *  caret position has just been changed.
         *
         *
         *  <p>The properties of the event object have the following values:</p>
         *  <table class="innertable">
         *     <tr><th>Property</th><th>Value</th></tr>
         *     <tr><td><code>bubbles</code></td><td>false</td></tr>
         *     <tr><td><code>cancelable</code></td><td>false</td></tr>
         *     <tr><td><code>currentTarget</code></td><td>The Object that defines the 
         *       event listener that handles the event. For example, if you use 
         *       <code>myButton.addEventListener()</code> to register an event listener, 
         *       myButton is the value of the <code>currentTarget</code>. </td></tr>
         *     <tr><td><code>detail</code></td><td>The scroll direction.</td></tr>
         *     <tr><td><code>target</code></td><td>The Object that dispatched the event; 
         *       it is not always the Object listening for the event. 
         *       Use the <code>currentTarget</code> property to always access the 
         *       Object listening for the event.</td></tr>
         *  </table>
         *
         *  @eventType caretChange
         *  
         *  @langversion 3.0
         *  @playerversion Flash 11
         *  @playerversion AIR 3.0
         *  @productversion Flex 5.0
         */
        public static const CARET_CHANGE:String = "caretChange";
        
        /**
         *  The <code>DateChooserEvent.MONTH_SCROLL</code> constant defines the value of the 
         *  <code>type</code> property of the event object for a <code>monthScroll</code>event,
         *  which indicates that the month(s) dispayed has changed because of user interaction.
         *
         *  <p>The properties of the event object have the following values:</p>
         *  <table class="innertable">
         *     <tr><th>Property</th><th>Value</th></tr>
         *     <tr><td><code>bubbles</code></td><td>false</td></tr>
         *     <tr><td><code>cancelable</code></td><td>false</td></tr>
         *     <tr><td><code>currentTarget</code></td><td>The Object that defines the 
         *       event listener that handles the event. For example, if you use 
         *       <code>myButton.addEventListener()</code> to register an event listener, 
         *       myButton is the value of the <code>currentTarget</code>. </td></tr>
         *     <tr><td><code>detail</code></td><td>The scroll direction.</td></tr>
         *     <tr><td><code>target</code></td><td>The Object that dispatched the event; 
         *       it is not always the Object listening for the event. 
         *       Use the <code>currentTarget</code> property to always access the 
         *       Object listening for the event.</td></tr>
         *  </table>
         *
         *  @eventType scroll
         *  
         *  @langversion 3.0
         *  @playerversion Flash 11
         *  @playerversion AIR 3.0
         *  @productversion Flex 5.0
         */
        public static const MONTH_SCROLL:String = "monthScroll";
        
        /**
         *  The <code>DateChooserEvent.SELECTION_CHANGE</code> constant defines 
         *  the value of the <code>type</code> property of the event object for a 
         *  <code>selectionChange</code> event, which indicates that the current 
         *  selection has just been changed.
         *
         *  <p>This event is dispatched when the user interacts with the control.
         *  When you change the selection programmatically, the component does not dispatch the 
         *  <code>selectionChange</code> event. </p>
         *
         *  <p>The properties of the event object have the following values:</p>
         *  <table class="innertable">
         *     <tr><th>Property</th><th>Value</th></tr>
         *     <tr><td><code>bubbles</code></td><td>false</td></tr>
         *     <tr><td><code>cancelable</code></td><td>false</td></tr>
         *     <tr><td><code>currentTarget</code></td><td>The Object that defines the 
         *       event listener that handles the event. For example, if you use 
         *       <code>myButton.addEventListener()</code> to register an event listener, 
         *       myButton is the value of the <code>currentTarget</code>. </td></tr>
         *     <tr><td><code>detail</code></td><td>The scroll direction.</td></tr>
         *     <tr><td><code>target</code></td><td>The Object that dispatched the event; 
         *       it is not always the Object listening for the event. 
         *       Use the <code>currentTarget</code> property to always access the 
         *       Object listening for the event.</td></tr>
         *  </table>
         *
         *  @eventType selectionChange
         *  
         *  @langversion 3.0
         *  @playerversion Flash 11
         *  @playerversion AIR 3.0
         *  @productversion Flex 5.0
         */
        public static const SELECTION_CHANGE:String = "selectionChange";
        
        //--------------------------------------------------------------------------
        //
        //  Constructor
        //
        //--------------------------------------------------------------------------
        
        // TBD: could be more than one month or one year
        
        /**
         *  Constructor.
         *  Normally called by the DateChooser object and not used in application code.
         *
         *  @param type The event type; indicates the action that triggered the event.
         *  @param bubbles Specifies whether the event can bubble up the display list hierarchy.
         *  @param cancelable Specifies whether the behavior associated with the event can be prevented.
         *  
         *  @langversion 3.0
         *  @playerversion Flash 9
         *  @playerversion AIR 1.1
         *  @productversion Flex 3
         */
        public function DateChooserEvent(type:String, bubbles:Boolean = false,
                                         cancelable:Boolean = false)
        {
            super(type, bubbles, cancelable);
        }
        
        //--------------------------------------------------------------------------
        //
        //  Properties
        //
        //--------------------------------------------------------------------------
               
        //--------------------------------------------------------------------------
        //
        //  Overridden methods: Event
        //
        //--------------------------------------------------------------------------
        
        /**
         *  @private
         */
        override public function clone():Event
        {
            return new DateChooserEvent(type, bubbles, cancelable);
        }

        /**
         *  @private
         */
        override public function toString():String
        {
            return formatToString(
                "DateChooserEvent", "type", 
                "bubbles", "cancelable", "eventPhase");
        }
            
    }
    
}
