/**
 Licensed to the Apache Software Foundation (ASF) under one or more
 contributor license agreements.  See the NOTICE file distributed with
 this work for additional information regarding copyright ownership.
 The ASF licenses this file to You under the Apache License, Version 2.0
 (the "License"); you may not use this file except in compliance with
 the License.  You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */
package org.apache.flex.utilities.developerToolSuite.presentation.graphic.component {
    import flash.events.Event;

    import spark.components.BorderContainer;
    import spark.core.IDisplayText;

    /**
     *  Color applied to the button when the emphasized flag is true.
     *
     *  @default #0099FF
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    [Style(name="accentColor", type="uint", format="Color", inherit="yes", theme="spark, mobile")]

    /**
     *  Color of text shadows.
     *
     *  @default #FFFFFF
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    [Style(name="textShadowColor", type="uint", format="Color", inherit="yes", theme="mobile")]

    /**
     *  Alpha of text shadows.
     *
     *  @default 0.55
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    [Style(name="textShadowAlpha", type="Number", inherit="yes", minValue="0.0", maxValue="1.0", theme="mobile")]

    [Exclude(name="textAlign", kind="style")]

    //-------------------------------------- //  Other metadata //--------------------------------------

    public class Frame extends BorderContainer {
        public function Frame() {
            super();
        }

        [SkinPart(required="false")]

        /**
         *  A skin part that defines the label of the button.
         *
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 1.5
         *  @productversion Flex 4
         */ public var labelDisplay:IDisplayText;

        //--------------------------------------------------------------------------
        //
        //  Overridden methods
        //
        //--------------------------------------------------------------------------

        //----------------------------------
        //  toolTip
        //----------------------------------

        /**
         *  @private
         */
        private var _explicitToolTip:Boolean = false;

        [Inspectable(category="General", defaultValue="null")]

        /**
         *  @private
         */ override public function set toolTip(value:String):void {
            super.toolTip = value;

            _explicitToolTip = value != null;
        }

        //--------------------------------------------------------------------------
        //
        //  Properties
        //
        //--------------------------------------------------------------------------

        private var _label:String;

        /**
         *  Text to appear on the on the border's Frame control.
         *
         *  <p>If the label is wider than the Frame control,
         *  the label is truncated and terminated by an ellipsis (...).
         *  The full label displays as a tooltip
         *  when the user moves the mouse over the control.
         *  If you have also set a tooltip by using the <code>tooltip</code>
         *  property, the tooltip is displayed rather than the label text.</p>
         *
         *  <p>This is the default Frame property.</p>
         *
         *  <p>This property is a <code>String</code> typed facade to the
         *  <code>content</code> property.  This property is bindable and it shares
         *  dispatching the "contentChange" event with the <code>content</code>
         *  property.</p>
         *
         *  @default ""
         *  @see #content
         *  @eventType contentChange
         *
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 1.5
         *  @productversion Flex 4
         */
        public function set label(value:String):void {
            // Push to the optional labelDisplay skin part

            _label = value;

            if (labelDisplay) {
                labelDisplay.text = _label;
            }

            dispatchEvent(new Event("labelChange"));
        }

        /**
         *  @private
         */
        public function get label():String {
            return _label;
        }

        public var showLabel:Boolean = true;

        //--------------------------------------------------------------------------
        //
        //  Overridden properties
        //
        //--------------------------------------------------------------------------

        /**
         *  @private
         */
        override protected function partAdded(partName:String, instance:Object):void {
            super.partAdded(partName, instance);

            if (instance == labelDisplay) {
                labelDisplay.addEventListener("isTruncatedChanged", labelDisplay_isTruncatedChangedHandler);

                // Push down to the part only if the label was explicitly set
                if (labelDisplay !== null) {
                    labelDisplay.text = label;
                }
            }
        }

        /**
         *  @private
         */
        override protected function partRemoved(partName:String, instance:Object):void {
            super.partRemoved(partName, instance);

            if (instance == labelDisplay) {
                labelDisplay.removeEventListener("isTruncatedChanged", labelDisplay_isTruncatedChangedHandler);
            }
        }

        /**
         *  @private
         */
        private function labelDisplay_isTruncatedChangedHandler(event:Event):void {

            if (_explicitToolTip) {
                return;
            }

            var isTruncated:Boolean = labelDisplay.isTruncated;

            // If the label is truncated, show the whole label string as a tooltip.
            // We set super.toolTip to avoid setting our own _explicitToolTip.
            super.toolTip = isTruncated ? labelDisplay.text : null;
        }
    }
}
