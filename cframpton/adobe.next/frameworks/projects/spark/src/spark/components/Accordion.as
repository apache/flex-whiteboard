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

package spark.components
{

import flash.display.DisplayObjectContainer;
import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.ui.Keyboard;

import mx.automation.IAutomationObject;
import mx.core.IDeferredInstance;
import mx.core.IVisualElement;
import mx.core.mx_internal;
import mx.events.FlexEvent;
import mx.managers.IFocusManagerComponent;

import spark.components.supportClasses.ToggleButtonBase;
import spark.events.ElementExistenceEvent;
import spark.events.IndexChangeEvent;
import spark.layouts.supportClasses.LayoutBase;

use namespace mx_internal;

//--------------------
//  Events
//--------------------

/**
 *  Dispatched when selected indices or selected index changes via 
 *  keyboard/mouse interaction.
 *
 *  @eventType spark.events.IndexChangeEvent.CHANGE
 *
 *  @langversion 3.0
 *  @playerversion Flash 11
 *  @playerversion AIR 3.0
 *  @productversion Flex 5.0
 */
[Event(name="change", type="spark.events.IndexChangeEvent")]

/**
 *  Dispatched when all indices are finished animating.
 *  If no animation occurred, this event will not be dispatched.
 *
 *  @eventType mx.events.FlexEvent.CHANGE_END
 *  
 *  @langversion 3.0
 *  @playerversion Flash 11
 *  @playerversion AIR 3.0
 *  @productversion Flex 5.0
 */
[Event(name="changeEnd", type="mx.events.FlexEvent")]

/**
 *  <p>A Spark Accordion component is a container with 
 *  children that are AccordionContents.
 *  Each AccordionContent has a header and its content. 
 *  Each of these AccordionContents can be either selected
 *  or unselected. When selected, both header and content is visible. 
 *  When unselected only the content's header appears. </p>
 *
 *  <p> Notes: </p>
 *  <p>Note that the children of the Accordion must be instances of 
 *  type AccordionContent. </p>
 *
 *  <p>There are two main types of Accordions. A Horizontal Accordion 
 *  and a Vertical Accordion. 
 *  In a Vertical Accordion, the contents are visually stacked on 
 *  top of each other and in each content, the header is above the contents.
 *  In a Horizontal Accordion they are stacked visually side by side where 
 *  the header is either to the left or right of the content.</p>
 *
 *  <p> To create an Horizontal Accordion set HorizontalAccordionSkin as the
 *  skin class of the Accordion and the HorizontalAccordionContentSkin
 *  as the skin class as each of the AccordionContents.
 *  To create a Vertical Accordion use the VerticalAccordionSkin and
 *  VerticalAccordionContentSkin.
 *  If you want to make a custom Accordion skin, it is recommended that you use 
 *  the VerticalAccordionLayout and HorizontalAccordionLayout in the 
 *  <code>contentGroup</code>.</p>
 *    
 *  <p>A child component may use deferred instantiation if it implements 
 *  <code>IDeferredContentOwner</code>. When a child's creationPolicy is "auto" 
 *  or "none" is does not create its children. 
 *  Later, when a child component becomes visible, Accordion will call the child's 
 *  <code>createDeferredContent</code> method to create the child's children.</p>
 *
 *  <p>The Accordion provides user interaction through mouse or keyboard. 
 *  One can select or unselect an Accordion by clicking on the headers. 
 *  See specification for full list of keyboard controls. </p>
 *
 *  <p>The Spark Accordion allows multiple AccordionContents to be open at the 
 *  same time when the <code>allowMultipleSelection</code> property is 
 *  <code>true</code>.</p>
 * 
 *  <p>The Spark Accordion can be set to require at least one AccordionContent
 *  be selected at all times by setting the <code>selectionRequired</code> 
 *  property to <code>false</code>.</p>
 *
 *  <p>The Accordion has two main modes of laying out its contents. 
 *  When the <code>resizeToContent</code> property is <code>true</code>, 
 *  the Accordion resizes to the size of its open contents.
 *  When it is <code>false</code> it remains at a fixed size. 
 *  In addition when the property is <code>false</code>, at most one 
 *  AccordionContent can be selected at a time (<code>allowMultipleSelection</code>
 *  is set to <code>false</code>. </p>
 *
 *  <p>By default the Accordion is a Vertical Accordion. 
 *  The <code>resizeToContent</code> property is <code>false</code>, forcing 
 *  <code>allowMultipleSelection</code> to be <code>false</code>.
 *  The Accordion is sized to fit the size of the first selected AccordionContent 
 *  and the headers of the other AccordionContents. 
 *  The <code>selectionRequired</code> property is <code>true</code>.</p>
 *
 *  @langversion 3.0
 *  @playerversion Flash 11
 *  @playerversion AIR 3.0
 *  @productversion Flex 5.0 
 */ 
public class Accordion extends SkinnableContainer implements IFocusManagerComponent
{
    include "../core/Version.as";
    
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
    public function Accordion()
    {
        super();
        
        addEventListener(ElementExistenceEvent.ELEMENT_ADD, elementAddHandler);
        addEventListener(ElementExistenceEvent.ELEMENT_REMOVE, elementRemoveHandler);
        
        focusEnabled = true;
        hasFocusableChildren = true;

        // Set up accordion selection. requireSeletion must be set after accordionSelection.
        accordionSelection = new AccordionSelection(findFirstSelectableIndex);
        requireSelection = true;

        // Set up caret selection.
        caretSelection = new AccordionSelection(findDefaultFocusableIndex);
        deferredCaretSelectionFunction = function():void {
            caretSelection.setRequireSelection(true);
        };
        invalidateProperties();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  The object used to track accordion selection.
     */
    private var accordionSelection:AccordionSelection;
    
    [Bindable(event="caretChange")]
    
    /**
     *  @private
     *  The caret index is exposed as mx_internal to simplify test automation.
     */
    mx_internal function get caretIndex():int
    {
        return caretSelection.selectedIndex;
    }
    
    /**
     *  @private
     */
    private var caretSelection:AccordionSelection;
    
    /**
     *  @private
     */
    private var deferredRequireSelectionFunction:Function;
    
    /**
     *  @private
     */
    private var deferredSelectionFunction:Function;
    
    /**
     *  @private
     */
    private var deferredCaretSelectionFunction:Function;

    /**
     *  @private
     */
    private function get focused():Boolean
    {
        return focusManager.getFocus() == this;    
    }
    
    /**
     *  @private
     */
    private var focusChangedByKeyboard:Boolean = false;
    
    /**
     *  @private
     */
    private var _showCaret:Boolean = false;
    
    private function get showCaret():Boolean
    {
        return _showCaret;
    }
    
    private function set showCaret(value:Boolean):void
    {
        _showCaret = value;
        invalidateProperties();
    }
    
    /**
     *  @private
     */
    private var needToInstantiateSelectedChildren:Boolean = false;
    
    /**
     *  @private
     */
    private function get validSelection():Boolean
    {
        return isValidIndex(selectedIndex);
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden properties
    //
    //--------------------------------------------------------------------------
    
    override public function set owner(value:DisplayObjectContainer):void
    {
        if (owner)
        {
            owner.removeEventListener(FocusEvent.KEY_FOCUS_CHANGE, keyFocusChangeHandler);
            owner.removeEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, mouseFocusChangeHandler);
        }
        
        super.owner = value;
        
        if (owner)
        {
            owner.addEventListener(FocusEvent.KEY_FOCUS_CHANGE, keyFocusChangeHandler);
            owner.addEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, mouseFocusChangeHandler);
        }
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Whether a selection operation must be deferred.
     *  Wait until children are created, using initialized as a
     *  heuristic.
     */
    private function get deferSelection():Boolean 
    {
        return !initialized;
    }
    
    /**
     *  @private
     *  Returns true if any of the AccordionContents are currently animating.
     */
    mx_internal function get isAnimating():Boolean
    {
        for (var i:int = 0; i < numElements; i++)
        {
            var accordionContent:AccordionContent = AccordionContent(getElementAt(i));
            if (accordionContent.isAnimating)
                return true;
        }
        return false;
    }
    
    //----------------------
    // resizeToContent
    //----------------------
    
    /**
     *  @private
     */
    private var _resizeToContent:Boolean = false;
    
    /**
     *  <p>If <code>true</code>, the Accordion component automatically
     *  resizes to the size of its currently selected children.</p>
     * 
     *  <p>When <code>resizeToContent</code> is <code>false</code>, the Accordion will 
     *  remain at a fixed size determined by the size of the first ever open AccordionContent, 
     *  or if given, the explicit dimensions. In addition, <code>allowMultipleSelection</code>
     *  will always be false.</p>
     * 
     *  <p>When <code>resizeToContent</code> is <code>true</code>, it is recommended
     *  that the Accordion only resize along its primary axis for smooth animation.
     *  For example, in a vertical Accordion, the AccordionContent elements should
     *  only vary in height, and share the same width value. 
     *  Likewise, in a horizontal Accordion, the AccordionContent elements should
     *  only vary in width, and share the same height value.</p>
     *
     *  @default false
     * 
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5.0
     */
    public function get resizeToContent():Boolean
    {
        return _resizeToContent;
    }
    
    /**
     *  @private
     */
    public function set resizeToContent(value:Boolean):void
    {
        if (value == _resizeToContent)
            return;
        
        _resizeToContent = value;
        
        invalidateSize();
        invalidateDisplayList();
    }
    
    //---------------------------
    // requireSelection
    //---------------------------
    
    /**         
     *  <p>If <code>true</code> at least one AccordionContent
     *  must be selected at all times.</p>
     *
     *  @default "true"
     * 
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5.0
     */
    public function get requireSelection():Boolean
    {
        return accordionSelection.requireSelection;
    }
    
    /**
     *  @private
     */
    public function set requireSelection(value:Boolean):void
    {
        if (deferSelection) 
        {
            deferredRequireSelectionFunction = function():void {
                setRequireSelection(value);
            };
            invalidateProperties();
        } 
        else 
        {
            setRequireSelection(value);
        }
    }
    
    //----------------------------------
    //  selectedElement
    //----------------------------------
    
    [Bindable("valueCommit")]
    
    /**
     *  A reference to a currently selected child element.
     *  If there are no children, this property is <code>null</code>.
     * 
     *  <p><strong>Note:</strong> You can only set this property in an
     *  ActionScript statement, not in MXML.</p>
     *  
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5.0
     */
    public function get selectedElement():IVisualElement
    {
        if (!validSelection)
            return null;
        
        return getElementAt(selectedIndex);
    }
    
    /**
     *  @private
     * 
     *  Null value clears selection.
     *  Not-null value that is not in the Accordion is ignored.
     *  Otherwise, sets the selected element.
     */
    public function set selectedElement(value:IVisualElement):void
    {
        if (deferSelection) 
        {
            deferredSelectionFunction = function():void {
                setSelectedElement(value);
            };
            invalidateProperties();
        } 
        else 
        {
            setSelectedElement(value);
        }
    }
    
    //----------------------------------
    //  selectedIndex
    //----------------------------------
    
    [Bindable("valueCommit")]
    
    /**
     *  The index of the currently selected AccordionContent.
     *
     *  @default "-1"
     * 
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5.0
     */
    public function get selectedIndex():int
    {
        var indices:Vector.<int> = accordionSelection.selectedIndices;
        if (indices.length < 1)
            return -1;
        return indices[0];
    }
    
    /**
     *  @private
     * 
     *  -1 clears the selection.
     *  Any other out of range value is ignored.
     *  Valid values change the selection.
     */
    public function set selectedIndex(value:int):void
    {
        if (deferSelection) 
        {
            deferredSelectionFunction = function():void {
                setSelectedIndex(value);
            };
            invalidateProperties();
        } 
        else 
        {
            setSelectedIndex(value);
        }
    }
    
    
    [InstanceType("Array")]
    [ArrayElementType("spark.components.AccordionContent")]
    
    
    /**
     *  @private
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4 
     */
    override public function set mxmlContentFactory(value:IDeferredInstance):void
    {
        super.mxmlContentFactory = value;
    }
    
    
    [ArrayElementType("spark.components.AccordionContent")]
    
    /**
     *  @private
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4 
     */
    override public function set mxmlContent(value:Array):void
    {
        super.mxmlContent = value;
    }
    
    
    /**
     *  @private
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4 
     */
    override public function set layout(value:LayoutBase):void
    {
        super.layout = value;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods: UIComponent
    //
    //--------------------------------------------------------------------------
    
    override public function drawFocus(isFocused:Boolean):void
    {
        // Clear the focus rectangle from all headers.
        var numAccordionContents:int = numElements;
        for (var i:int = 0; i < numAccordionContents; i++)
        {
            var accordionContent:AccordionContent = getAccordionContentAt(i);
            accordionContent.depth = 0;

            var accordionHeader:ToggleButtonBase = accordionContent.accordionHeader;
            if (accordionHeader)
            {
                accordionHeader.drawFocusAnyway = false;
                accordionHeader.drawFocus(false);
            }
        }
        
        // Draw the focus rectangle on the caret index header.
        var caretAccordionContent:AccordionContent = getAccordionContentAt(caretSelection.selectedIndex);
        if (!caretAccordionContent)
            return;
        
        caretAccordionContent.depth = 1;
        
        var caretAccordionHeader:ToggleButtonBase = caretAccordionContent.accordionHeader;
        if (caretAccordionHeader)
        {
            caretAccordionHeader.drawFocusAnyway = isFocused;
            caretAccordionHeader.drawFocus(isFocused);
        }
    }
    
    /**
     *  @private
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4 
     */
    override protected function commitProperties():void
    {
        super.commitProperties();
        
        if (deferredRequireSelectionFunction != null)
        {
            deferredRequireSelectionFunction();
            deferredRequireSelectionFunction = null;
        }
        
        if (deferredSelectionFunction != null)
        {
            deferredSelectionFunction();
            deferredSelectionFunction = null;
        }
        
        if (deferredCaretSelectionFunction != null)
        {
            deferredCaretSelectionFunction();
            deferredCaretSelectionFunction = null;
        }
        
        updateSelectedStateOfChildren(accordionSelection.selectedIndices);
        
        drawFocus(focused && showCaret);
    }
    
    /**
     *  @private
     *  
     *  Ignores any elements that are not of type AccordionContent.
     *
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5.0
     */
    override public function addElement(element:IVisualElement):IVisualElement
    {
        var accordionContent:AccordionContent = element as AccordionContent;
        if (!accordionContent)
            return null;
        
        var addedElement:IVisualElement = super.addElement(accordionContent);
        if (!addedElement)
            return null;
        
        var index:int = getElementIndex(accordionContent);
        adjustIndicesFromAddition(index, accordionContent.selected);
        
        return accordionContent;
    }
    
    /**
     *  @private
     * 
     *  Ignores elements that are not of type AccordionContent.
     *
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5.0
     */
    override public function addElementAt(element:IVisualElement, index:int):IVisualElement
    {
        var accordionContent:AccordionContent = element as AccordionContent;
        if (!accordionContent)
            return null;
        
        var addedElement:IVisualElement = super.addElementAt(element, index);
        if (!addedElement)
            return null;
        
        adjustIndicesFromAddition(index, accordionContent.selected);
        
        return addedElement;
    }
    
    /**
     *  @private
     *
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5.0
     */
    override public function removeElement(element:IVisualElement):IVisualElement
    {
        var index:int = getElementIndex(element);
        var removedElement:IVisualElement = super.removeElement(element);
        if (!removedElement)
            return null;
        
        adjustIndicesFromRemoval(index);
        
        return removedElement;
    }
    
    /**
     *  @private
     *
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5.0
     */
    override public function removeElementAt(index:int):IVisualElement
    {
        var removedElement:IVisualElement = super.removeElementAt(index);
        if (!removedElement)
            return null;
        
        adjustIndicesFromRemoval(index);
        
        return removedElement;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    private function isValidIndex(index:int):Boolean
    {
        return index >= 0 && index < numElements;
    }
    
    /**
     *  @private
     */     
    private function getAccordionContentAt(index:int):AccordionContent
    {
        return isValidIndex(index) ? AccordionContent(getElementAt(index)) : null;
    }
    
    /**
     *  @private
     */
    private function getAccordionContentIndex(accordionContent:AccordionContent):int
    {
        var numAccordionContents:int = numElements;
        for (var i:int = 0; i < numAccordionContents; i++)
        {
            if (getAccordionContentAt(i) == accordionContent)
                return i;
        }
        return -1;
    }
    
    /**
     *  @private
     */     
    private function getAccordionHeaderAt(index:int):ToggleButtonBase
    {
        var accordionContent:AccordionContent = getAccordionContentAt(index);
        return accordionContent ? accordionContent.accordionHeader : null;
    }
    
    /**
     *  @private
     * 
     *  Update the <code>selected</code> state of the AccordionContent.
     * 
     *  @param indices Indices of selected children
     */
    private function updateSelectedStateOfChildren(indices:Vector.<int>):void
    {
        // Loop thru children, setting their selected state.
        // Only one child can be selected at a time, the rest
        // are unselected.
        for (var i:int = 0; i < numElements; i++)
        {
            var accordionContent:AccordionContent = getAccordionContentAt(i);
            var selected:Boolean = indices.indexOf(i) >= 0;
            accordionContent.selected = selected;
        }
    }
    
    /**
     *  @private
     * 
     *  -1 clears the selection.
     *  Any other invalid index is ignored.
     *  Otherwise, sets the currently selected index.
     */
    private function setSelectedIndex(value:int):void 
    {
        var selectionChanged:Boolean = false;
        
        if (value == -1)
            selectionChanged = accordionSelection.removeAll();
        else if (isValidIndex(value))
            selectionChanged = accordionSelection.setSelectedIndex(value);       
        
        if (selectionChanged) 
        {
            invalidateProperties();
            dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
        }
    }
    
    /**
     *  @private
     */
    private function setSelectedElement(element:IVisualElement):void
    {
        var selectionChanged:Boolean = false;
        var newIndex:int = getAccordionContentIndex(element as AccordionContent);
        
        if (!element)
            selectionChanged = accordionSelection.removeAll();
        else if (isValidIndex(newIndex))
            selectionChanged = accordionSelection.setSelectedIndex(newIndex);       
        
        if (selectionChanged) 
        {
            invalidateProperties();
            dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
        }
    }
    
    /**
     *  @private
     *  Sets whether selection is required. Setting it to
     *  true may cause the selection to change
     */
    private function setRequireSelection(value:Boolean):Boolean 
    {
        const selectionChanged:Boolean = accordionSelection.setRequireSelection(value);
        if (selectionChanged) 
        {
            invalidateProperties();
            dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
        }
        return selectionChanged;
    }
    
    /**
     *  @private
     */
    private function isFocusable(accordionContent:AccordionContent):Boolean
    {
        return accordionContent.enabled && accordionContent.accordionHeader;
    }
    
    /**
     *  @private
     *  
     *  Finds the first enabled element in the Accordion.
     */
    private function findFirstEnabledElement():int
    {
        var numAccordionContents:int = numElements;
        for (var i:int = 0; i < numAccordionContents; i++)
        {
            if (getAccordionContentAt(i).enabled)
                return i;
        }
        return -1;
    }
    
    /**
     *  @private
     * 
     *  Used by AccordionSelection when requireSelection is true.
     */
    private function findFirstSelectableIndex():int 
    {
        return findFirstEnabledElement();
    }
    
    /**
     *  @private
     */
    private function wrapIndex(index:int, max:int):int
    {
        var wrappedIndex:int = index % max;
        return wrappedIndex >= 0 ? wrappedIndex : max + wrappedIndex;
    }
    
    /**
     *  @private
     * 
     *  Finds the next index starting at focusedIndex that corresponds to an
     *  AccordionContent that is enabled and has a header.
     */
    private function findFirstFocusableIndex(startIndex:int, forward:Boolean):int
    {
        var currentIndex:int = startIndex;
        var numAccordionContents:int = numElements;
        for (var i:int = 0; i < numAccordionContents; i++)
        {
            var wrappedIndex:int = wrapIndex(currentIndex, numAccordionContents);
            
            if (isFocusable(getAccordionContentAt(wrappedIndex)))
                return wrappedIndex;
            
            if (forward)
                currentIndex++;
            else
                currentIndex--;
        }
        return -1;
    }
    
    /**
     *  @private
     */
    private function findDefaultFocusableIndex():int
    {
        if (validSelection)
            return selectedIndex;
        else if (numElements > 0)
            return findFirstFocusableIndex(0, true);
        else
            return -1;
    }
    
    /**
     *  @private
     *  If an element was added, adjust the selection and notify listeners.
     *  Pass in true for the selected argument if the index we are adding should
     *  be selected.
     *  invalidateSize and invalidateDisplayList are called as part of adding or
     *  removing an element from a group.
     *  Selection may have changed, so we need to invalidate properties as well.
     */
    private function adjustIndicesFromAddition(index:int, selected:Boolean):void
    {
        // Adjust selection.
        var selectionChanged:Boolean = accordionSelection.indexAdded(index);
        
        if (selected)
            selectionChanged = accordionSelection.setSelectedIndex(index) || selectionChanged;
        
        if (selectionChanged && hasEventListener(FlexEvent.VALUE_COMMIT))
            dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
            
        // Adjust caret.
        var caretChanged:Boolean = caretSelection.indexAdded(index);
        if (caretChanged && hasEventListener("caretChange"))
            dispatchEvent(new Event("caretChange"));
        
        invalidateProperties();
    }
    
    /**
     *  @private
     *  If an element was removed, adjust the selection and notify listeners 
     *  accordingly.
     */
    private function adjustIndicesFromRemoval(index:int):void
    {
        // Adjust selection.
        var selectionChanged:Boolean = accordionSelection.indexRemoved(index);
        
        if (selectionChanged && hasEventListener(FlexEvent.VALUE_COMMIT))
            dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
         
        // Adjust caret.
        var caretChanged:Boolean = caretSelection.indexRemoved(index);
        if (caretChanged && hasEventListener("caretChange"))
            dispatchEvent(new Event("caretChange"));
        
        invalidateProperties();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden event handlers
    //
    //--------------------------------------------------------------------------
    
    override protected function focusInHandler(event:FocusEvent):void
    {
        showCaret = focusChangedByKeyboard ? focused : false;

        super.focusInHandler(event);
    }
    
    //--------------------------------------------------------------------------
    //
    //  Event handlers
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  MXML addition will not go through addElement() or addElementAt(), but it
     *  will go through this handler.
     */
    private function elementAddHandler(event:ElementExistenceEvent):void
    {
        var accordionContent:AccordionContent = AccordionContent(event.element);
        if (accordionContent is IAutomationObject)
            IAutomationObject(accordionContent).showInAutomationHierarchy = true;
        
        accordionContent.addEventListener(MouseEvent.CLICK, accordionContent_mouseClickHandler);
    }
    
    /**
     *  @private
     */
    private function elementRemoveHandler(event:ElementExistenceEvent):void
    {
        var accordionContent:AccordionContent = AccordionContent(event.element);
        
        accordionContent.removeEventListener(MouseEvent.CLICK, accordionContent_mouseClickHandler);
    }    
    
    /**
     *  @private
     */
    private function accordionContent_mouseClickHandler(event:MouseEvent):void
    {
        var content:AccordionContent = AccordionContent(event.currentTarget);
        var index:int = getElementIndex(content);
        if (event.target == content.accordionHeader) 
        {
            var selectionKind:String = selectedIndex == index ? AccordionSelectionEventKind.CLEAR_SELECTION : AccordionSelectionEventKind.SET_INDEX;
            commitInteractiveSelection(selectionKind, selectedIndex, index);
            commitMouseCaretChange(index);
        }
    }    
    
    /**
     *  @private
     *  Bottle-neck for changing selection due to user interaction
     *  Currently supports only single selection
     *  See DataGrid.commitInteractiveSelection for a more elaborate version
     */
    private function commitInteractiveSelection(selectionEventKind:String, oldIndex:int, newIndex:int):Boolean 
    {
        var changed:Boolean = false;
        
        switch (selectionEventKind) 
        {
            case AccordionSelectionEventKind.SET_INDEX:
            {
                changed = accordionSelection.setSelectedIndex(newIndex);
                break;
            }
                
            case AccordionSelectionEventKind.CLEAR_SELECTION:
            {
                changed = accordionSelection.removeAll();
                break;
            }
        }
        
        if (changed) 
        {
            // use selectedIndex rather than newIndex, in case requiredSelection altered things
            var ice:IndexChangeEvent = new IndexChangeEvent(IndexChangeEvent.CHANGE, false, false, oldIndex, selectedIndex);
            if (hasEventListener(IndexChangeEvent.CHANGE))
                dispatchEvent(ice);
            if (hasEventListener(FlexEvent.VALUE_COMMIT))
                dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
            invalidateProperties();
        }
        
        return changed;
    }
    
    /**
     *  @private
     */
    private function commitKeyboardCaretChange(event:KeyboardEvent, newCaretIndex:int):void
    {
        event.preventDefault();

        setFocus();        
        showCaret = focused;
        
        var caretChanged:Boolean = caretSelection.setSelectedIndex(newCaretIndex);
        if (caretChanged && hasEventListener("caretChange"))
            dispatchEvent(new Event("caretChange"));
    }
    
    /**
     *  @private
     */
    private function commitMouseCaretChange(newCaretIndex:int):void
    {
        showCaret = false;

        var caretChanged:Boolean = caretSelection.setSelectedIndex(newCaretIndex);
        if (caretChanged && hasEventListener("caretChange"))
            dispatchEvent(new Event("caretChange"));
    }
    
    /**
     *  @private
     */    
    private function keyFocusChangeHandler(event:FocusEvent):void
    {
        focusChangedByKeyboard = true;
    }
    
    /**
     *  @private
     */    
    private function mouseFocusChangeHandler(event:FocusEvent):void
    {
        focusChangedByKeyboard = false;
    }
    
    /**
     *  @private
     *  Handles "keyDown" event.
     */
    override protected function keyDownHandler(event:KeyboardEvent):void
    {
        var keyCode:uint = mapKeycodeForLayoutDirection(event);
        var caretIndex:int = caretSelection.selectedIndex;
        
        switch (keyCode)
        {
            case Keyboard.PAGE_DOWN:
            {
                if (event.ctrlKey && !focused)
                    commitKeyboardCaretChange(event, findFirstFocusableIndex(caretIndex + 1, true));
                break;
            }
                
            case Keyboard.PAGE_UP:
            {
                if (event.ctrlKey && !focused)
                    commitKeyboardCaretChange(event, findFirstFocusableIndex(caretIndex - 1, false));
                break;
            }
                
            case Keyboard.HOME:
            {
                commitKeyboardCaretChange(event, findFirstFocusableIndex(0, true));
                break;
            }
                
            case Keyboard.END:
            {
                commitKeyboardCaretChange(event, findFirstFocusableIndex(numElements - 1, false));
                break;
            }
                
            case Keyboard.DOWN:
            case Keyboard.RIGHT:
            {
                if (focused)
                    commitKeyboardCaretChange(event, findFirstFocusableIndex(caretIndex + 1, true));
                break;
            }
                
            case Keyboard.UP:
            case Keyboard.LEFT:
            {
                if (focused)
                    commitKeyboardCaretChange(event, findFirstFocusableIndex(caretIndex - 1, false));
                else if (event.ctrlKey)
                    commitKeyboardCaretChange(event, caretIndex);
                break;
            }
                
            case Keyboard.ENTER:
            case Keyboard.SPACE:
            {
                if (!focused)
                    break;

                var selectionKind:String = (selectedIndex == caretIndex) ? 
                    AccordionSelectionEventKind.CLEAR_SELECTION : AccordionSelectionEventKind.SET_INDEX;
                
                commitInteractiveSelection(selectionKind, selectedIndex, caretIndex);
                commitKeyboardCaretChange(event, caretIndex);                
                
                break;
            }
                
            default:
            {
                if (!focused)
                    break;
                
                var typedCode:String = String.fromCharCode(keyCode).toLowerCase();
                for (var i:int = 1; i <= numElements; i++)
                {
                    var index:int = (caretIndex + i) % numElements
                    var accordionContent:AccordionContent = getAccordionContentAt(index);
                    
                    var labelCode:String;
                    if (accordionContent.label && accordionContent.label.length > 0)
                        labelCode = accordionContent.label.charAt(0).toLowerCase();
                    
                    if (typedCode == labelCode && isFocusable(accordionContent))
                    {
                        commitKeyboardCaretChange(event, index);
                        break;
                    }
                }
                break;
            }
        }
    }
}

}

import mx.core.mx_internal;

import spark.components.Accordion;

use namespace mx_internal;

/**
 *  A helper class for managing Accordion's selection, as a vector of
 *  selected indices. Currently only supports single selection. Methods
 *  return true if selection changed as a result of the operation.
 */
class AccordionSelection 
{
    /**
     *  Constructor
     */
    public function AccordionSelection(findFirstSelectableIndexFunction:Function) 
    {
        this.findFirstSelectableIndexFunction = findFirstSelectableIndexFunction;
    }
    
    /**
     *  The accordion whose selection we are managing
     */   
    private var findFirstSelectableIndexFunction:Function;
    
    /**
     *  Whether to require a selection, if one is possible
     */
    private var _requireSelection:Boolean;
    public function get requireSelection():Boolean 
    {
        return _requireSelection;
    }
    
    public function setRequireSelection(value:Boolean):Boolean 
    {
        if (value == _requireSelection)
            return false;
        _requireSelection = value;
        if (_requireSelection)
            return ensureMatchesRequiredSelection();
        return false;
    }
    
    /**
     *  The selected indices. This can currently only be of length
     *  less than or equal to 1.
     */
    private var _selectedIndices:Vector.<int> = new Vector.<int>();
    public function get selectedIndices():Vector.<int> 
    {
        return _selectedIndices;
    }
    
    public function get selectedIndex():int
    {
        return _selectedIndices.length > 0 ? _selectedIndices[0] : -1;
    }
    
    /**
     *  Sets the selected index. Returns true if the selection changed.
     */ 
    public function setSelectedIndex(value:int):Boolean 
    {
        if (_selectedIndices.length == 1 && _selectedIndices[0] == value)
            return false;
        _selectedIndices.length = 0;
        if (value >= 0) 
        {
            _selectedIndices.push(value);
            return true;
        } 
        else 
        {
            return ensureMatchesRequiredSelection();
        }
    }
    
    /**
     *  Make sure an element is selected, if requireSelection is true
     */
    private function ensureMatchesRequiredSelection():Boolean 
    {
        if (_selectedIndices.length == 0 && _requireSelection) 
        {
            var index:int = findFirstSelectableIndexFunction();
            if (index >= 0) 
            {
                _selectedIndices.push(index);
                return true;
            }
        }
        return false;
    }
    
    /**
     *  Clears the selection
     *  We do not call ensureRequireSelection, as we skip removal
     *  if an element is already selected
     */
    public function removeAll():Boolean 
    {
        if (_selectedIndices.length == 0)
            return false;
        if (_selectedIndices.length == 1 && requireSelection)
            return false;
        _selectedIndices.length = 0;
        return true;
    }
    
    /**
     *  Remove the index from the selection
     */
    private function removeIndex(value:int):Boolean 
    {
        var index:int = _selectedIndices.indexOf(value);
        if (index < 0)
            return false;
        _selectedIndices.splice(index, 1);
        return true;
    }
    
    /**
     *  Call this when an element with the given index has
     *  been removed from the accordion
     */
    public function indexRemoved(value:int):Boolean 
    {
        var altered:Boolean = removeIndex(value);
        for (var i:int = 0; i < _selectedIndices.length; i++)
        {
            if (_selectedIndices[i] >= value) 
            {
                _selectedIndices[i]--;
                altered = true;
            }
        }
        return ensureMatchesRequiredSelection() || altered;
    }
    
    /**
     *  Call this when an element with the given index
     *  has been added to the accordion
     */
    public function indexAdded(value:int):Boolean 
    {
        var altered:Boolean = false;
        for (var i:int = 0; i < _selectedIndices.length; i++)
        {
            if (_selectedIndices[i] >= value) 
            {
                _selectedIndices[i]++;
                altered = true;
            }
        }
        return ensureMatchesRequiredSelection() || altered;
    }
}

/**
 *  Constants representing different kinds of selection
 *  events.
 */
class AccordionSelectionEventKind 
{
    public static const SET_INDEX:String = "setIndex";
    public static const CLEAR_SELECTION:String = "clearSelection";
}