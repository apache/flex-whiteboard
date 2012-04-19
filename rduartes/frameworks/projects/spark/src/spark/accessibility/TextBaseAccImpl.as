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

package spark.accessibility
{

import flash.accessibility.Accessibility;
import flash.events.Event;
import mx.accessibility.AccImpl;
import mx.accessibility.AccConst;
import mx.core.UIComponent;
import mx.core.mx_internal;

import spark.components.supportClasses.TextBase;

use namespace mx_internal;

/**
 *  TextBaseAccImpl is the accessibility implementation class
 *  for spark.components.TextBase.
 *
 *  <p>When a Spark Label or RichText component is created,
 *  its <code>accessibilityImplementation</code> property
 *  is set to an instance of this class.
 *  The Flash Player then uses this class to allow MSAA clients
 *  such as screen readers to see and manipulate
 *  the Label or RichText component.
 *  See the mx.accessibility.AccImpl and
 *  flash.accessibility.AccessibilityImplementation classes
 *  for background information about accessibility implementation
 *  classes and MSAA.</p>
 *
 *  <p><b>Children</b></p>
 *
 *  <p>A TextBase has no MSAA children.</p>
 *
 *  <p><b>Role</b></p>
 *
 *  <p>The MSAA Role of a TextBase is ROLE_SYSTEM_STATICTEXT.</p>
 *
 *  <p><b>Name</b></p>
 *
 *  <p>The MSAA Name of a TextBase is, by default, the text that it displays.
 *  When wrapped in a FormItem,
 *  this text will be combined with the FormItem's label.
 *  To override this behavior,
 *  set the component's <code>accessibilityName</code> property.</p>
 *
 *  <p>When the Name changes,
 *  a TextBase dispatches the MSAA event EVENT_OBJECT_NAMECHANGE.</p>
 *
 *  <p><b>Description</b></p>
 *
 *  <p>The MSAA Description of a TextBase is, by default, the empty string,
 *  but you can set the TextBase's <code>accessibilityDescription</code>
 *  property.</p>
 *
 *  <p><b>State</b></p>
 *
 *  <p>The MSAA State of a TextBase is a combination of:
 *  <ul>
 *    <li>STATE_SYSTEM_UNAVAILABLE (when enabled is false)</li>
 *    <li>STATE_SYSTEM_READONLY</li>
 *  </ul></p>
 *
 *  <p>When the State changes,
 *  a TextBase dispatches the MSAA event EVENT_OBJECT_STATECHANGE.</p>
 *
 *  <p><b>Value</b></p>
 *
 *  <p>A TextBase does not have an MSAA Value.</p>
 *
 *  <p><b>Location</b></p>
 *
 *  <p>The MSAA Location of a TextBase is its bounding rectangle.</p>
 *
 *  <p><b>Default Action</b></p>
 *
 *  <p>A TextBase does not have an MSAA DefaultAction.</p>
 *
 *  <p><b>Focus</b></p>
 *
 *  <p>A TextBase does not accept focus.</p>
 *
 *  <p><b>Selection</b></p>
 *
 *  <p>A TextBase does not support selection in the MSAA sense.</p>
 *
 *  <p><b>Other</b></p>
 *
 *  <p>MSAA documentation suggests that the <code>accessibilityShortcut</code>
 *  should be set to the shortcut keystroke for any associated input component.
 *  Since the shortcut is an accessibility property
 *  and not implementable by an AccessibilityImplementation
 *  it is not addressed in TextBaseAccImpl.</p>
 *
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class TextBaseAccImpl extends AccImpl
{
    include "../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Class methods
    //
    //--------------------------------------------------------------------------

    /**
     *  Enables accessibility in the TextBase class.
     *
     *  <p>This method is called by application startup code
     *  that is autogenerated by the MXML compiler.
     *  Afterwards, when instances of TextBase are initialized,
     *  their <code>accessibilityImplementation</code> property
     *  will be set to an instance of this class.</p>
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static function enableAccessibility():void
    {
        TextBase.createAccessibilityImplementation =
            createAccessibilityImplementation;
    }

    /**
     *  @private
     *  Creates a TextBase's AccessibilityImplementation object.
     *  This method is called from UIComponent's
     *  initializeAccessibility() method.
     */
    mx_internal static function createAccessibilityImplementation(
                                component:UIComponent):void
    {
        component.accessibilityImplementation =
            new TextBaseAccImpl(component);
    }

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor.
     *
     *  @param master The UIComponent instance that this AccImpl instance
     *  is making accessible.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function TextBaseAccImpl(master:UIComponent)
    {
        super(master);

        role = AccConst.ROLE_SYSTEM_STATICTEXT;
    }

    //--------------------------------------------------------------------------
    //
    //  Overridden properties: AccImpl
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  eventsToHandle
    //----------------------------------

    /**
     *  @private
     *    Array of events that we should listen for from the master component.
     */
    override protected function get eventsToHandle():Array
    {
        return super.eventsToHandle.concat(["updateComplete"]);
    }

    //--------------------------------------------------------------------------
    //
    //  Overridden methods: AccessibilityImplementation
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  IAccessible method for returning the state of the TextBase.
     *  States are predefined for all the components in MSAA.
     *  Values are assigned to each state.
     *  Depending upon the TextBase being enabled,
     *  a state is returned.
     *
     *  @param childID uint
     *
     *  @return State uint
     */
    override public function get_accState(childID:uint):uint
    {
        var accState:uint = getState(childID);

        accState &= ~AccConst.STATE_SYSTEM_FOCUSABLE;
        
        accState |= AccConst.STATE_SYSTEM_READONLY;
        
        return accState;
    }

    //--------------------------------------------------------------------------
    //
    //  Overridden methods: AccImpl
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  method for returning the name of the TextBase
     *  which is spoken out by the screen reader
     *  The TextBase should return the text inside as the name of the TextBase.
     *  The name in AccessibilityProperties is combined with the name
     *  specified here.
     *
     *  @param childID uint
     *
     *  @return Name String
     */
    override protected function getName(childID:uint):String
    {
        var label:String = TextBase(master).text;

        return label != null && label != "" ? label : "";
    }

    //--------------------------------------------------------------------------
    //
    //  Overridden event handlers: AccImpl
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  Override the generic event handler.
     *  All AccImpl must implement this
     *  to listen for events from its master component.
     */
    override protected function eventHandler(event:Event):void
    {
        // Let AccImpl class handle the events
        // that all accessible UIComponents understand.
        $eventHandler(event);

        switch (event.type)
        {
            case "updateComplete":
            {
                Accessibility.sendEvent(master, 0, AccConst.EVENT_OBJECT_NAMECHANGE);
                Accessibility.updateProperties();
                break;
            }
        }
    }
}

}
