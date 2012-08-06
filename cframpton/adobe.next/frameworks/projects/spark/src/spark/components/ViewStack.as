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

import flash.display.DisplayObject;
import flash.events.Event;
import flash.utils.Dictionary;

import mx.automation.IAutomationObject;
import mx.core.IDeferredContentOwner;
import mx.core.IFactory;
import mx.core.IInvalidating;
import mx.core.INavigatorContent;
import mx.core.ISelectableList;
import mx.core.IUIComponent;
import mx.core.IVisualElement;
import mx.core.IVisualElementContainer;
import mx.core.UIComponent;
import mx.core.mx_internal;
import mx.effects.Effect;
import mx.effects.EffectManager;
import mx.effects.IEffect;
import mx.events.CollectionEvent;
import mx.events.CollectionEventKind;
import mx.events.EffectEvent;
import mx.events.FlexEvent;
import mx.events.PropertyChangeEvent;
import mx.geom.RoundedRectangle;
import mx.states.Transition;

import spark.components.supportClasses.ViewStackLayout;
import spark.core.ContainerDestructionPolicy;
import spark.events.ElementExistenceEvent;
import spark.events.IndexChangeEvent;
import spark.layouts.supportClasses.LayoutBase;


use namespace mx_internal;

//--------------------------------------
//  Events
//--------------------------------------

/**
 *  Dispatched when the selected child container changes.
 *
 *  @eventType spark.events.IndexChangeEvent.CHANGE
 *  
 *  @langversion 3.0
 *  @playerversion Flash 11
 *  @playerversion AIR 3.0
 *  @productversion Flex 5.0
 */
[Event(name="change", type="spark.events.IndexChangeEvent")]

//--------------------------------------
//  Other metadata
//--------------------------------------

[IconFile("ViewStack.png")]

[Exclude(name="layout", kind="property")]

/**
 *  A Spark ViewStack component consists of a collection of child
 *  components stacked on top of each other, where only one child is visible
 *  at a time.
 *  When a different child component is selected, it seems to replace
 *  the old one because it appears in the same location.
 *  However, the old child component still exists; it is just invisible.
 * 
 *  <p><b>Notes:</b> 
 *  The direct children of ViewStack must implement the IVisualElement
 *  interface. The <code>NavigatorContent</code> component is the recommended 
 *  child component to use with ViewStack.</p>

 *  <p>A child component may use deferred instantiation if it implements 
 *  <code>IDeferredContentOwner</code>. When a child's creationPolicy is "auto"
 *  or "none" is does not create its children. Later, when a child component becomes
 *  visible, ViewStack will call the child's <code>createDeferredContent</code>
 *  method to create the child's children. </p>
 *
 *  <p>A ViewStack container does not provide a user interface
 *  for selecting which child container is currently visible.
 *  Typically, you set its <code>selectedIndex</code> or
 *  <code>selectedElement</code> property in ActionScript in response to
 *  some user action. 
 *  Alternately, you can associate a Spark TabBar or ButtonBar with a ViewStack 
 *  component to provide a navigation interface.
 *  To do so, specify the ViewStack component as the value of the
 *  <code>dataProvider</code> property of the TabBar or
 *  ButtonBar component.</p>
 *
 *  To play an effect that provides a transition from one selected component
 *  to the next override the <code>showSelectedElement</code> method. The 
 *  default implementation of <code>showSelectedElement</code> is to hide the 
 *  previously selected element and show the newly selected element.
 *
 *  <p>The ViewStack container has the following default sizing characteristics:</p>
 *     <table class="innertable">
 *        <tr>
 *           <th>Characteristic</th>
 *           <th>Description</th>
 *        </tr>
 *        <tr>
 *           <td>Default size</td>
 *           <td>The width and height of the initial selected child.</td>
 *        </tr>
 *        <tr>
 *           <td>Container resizing rules</td>
 *           <td>By default, ViewStack components are sized only once to fit the size of the 
 *               first selected child. They do not resize when you navigate to another child.
 *               To force ViewStack containers to resize when you navigate 
 *               to a different child, set the <code>resizeToContent</code> property to true.</td>
 *        </tr>
 *        <tr>
 *           <td>Child sizing rules</td>
 *           <td>Children are sized to their default size. If the child is larger than the ViewStack 
 *               container, it is clipped. If the child is smaller than the ViewStack container, 
 *               it is aligned to the upper-left corner of the ViewStack container.</td>
 *        </tr>
 *     </table>
 * 
 *  @mxml
 *
 *  <p>The <code>&lt;s:ViewStack&gt;</code> tag inherits the
 *  tag attributes of its superclass and adds the following tag attributes:</p>
 *
 *  <pre>
 *  &lt;s:ViewStack
 *    <b>Properties</b>
 *    resizeToContent="false|true"
 *    lastSelectedIndex="-1"
 *    selectedIndex="0"
 *    
 *    <b>Events</b>
 *    change="<i>No default</i>"
 *    &gt;
 *      ...
 *      <i>child tags</i>
 *      ...
 *  &lt;/s:ViewStack&gt;
 *  </pre>
 *
 *  @see spark.components.TabBar
 *  @see spark.components.ButtonBar
 *  
 *  @langversion 3.0
 *  @playerversion Flash 11
 *  @playerversion AIR 3.0
 *  @productversion Flex 5.0
 */
public class ViewStack extends SkinnableContainer implements ISelectableList
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
    public function ViewStack()
    {
        super();
        
        super.layout = new ViewStackLayout();
        
        addEventListener(ElementExistenceEvent.ELEMENT_ADD, elementAddHandler);
        addEventListener(ElementExistenceEvent.ELEMENT_REMOVE, elementRemoveHandler);
    }
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  If we're in the middle of adding a child
     */
    private var addingChildren:Boolean = false;
    
    /**
     *  @private
     *  Remember which child has an overlay mask, if any.
     *  Used for the dissolve effect.
     */
    private var effectOverlayChild:UIComponent;
    
    /**
     *  @private
     *  Keep track of the overlay's targetArea
     *  Used for the dissolve effect.
     */
    private var effectOverlayTargetArea:RoundedRectangle;
    
    /**
     *  @private
     *  Whether a change event has to be dispatched in commitProperties()
     */
    private var dispatchChangeEventPending:Boolean = false;
    
    /**
     *  @private
     *  Store the last selectedIndex
     */
    private var lastSelectedIndex:int = -1;
    
    /**
     *  @private
     */
    private var needToInstantiateSelectedChild:Boolean = false;
    
    /**
     *  @private
     *  True if resizeToConent was changed. This means we need to update the
     *  layout with the new value.
     */
    private var resizeToContentChanged:Boolean = false;
    
    //--------------------------------------------------------------------------
    //
    //  Overridden properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  autoLayout
    //----------------------------------
    
    /**
     *  The <code>autoLayout</code> property have been overriden to always 
     *  return <code>true</code>. It cannot be set to <code>false</code>.
     */
    override public function get autoLayout():Boolean
    {
        return true;
    }
    
    /**
     *  @private
     *  autoLayout is always true for ViewStack
     *  and can't be changed by this setter.
     *
     *  We can probably find a way to make autoLayout work with Accordion
     *  and ViewStack, but right now there are problems if deferred
     *  instantiation runs at the same time as an effect. (Bug 79174)
     */
    override public function set autoLayout(value:Boolean):void
    {
    }
    
    //----------------------------------
    //  layout
    //----------------------------------    
    
    /**
     *  @private
     */
    override public function set layout(value:LayoutBase):void
    {
        throw(new Error(resourceManager.getString("components", "layoutReadOnly")));
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  resizeToContent
    //----------------------------------
    
    /**
     *  @private
     *  Storage for the resizeToContent property.
     */
    private var _resizeToContent:Boolean = false;
    
    /**
     *  If <code>true</code>, the ViewStack container automatically
     *  resizes to the size of its current child.
     *     If <code>false</code>, the ViewStack container sizes to the size of
     *  the first child. Note that by default the content itself does not get 
     *  resized so content that does not fit within the ViewStack will still appear. 
     *  To clip the extra content, you can create a skin for the NavigatorContainer
     *  and set the <code>clipAndEnableScrolling</code> property on its <code> contentGroup </code>.
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
        _resizeToContent = value;
        resizeToContentChanged = true;
        invalidateProperties();
    }
    
    //----------------------------------
    //  selectedElement
    //----------------------------------
    
    [Bindable("valueCommit")]
    [Bindable("creationComplete")]
    
    /**
     *  A reference to the currently visible child.
     *  The default is a reference to the first child.
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
        if (selectedIndex == -1)
            return null;
        
        return IVisualElement(getElementAt(selectedIndex));
    }
    
    /**
     *  @private
     */
    public function set selectedElement(
        value:IVisualElement):void
    {
        var newIndex:int = getElementIndex(IVisualElement(value));
        
        if (newIndex >= 0 && newIndex < numElements)
            selectedIndex = newIndex;
    }
    
    //----------------------------------
    //  selectedIndex
    //----------------------------------
    
    /**
     *  @private
     *  Storage for the selectedIndex property.
     */
    private var _selectedIndex:int = -1;
    
    /**
     *  @private
     */
    private var proposedSelectedIndex:int = -1;
    
    /**
     *  @private
     */
    private var showSelectedIndex:Boolean = false;
    
    [Bindable("change")]
    [Bindable("valueCommit")]
    [Bindable("creationComplete")]
    [Inspectable(category="General")]
    
    /**
     *  The zero-based index of the currently visible child.
     *  The default value is 0, corresponding to the first child.
     *  If there are no children, the value of this property is <code>-1</code>.
     * 
     *  <p><strong>Note:</strong> When you add a new child to a ViewStack 
     *  container, the <code>selectedIndex</code> property is automatically 
     *  adjusted, if necessary, so that the selected child remains selected.</p>
     *  
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5.0
     */
    public function get selectedIndex():int
    {
        return proposedSelectedIndex == -1 ?
            _selectedIndex :
            proposedSelectedIndex;
    }
    
    /**
     *  @private
     */
    public function set selectedIndex(value:int):void
    {
        // Bail if the index isn't changing.
        if (value == selectedIndex)
            return;
        
        // ignore, probably coming from tabbar
        if (addingChildren)
            return;
        
        // Propose the specified value as the new value for selectedIndex.
        // It gets applied later when measure() calls commitSelectedIndex().
        // The proposed value can be "out of range", because the children
        // may not have been created yet, so the range check is handled
        // in commitSelectedIndex(), not here. Other calls to this setter
        // can change the proposed index before it is committed. Also,
        // childAddHandler() proposes a value of 0 when it creates the first
        // child, if no value has yet been proposed.
        proposedSelectedIndex = value;
        showSelectedIndex = true;
        invalidateProperties();
        
        dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods: UIComponent
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    override protected function childrenCreated():void
    {
        super.childrenCreated();
        
        // Make sure all the children are not visible after
        // creation.
        for (var i:int = 0; i < numElements; i++)
        {
            if (i != selectedElement)
                getElementAt(i).visible = false;
        }
    }
    
    /**
     *  @private
     */
    override protected function commitProperties():void
    {
        super.commitProperties();
     
        // If the selected index has not been set then default
        // to the first element.
        if (numElements > 0 && proposedSelectedIndex == -1)
            proposedSelectedIndex = 0;
                
        if (proposedSelectedIndex != -1)
        {
            commitSelectedIndex(proposedSelectedIndex);
            proposedSelectedIndex = -1;
        }
        
        if (needToInstantiateSelectedChild)
        {
            instantiateSelectedChild();
            needToInstantiateSelectedChild = false;
        }
        
        if (resizeToContentChanged)
        {
            resizeToContentChanged = false;
            ViewStackLayout(layout).resizeToContent = _resizeToContent;
        }
        
        // Dispatch the change event only after the child has been
        // instantiated.
        if (dispatchChangeEventPending)
        {
            dispatchChangeEvent(lastSelectedIndex, selectedIndex);
            dispatchChangeEventPending = false;
        }
        
    }
    
    /**
     *  @private
     *  Responds to size changes by setting the positions and sizes
     *  of this container's children.
     *  For more information about the <code>updateDisplayList()</code> method,
     *  see the <code>UIComponent.updateDisplayList()</code> method.
     *
     *  <p>Only one of its children is visible at a time, therefore,
     *  a ViewStack container positions and sizes only that child.</p>
     *
     *  <p>The selected child is positioned in the ViewStack container's
     *  upper-left corner, and allows for the ViewStack container's
     *  padding and borders. </p>
     *
     *  <p>If the selected child has a percentage <code>width</code> or
     *  <code>height</code> value, it is resized in that direction
     *  to fill the specified percentage of the ViewStack container's
     *  content area (i.e., the region inside its padding).</p>
     *
     *  @param unscaledWidth Specifies the width of the component, in pixels,
     *  in the component's coordinates, regardless of the value of the
     *  <code>scaleX</code> property of the component.
     *
     *  @param unscaledHeight Specifies the height of the component, in pixels,
     *  in the component's coordinates, regardless of the value of the
     *  <code>scaleY</code> property of the component.
     * 
     *  @see mx.core.UIComponent#updateDisplayList()
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    override protected function updateDisplayList(unscaledWidth:Number,
                                                  unscaledHeight:Number):void
    {
        super.updateDisplayList(unscaledWidth, unscaledHeight);
        
        if (showSelectedIndex)
        {
            showSelectedIndex = false;

            showSelectedElement(getLastSelectedElement(),
                                selectedElement);
        }
    }
    
    /**
     *  @private
     *  When asked to create an overlay mask, create it on the selected child
     *  instead. That way, the chrome around the edge of the ViewStack
     *  (e.g. the tabs in a TabNavigator) is not occluded by the overlay mask
     *  (Bug 99029)
     */
    override mx_internal function addOverlay(color:uint,
                                             targetArea:RoundedRectangle = null):void
    {
        // As we're switching the currently-selected child, don't
        // allow two children to both have an overlay at the same time.
        // This is done because it makes accounting a headache.  If there's
        // a legitimate reason why two children both need overlays, this
        // restriction could be relaxed.
        if (effectOverlayChild)
            removeOverlay();
        
        // Remember which child has an overlay, so that we don't inadvertently
        // create an overlay on one child and later try to remove the overlay
        // of another child. (bug 100731)
        effectOverlayChild = (selectedElement as UIComponent);
        if (!effectOverlayChild)
            return;
        
        effectOverlayColor = color;
        effectOverlayTargetArea = targetArea;
        
        if ((selectedElement is IDeferredContentOwner) &&
            IDeferredContentOwner(selectedElement).deferredContentCreated == false)
            // No children have been created
        {
            // Wait for the childrenCreated event before creating the overlay
            selectedElement.addEventListener(FlexEvent.INITIALIZE,
                initializeHandler);
        }
        else // Children already exist
        {
            initializeHandler(null);
        }
    }
    
    /**
     *  @private
     */
    override mx_internal function removeOverlay():void
    {
        if (effectOverlayChild)
        {
            effectOverlayChild.removeOverlay();
            effectOverlayChild = null;
        }
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods: SkinnableContainer
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    override public function addElementAt(element:IVisualElement, index:int):IVisualElement
    {
        addingChildren = true;
        var obj:IVisualElement = super.addElementAt(element, index);
        internalDispatchEvent(CollectionEventKind.ADD, obj, index);
        childAddHandler(element);
        addingChildren = false;
        return obj;
    }
    
    /**
     *  @private
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    override public function removeElement(element:IVisualElement):IVisualElement
    {
        var index:int = getElementIndex(element);
        var obj:IVisualElement = super.removeElement(element);
        internalDispatchEvent(CollectionEventKind.REMOVE, obj, index);
        childRemoveHandler(element, index);
        return obj;
    }
    
    /**
     *  @private
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    override public function removeAllElements():void
    {
        super.removeAllElements();
        internalDispatchEvent(CollectionEventKind.RESET);
    }
    
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     * 
     *  Commits the selected index. This function is called during the commit 
     *  properties phase when the <code>selectedIndex</code> or 
     *  <code>selectedItem</code> property changes.
     *
     *  @param newIndex The selected index.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    protected function commitSelectedIndex(newIndex:int):void
    {
        // The selectedIndex must be -1 if there are no children,
        // even if a selectedIndex has been proposed.
        if (numElements == 0)
        {
            _selectedIndex = -1;
            return;
        }
        
        // If there are children, ensure that the new index is in bounds.
        if (newIndex < 0)
            newIndex = 0;
        else if (newIndex > numElements - 1)
            newIndex = numElements - 1;
        
        // Stop all currently playing effects
        if (lastSelectedIndex != -1 && lastSelectedIndex < numElements)
        {
            var lastElement:UIComponent = getElementAt(lastSelectedIndex) as UIComponent; 
            if (lastElement)
                lastElement.endEffectsStarted();
        }
        
        if (_selectedIndex != -1 && (selectedElement is UIComponent))
            UIComponent(selectedElement).endEffectsStarted();
        
        // Remember the old index.
        lastSelectedIndex = _selectedIndex;
        
        // Bail if the index isn't changing.
        if (newIndex == lastSelectedIndex)
            return;
        
        // Commit the new index.
        _selectedIndex = newIndex;
        ViewStackLayout(layout).selectedIndex = newIndex;
        
        // Only dispatch a change event if we're going to and from
        // a valid index
        if (lastSelectedIndex != -1 && newIndex != -1)
            dispatchChangeEventPending = true;

        showSelectedIndex = true;
        needToInstantiateSelectedChild = true;
        invalidateProperties();
    }
    
    /**
     *  This function is called during the transition of selected elements to 
     *  hide <code>oldSelectedElement</code> and show 
     * <code>newSelectedElement</code>. This method is also called for
     *  the selection of the first element in the <code>ViewStack</code> 
     *  component. During the selection of the first element there is no 
     *  previously selected element so the <code>oldSelectedElement</code>
     *  parameter will be <code>null</code>. 
     *  When this function is called the <code>oldSelectedElement</code> is
     *  visible (if it exists) and the <code>newSelectedElement</code> is not. 
     *
     *  The default behavior of this function is hide 
     *  <code>oldSelectedElement</code> and show <code>newSelectedElement</code>
     *  by setting their <code>visible</code> properties.
     * 
     *  @param oldSelectedElement A reference to the element was selected until 
     *  the last change of selected elements. This reference is 
     *  <code>null</code> during the initial selection of an element in the 
     *  <code>ViewStack</code> component.
     *  @param newSelectedElement A reference to the element that has been selected
     *  for display in the ViewStack.
     *  
     */
    protected function showSelectedElement(oldSelectedElement:IVisualElement,
                                           newSelectedElement:IVisualElement):void
    {
        // The default behavior is to make the oldSelectedElement hidden and 
        // make the newSelectedElement visible.
        if (oldSelectedElement)
            oldSelectedElement.visible = false;
        
        if (newSelectedElement)
            newSelectedElement.visible = true;
        
        selectedElementShown(oldSelectedElement, newSelectedElement);
    }
    
    /**
     *  This function is called after <code>showSelectedElement()</code> has completed.
     *  If <code>showSelectedElement()</code> runs an effect this function should
     *  not be called until after the effect has completed.
     * 
     *  @param oldSelectedElement A reference to the element was selected until 
     *  the last change of selected elements. This reference is 
     *  <code>null</code> during the initial selection of an element in the 
     *  <code>ViewStack</code> component.
     *  @param newSelectedElement A reference to the element that has been selected
     *  for display in the ViewStack.
     *  
     */
    protected function selectedElementShown(oldSelectedElement:IVisualElement,
                                            newSelectedElement:IVisualElement):void
    {
        // After the oldSelectedElement is hidden and the newSelectedElement has been
        // shown.
        // Make sure the visibility of the elements are set.
        if (oldSelectedElement)
        {
            applyDestructionPolicy();
        }
        
    }
    
    
    /**
     *  @private
     */ 
    private function getLastSelectedElement():IVisualElement
    {
        var lastSelectedElement:IVisualElement = null
            
        if (lastSelectedIndex != -1 
            && lastSelectedIndex < numElements 
            && lastSelectedIndex != selectedIndex)
            lastSelectedElement = getElementAt(lastSelectedIndex);
            
        return lastSelectedElement;
    }
    
    //--------------------------------------------------------------------------
    //
    //  IList Implementation
    //  ViewStack implements IList so it can be plugged into a Spark ButtonBar
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  The IList implementation dispatches change events when 
     *  label or icon properties change.
     */
    private function navigatorChildChangedHandler(event:Event):void
    {
        var pe:PropertyChangeEvent = new PropertyChangeEvent(PropertyChangeEvent.PROPERTY_CHANGE);
        pe.source = event.target;
        pe.property = (event.type == "labelChanged") ? "label" : "icon";
        
        internalDispatchEvent(CollectionEventKind.UPDATE, pe, getElementIndex(event.target as IVisualElement));
    }
    
    /**
     *  Dispatches a collection event with the specified information.
     *
     *  @param kind String indicates what the kind property of the event should be
     *  @param item Object reference to the item that was added or removed
     *  @param location int indicating where in the source the item was added.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    private function internalDispatchEvent(kind:String, item:Object = null, location:int = -1):void
    {
        if (hasEventListener(CollectionEvent.COLLECTION_CHANGE))
        {
            var event:CollectionEvent =
                new CollectionEvent(CollectionEvent.COLLECTION_CHANGE);
            event.kind = kind;
            event.items.push(item);
            event.location = location;
            dispatchEvent(event);
        }
        
        // now dispatch a complementary PropertyChangeEvent
        if (hasEventListener(PropertyChangeEvent.PROPERTY_CHANGE) && 
            (kind == CollectionEventKind.ADD || kind == CollectionEventKind.REMOVE))
        {
            var objEvent:PropertyChangeEvent =
                new PropertyChangeEvent(PropertyChangeEvent.PROPERTY_CHANGE);
            objEvent.property = location;
            if (kind == CollectionEventKind.ADD)
                objEvent.newValue = item;
            else
                objEvent.oldValue = item;
            dispatchEvent(objEvent);
        }
    }
    
    /**
     *  @private
     *  IList implementation of length returns numElements
     */
    public function get length():int
    {
        return numElements;
    }
    
    /**
     *  @private
     *  IList implementation of addItem calls addChild
     */
    public function addItem(item:Object):void
    {
        addElement(item as IVisualElement);
    }
    
    /**
     *  @private
     *  IList implementation of addItemAt calls addChildAt
     */
    public function addItemAt(item:Object, index:int):void
    {
        addElementAt(item as IVisualElement, index);
    }
    
    /**
     *  @private
     *  IList implementation of getItemAt calls getElementAt
     */
    public function getItemAt(index:int, prefetch:int = 0):Object
    {
        return getElementAt(index);
    }
    
    /**
     *  @private
     *  IList implementation of getItemIndex calls getElementIndex
     */
    public function getItemIndex(item:Object):int
    {
        return getElementIndex(item as IVisualElement);
    }
    
    /**
     *  @private
     *  IList implementation of itemUpdated doesn't do anything
     */
    public function itemUpdated(item:Object, property:Object = null, 
                                oldValue:Object = null, 
                                newValue:Object = null):void
    {
        
    }                         
    
    /**
     *  @private
     *  IList implementation of removeAll calls removeAllChildren
     */
    public function removeAll():void
    {
        removeAllElements();
    }
    
    /**
     *  @private
     *  IList implementation of removeItemAt calls removeChildAt
     */
    public function removeItemAt(index:int):Object
    {
        return removeElementAt(index);
    }
    
    /**
     *  @private
     *  IList implementation of setItemAt removes the old
     *  child and adds the new
     */
    public function setItemAt(item:Object, index:int):Object
    {
        var result:Object = removeElementAt(index);
        addElementAt(item as IVisualElement,index);
        return result;
    }
    
    /**
     *  @private
     *  IList implementation of toArray returns array of children
     */
    public function toArray():Array 
    {
        var result:Array = [];
        for (var i:int = 0; i < numElements; i++)
        {
            result.push(getElementAt(i));
        }
        return result;
    }
    
    /**
     *  @private
     * 
     *  Apply the destruction policy to the lastSelectedElement.
     */
    private function applyDestructionPolicy():void
    {
        if (lastSelectedIndex == -1 || lastSelectedIndex >= numElements)
            return;
        
        var lastElement:IDeferredContentOwner = getElementAt(lastSelectedIndex) as IDeferredContentOwner;
        
        if (lastElement && 
            (lastElement.elementDestructionPolicy == ContainerDestructionPolicy.AUTO ||
             lastElement.elementDestructionPolicy == ContainerDestructionPolicy.ALWAYS))
        {
            lastElement.removeDeferredContent(
                lastElement.elementDestructionPolicy == ContainerDestructionPolicy.AUTO);
        }
        
    }

    /**
     *  @private
     */
    private function instantiateSelectedChild():void
    {
        if (!selectedElement)
            return;
        
        // Performance optimization: don't call createComponents if we know
        // that createComponents has already been called.
        if ((selectedElement is IDeferredContentOwner) && 
            IDeferredContentOwner(selectedElement).elementCreationPolicy != "none" &&
            IDeferredContentOwner(selectedElement).deferredContentCreated == false)
        {
            if (initialized)  // Only listen if the ViewStack has already been initialized.
                selectedElement.addEventListener(FlexEvent.CREATION_COMPLETE,childCreationCompleteHandler);
            IDeferredContentOwner(selectedElement).createDeferredContent();
        }
        
        // Do the initial measurement/layout pass for the
        // newly-instantiated descendants.
        
        if (selectedElement is IInvalidating)
            IInvalidating(selectedElement).invalidateSize();
        
        invalidateDisplayList();
    }
    
    /**
     *  @private
     */
    private function dispatchChangeEvent(oldIndex:int, newIndex:int):void
    {
        var event:IndexChangeEvent =
            new IndexChangeEvent(IndexChangeEvent.CHANGE);
        event.oldIndex = oldIndex;
        event.newIndex = newIndex;
        
        dispatchEvent(event);
    }
    
    //--------------------------------------------------------------------------
    //
    //  Event handlers
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  Called when we are running a Dissolve effect
     *  and the initialize event has been dispatched
     *  or the children already exist
     */
    private function initializeHandler(event:FlexEvent):void
    {
        effectOverlayChild.removeEventListener(FlexEvent.INITIALIZE,
            initializeHandler);
        
        UIComponent(effectOverlayChild).addOverlay(effectOverlayColor, effectOverlayTargetArea);
    }
    
    /**
     *  @private
     *  Handles when the new selectedElement has finished being created.
     */
    private function childCreationCompleteHandler(event:FlexEvent):void
    {
        event.target.removeEventListener(FlexEvent.CREATION_COMPLETE,childCreationCompleteHandler);
        event.target.dispatchEvent(new FlexEvent(FlexEvent.SHOW));
        
    }
    
    /**
     *  @private
     */
    private function elementAddHandler(event:ElementExistenceEvent):void
    {
        addingChildren = true;
        internalDispatchEvent(CollectionEventKind.ADD, event.element, event.index);
        childAddHandler(event.element);
        addingChildren = false;
    }
    
    /**
     *  @private
     */
    private function elementRemoveHandler(event:ElementExistenceEvent):void
    {
        internalDispatchEvent(CollectionEventKind.REMOVE, event.element, event.index);
        childRemoveHandler(event.element, event.index);
    }
    
    /**
     *  @private
     */
    private function childAddHandler(child:IVisualElement):void
    {
        var index:int = getElementIndex(child);
        
        // ViewStack creates all of its children initially invisible.
        // They are made visible as they become selected.
        child.visible = false;
        
        if (child is INavigatorContent)
        {
            child.addEventListener("labelChanged", navigatorChildChangedHandler);
            child.addEventListener("iconChanged", navigatorChildChangedHandler);
        }
        
        // If we just created the first child and no selected index has
        // been proposed, then propose this child to be selected.
        if (_selectedIndex == -1 && proposedSelectedIndex == -1)
        {
            proposedSelectedIndex = 0;
            dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
            needToInstantiateSelectedChild = true;
            invalidateProperties();
        } 
        else if (index <= selectedIndex && numElements > 1 && proposedSelectedIndex == -1)         
        {
            proposedSelectedIndex++;
            dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
        }
        
        if (child is IAutomationObject)
            IAutomationObject(child).showInAutomationHierarchy = true;
        
    }
    
    /**
     *  @private
     *  When a child is removed, adjust the selectedIndex such that the current
     *  child remains selected; or if the current child was removed, then the
     *  next (or previous) child gets automatically selected; when the last
     *  remaining child is removed, the selectedIndex is set to -1.
     */
    private function childRemoveHandler(child:IVisualElement, index:int):void
    {
        if (child is INavigatorContent)
        {
            child.removeEventListener("labelChanged", navigatorChildChangedHandler);
            child.removeEventListener("iconChanged", navigatorChildChangedHandler);
        }
        
        // Handle the simple case.
        if (index > selectedIndex)
            return;
        
        var currentSelectedIndex:int = selectedIndex;
        
        // This matches one of the two conditions:
        // 1. a view before the current was deleted, or
        // 2. the current view was deleted and it was also
        //    at the end of the stack.
        // In both cases, we need to decrement selectedIndex.
        if (index < currentSelectedIndex ||
            currentSelectedIndex == numElements)
        {
            // If the selectedIndex was already 0, it should go to -1.
            // -1 is a special value; in order to avoid runtime errors
            // in various methods, we need to skip the range checking in
            // commitSelectedIndex() and set _selectedIndex explicitly here.
            if (currentSelectedIndex == 0)
            {
                _selectedIndex = -1;
                dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
            }
            else
            {
                _selectedIndex--;
                dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
            }
        }
        else if (index == currentSelectedIndex)
        {
            // If we're deleting the currentSelectedIndex and there is another
            // child after it, it will become the new selected child so we
            // need to make sure it is instantiated and shown.
            needToInstantiateSelectedChild = true;
            invalidateProperties();

            showSelectedIndex = true;
            invalidateDisplayList();
        }
    }
        
}

}

