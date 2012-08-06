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
package spark.components.supportClasses
{
import mx.core.mx_internal;

import spark.components.Accordion;
import spark.components.AccordionContent;
import spark.events.ElementExistenceEvent;
import spark.layouts.HorizontalAlign;
import spark.layouts.VerticalLayout;

use namespace mx_internal;

/**
 *  When creating a vertical Accordion, use this layout in the Accordion's 
 *  skin within the <code>contentGroup</code>.
 * 
 *  <p>Do not set <code>horizontalAlign</code> in this layout. 
 *  Setting it will have no effect because the property is managed internally 
 *  in this layout.</p>
 * 
 *  @langversion 3.0
 *  @playerversion Flash 11
 *  @playerversion AIR 3.0
 *  @productversion Flex 5.0
 */
public class VerticalAccordionLayout extends VerticalLayout
{
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
    public function VerticalAccordionLayout()
    {
        super();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------   
    
    //----------------------------------
    //  accordion
    //----------------------------------
    
    /**
     *  @private
     *  The Accordion that owns this layout.
     */
    private function get accordion():Accordion
    {
        return target ? Accordion(Skin(target.parentDocument)["hostComponent"]) : null;
    } 
    
    //----------------------------------
    //  accordionHasSelection
    //----------------------------------   
    
    /**
     *  @private
     */     
    private function get accordionHasSelection():Boolean
    {
        return accordion && accordion.selectedElement;
    }
    
    //----------------------------------
    //  resizeToContent
    //----------------------------------   
    
    /**
     *  @private
     */     
    private function get resizeToContent():Boolean
    {
        return !accordion || accordion.resizeToContent;
    }
    
    //----------------------------------
    //  initialDimensions
    //----------------------------------
    
    /**
     *  @private
     *  If the Accordion does not define an explicitWidth or explicitHeight,
     *  the initial dimensions are set to the Accordion's dimensions the first 
     *  time an AccordionContent is selected.
     *  The dimensions never change after being set.
     */
    private var _initialWidth:Number;
    
    /**
     *  @private
     */
    private var _initialHeight:Number;
    
    /**
     *  @private
     */
    private var _initialMinWidth:Number;
    
    /**
     *  @private
     */
    private var _initialMinHeight:Number;
    
    /**
     *  @private
     */     
    private function get initialDimensionsSet():Boolean
    {
        // If one of the initial dimensions is set, they should all be set.
        return !isNaN(_initialWidth);
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden Properties
    //
    //--------------------------------------------------------------------------  
    
    /**
     *  @private
     */
    override public function get horizontalAlign():String
    {
        return resizeToContent ? HorizontalAlign.CONTENT_JUSTIFY : HorizontalAlign.JUSTIFY;
    }
    
    /**
     *  @private
     */
    override public function set target(value:GroupBase):void
    {
        if (target)
        {
            target.removeEventListener(ElementExistenceEvent.ELEMENT_ADD, accordion_elementAddHandler);
            target.removeEventListener(ElementExistenceEvent.ELEMENT_REMOVE, accordion_elementRemoveHandler);
        }
        
        super.target = value;
        
        if (target)
        {
            target.addEventListener(ElementExistenceEvent.ELEMENT_ADD, accordion_elementAddHandler);
            target.addEventListener(ElementExistenceEvent.ELEMENT_REMOVE, accordion_elementRemoveHandler);
        }
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  This method is only called when explicit dimensions are not set.
     *  There are two overall cases.
     *  When the Accordion is resizing to content, then VerticalLayout's
     *  measure method is sufficient.
     *  When the Accordion is not resizing to content, we may need to use
     *  or set the cached initial dimensions.
     */
    override public function measure():void
    {
        if (!resizeToContent && initialDimensionsSet)
        {
            target.measuredWidth = _initialWidth;
            target.measuredHeight = _initialHeight;
            target.measuredMinWidth = _initialMinWidth;
            target.measuredMinHeight = _initialMinHeight;
        }
        else if (!resizeToContent && accordionHasSelection)
        {
            super.measure();
            _initialWidth = target.measuredWidth;
            _initialHeight = target.measuredHeight;
            _initialMinWidth = target.measuredMinWidth;
            _initialMinHeight = target.measuredMinHeight;
        }
        else
        {
            super.measure();
        }
    }
    
    /**
     *  @private
     *  There are two overall cases.
     *  When the Accordion is resizing to content, then VerticalLayout's
     *  updateDisplayList method is sufficient.
     *  When the Accordion is not resizing to content, we may need to adjust
     *  the height of the single selected AccordionContent to make sure it
     *  doesn't hang out of the Accordion.
     *  Remember, when the Accordion is not resizing to content, there can be
     *  at most one selected AccordionContent.
     */
    override public function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    {
        super.updateDisplayList(unscaledWidth, unscaledHeight);
        
        if (resizeToContent)
            return;
        
        if (!accordion)
            return;
        
        var selectedAccordionContent:AccordionContent = AccordionContent(accordion.selectedElement);
        if (!selectedAccordionContent)
            return;
        
        var selectedAccordionContentIsAnimating:Boolean = !isNaN(selectedAccordionContent.explicitHeight);
        if (selectedAccordionContentIsAnimating)
            return;
        
        // Determine the total measured height of the Accordion without the selected AccordionContent.
        var numElements:int = accordion.numElements;
        var totalHeightWithoutSelection:Number = paddingTop + paddingBottom + (numElements - 1) * gap;
        for (var i:int = 0; i < numElements; i++)
        {
            if (i == accordion.selectedIndex)
                continue;
            
            var accordionContent:AccordionContent = AccordionContent(accordion.getElementAt(i));
            totalHeightWithoutSelection += accordionContent.measuredHeight;
        }
        
        // Determine how tall the selected AccordionContent should actually be.
        var selectionHeight:Number = Math.max(selectedAccordionContent.minHeight,
            unscaledHeight - totalHeightWithoutSelection);
        
        // Resize the selected AccordionContent to its new height.
        selectedAccordionContent.setLayoutBoundsSize(selectedAccordionContent.getLayoutBoundsWidth(),
            selectionHeight);
        
        // Reposition the AccordionContents after the selected AccordionContent.
        var yPosition:Number = selectedAccordionContent.getLayoutBoundsY() + selectionHeight + gap;
        for (i = accordion.selectedIndex + 1; i < numElements; i++)
        {
            accordionContent = AccordionContent(accordion.getElementAt(i));
            accordionContent.setLayoutBoundsPosition(accordionContent.getLayoutBoundsX(),
                yPosition);
            
            yPosition += accordionContent.getLayoutBoundsHeight() + gap;
        }
    }
    
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    private function clearInitialDimensions():void
    {
        _initialWidth = NaN;
        _initialHeight = NaN;
        _initialMinWidth = NaN;
        _initialMinHeight = NaN;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Event handlers
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */    
    private function accordion_elementAddHandler(event:ElementExistenceEvent):void
    {
        clearInitialDimensions();
    }   

    /**
     *  @private
     */
    private function accordion_elementRemoveHandler(event:ElementExistenceEvent):void
    {
        clearInitialDimensions();           
    }
} 
}