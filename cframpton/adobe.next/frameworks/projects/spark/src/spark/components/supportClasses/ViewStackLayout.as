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
import flash.geom.Rectangle;

import mx.core.IDeferredContentOwner;
import mx.core.ILayoutElement;
import mx.core.IVisualElement;
import mx.core.IUIComponent;
import mx.core.mx_internal;
import mx.resources.ResourceManager;

import spark.layouts.supportClasses.DropLocation;
import spark.layouts.supportClasses.LayoutBase;
import spark.layouts.supportClasses.LayoutElementHelper;

use namespace mx_internal;

[ExcludeClass]

[ResourceBundle("layout")]

/**
 *  The ViewStackLayout class arranges its elements to overlay each other. Each 
 *  element is positioned at the upper-left point of the target container.
 *  The size of the target container depends on the value of resizeToContent
 *  flag. If resizeToContent is false then the target container's size is the
 *  size of the first active child and does not change when the selected 
 *  child is changed.  If resizeToContent is true, then the target container 
 *  will be re-sized to the size of the selected child. 
 * 
 *  This layout is designed be used with the Spark ViewStack container
 *  where only the selected child is visible. But it is possible to use it with
 *  other containers as well.
 * 
 *  <p>The default size of the target container is the width and height of the 
 *  initial active child.</p>
 * 
 *  <p>By default, elements are sized only once to fit the size of the 
 *  first selected child element. They do not re-size when the selected child 
 *  is changed. To force the target container to re-size when you change the  
 *  selected child, set the resizeToContent property to true.</p>
 *  
 *  <p>Elements are sized to their default size. If the child is larger than 
 *  the target container, it is clipped. If the child is smaller than the 
 *  target container, it is aligned to the upper-left corner of the target
 *  container and re-sized to fill the target container.</p>
 * 
 *  @mxml 
 *  <p>The <code>&lt;s:ViewStackLayout&gt;</code> tag inherits all of the tag 
 *  attributes of its superclass and adds the following tag attributes:</p>
 *
 *  <pre>
 *  &lt;s:ViewStackLayout
 *    <b>Properties</b>
 *    paddingBottom="0"
 *    paddingLeft="0"
 *    paddingRight="0"
 *    paddingTop="0"
 *    resizeToContent="false|true"
 *    selectedIndex="0"
 *  &lt;/s:ViewStackLayout&gt;
 *  </pre>
 * 
 *  @see spark.components.ViewStack
 * 
 *  @langversion 3.0
 *  @playerversion Flash 11
 *  @playerversion AIR 3.0
 *  @productversion Flex 5.0
 */
public class ViewStackLayout extends LayoutBase
{
    include "../../core/Version.as";
    
    //--------------------------------------------------------------------------
    //
    //  Class methods
    //
    //--------------------------------------------------------------------------
    
    private static function constraintsDetermineWidth(layoutElement:ILayoutElement):Boolean
    {
        return !isNaN(layoutElement.percentWidth) ||
            !isNaN(LayoutElementHelper.parseConstraintValue(layoutElement.left)) &&
            !isNaN(LayoutElementHelper.parseConstraintValue(layoutElement.right));
    }
    
    private static function constraintsDetermineHeight(layoutElement:ILayoutElement):Boolean
    {
        return !isNaN(layoutElement.percentHeight) ||
            !isNaN(LayoutElementHelper.parseConstraintValue(layoutElement.top)) &&
            !isNaN(LayoutElementHelper.parseConstraintValue(layoutElement.bottom));
    }
    
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
    public function ViewStackLayout():void
    {
        super();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  We'll measure ourselves once and then store the results here.
     */
    private var cachedMeasuredMinWidth:Number;
    private var cachedMeasuredMinHeight:Number;
    private var cachedMeasuredWidth:Number;
    private var cachedMeasuredHeight:Number;
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  paddingBottom
    //----------------------------------
    
    private var _paddingBottom:Number = 0;
    
    [Inspectable(category="General")]
    
    /**
     *  Number of pixels between the container's bottom edge
     *  and the bottom edge of the last layout element.
     * 
     *  @default 0
     *  
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5.0
     */
    public function get paddingBottom():Number
    {
        return _paddingBottom;
    }
    
    /**
     *  @private
     */
    public function set paddingBottom(value:Number):void
    {
        if (_paddingBottom == value)
            return;
        
        _paddingBottom = value;
        invalidateTargetSizeAndDisplayList();
    }    
    
    //----------------------------------
    //  paddingLeft
    //----------------------------------
    
    private var _paddingLeft:Number = 0;
    
    [Inspectable(category="General")]
    
    /**
     *  The minimum number of pixels between the container's left edge and
     *  the left edge of the layout element.
     * 
     *  @default 0
     *  
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5.0
     */
    public function get paddingLeft():Number
    {
        return _paddingLeft;
    }
    
    /**
     *  @private
     */
    public function set paddingLeft(value:Number):void
    {
        if (_paddingLeft == value)
            return;
        
        _paddingLeft = value;
        invalidateTargetSizeAndDisplayList();
    }    
    
    //----------------------------------
    //  paddingRight
    //----------------------------------
    
    private var _paddingRight:Number = 0;
    
    [Inspectable(category="General")]
    
    /**
     *  The minimum number of pixels between the container's right edge and
     *  the right edge of the layout element.
     * 
     *  @default 0
     *  
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5.0
     */
    public function get paddingRight():Number
    {
        return _paddingRight;
    }
    
    /**
     *  @private
     */
    public function set paddingRight(value:Number):void
    {
        if (_paddingRight == value)
            return;
        
        _paddingRight = value;
        invalidateTargetSizeAndDisplayList();
    }    
    
    //----------------------------------
    //  paddingTop
    //----------------------------------
    
    private var _paddingTop:Number = 0;
    
    [Inspectable(category="General")]
    
    /**
     *  Number of pixels between the container's top edge
     *  and the top edge of the first layout element.
     * 
     *  @default 0
     *  
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5.0
     */
    public function get paddingTop():Number
    {
        return _paddingTop;
    }
    
    /**
     *  @private
     */
    public function set paddingTop(value:Number):void
    {
        if (_paddingTop == value)
            return;
        
        _paddingTop = value;
        invalidateTargetSizeAndDisplayList();
    }    
    
    //----------------------------------
    //  resizeToContent
    //----------------------------------
    
    /**
     *  @private
     *  Storage for the resizeToContent property.
     */
    private var _resizeToContent:Boolean = false;
    
    /**
     *  @copy spark.components.ViewStack#resizeToContent 
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
        if (value != _resizeToContent)
        {
            _resizeToContent = value;
            
            if (value && target)
            {
                target.invalidateSize();
                target.invalidateDisplayList();
            }
        }
    }
    
    //----------------------------------
    //  selectedIndex
    //----------------------------------
    
    /**
     *  @private
     *  Storage for the selectedIndex property.
     */
    private var _selectedIndex:int = -1;
    
    [Bindable("change")]
    [Bindable("valueCommit")]
    [Bindable("creationComplete")]
    [Inspectable(category="General")]
    
    /**
     *  @copy spark.components.ViewStack#selectedIndex 
     */
    public function get selectedIndex():int
    {
        return _selectedIndex;
    }
    
    /**
     *  @private
     */
    public function set selectedIndex(value:int):void
    {
        // The selectedIndex must be -1 if there are no children,
        // even if a selectedIndex has been proposed.
        if (target.numElements == 0)
        {
            _selectedIndex = -1;
            return;
        }
        
        // If there are children, ensure that the new index is in bounds.
        if (value < 0)
            value = 0;
        else if (value > target.numElements - 1)
            value = target.numElements - 1;
        
        // Bail if the index isn't changing.
        if (value == selectedIndex)
            return;
                
        _selectedIndex = value;
        
        if (target)
        {
            if (resizeToContent)
                target.invalidateSize();
            
            target.invalidateDisplayList();
        }
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @private 
     */
    override public function measure():void
    {
        // Virtual layouts are not supported. This class is not public so we 
        // are not throwing an error if someone tries to use virtual layouts.
        super.measure();
        
        var layoutTarget:GroupBase = target;
        if (!layoutTarget)
            return;
        
        // If resizeToContent is false then only size the target once.
        if (!resizeToContent && cachedMeasuredWidth)
        {
            layoutTarget.measuredWidth = cachedMeasuredWidth;
            layoutTarget.measuredHeight = cachedMeasuredHeight;
            layoutTarget.measuredMinWidth = cachedMeasuredMinWidth;
            layoutTarget.measuredMinHeight = cachedMeasuredMinHeight;
            return;				
        }
        
        // A ViewStackLayout measures itself based only on its selectedChild.
        // The minimum, maximum, and preferred sizes are those of the
        // selected child.
        var minWidth:Number = 0;
        var minHeight:Number = 0;
        var preferredWidth:Number = 0;
        var preferredHeight:Number = 0;
        
        if (layoutTarget.numElements > 0 && selectedIndex != -1)
        {
            var child:IVisualElement =
                layoutTarget.getElementAt(selectedIndex);
            
            minWidth = child.getMinBoundsWidth();
            preferredWidth = child.getPreferredBoundsWidth();
            
            minHeight = child.getMinBoundsHeight();
            preferredHeight = child.getPreferredBoundsHeight();
        }
        
        var hPadding:Number = paddingLeft + paddingRight;
        var vPadding:Number = paddingTop + paddingBottom;
        
        layoutTarget.measuredMinWidth = minWidth + hPadding;
        layoutTarget.measuredMinHeight = minHeight + vPadding;
        layoutTarget.measuredWidth = preferredWidth + hPadding;
        layoutTarget.measuredHeight = preferredHeight + vPadding;
        
        // If we're called before instantiateSelectedChild, then bail.
        // We'll be called again later (instantiateSelectedChild calls
        // invalidateSize), and we don't want to load values into the
        // cache until we're fully initialized.  (bug 102639)
        // This check was moved from the beginning of this function to
        // here to fix bug 103665.
        var selectedChild:IVisualElement = getSelectedChild();
        if ((selectedChild is IDeferredContentOwner) && 
            IDeferredContentOwner(selectedChild).deferredContentCreated == false)
            return;
        
        // Don't remember sizes if we don't have any children
        if (layoutTarget.numElements == 0)
            return;
        
        cachedMeasuredMinWidth = minWidth;
        cachedMeasuredMinHeight = minHeight;
        cachedMeasuredWidth = preferredWidth;
        cachedMeasuredHeight = preferredHeight;
    }
    
    /**
     *  @private 
     */
    override public function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    {
        super.updateDisplayList(unscaledWidth, unscaledHeight);
        
        var w:Number = unscaledWidth - paddingLeft - paddingRight;
        var h:Number = unscaledHeight - paddingTop - paddingBottom;
        
        var left:Number = paddingLeft;
        var top:Number = paddingTop;
        
        // Stretch the selectedIndex to fill our size
        if (selectedIndex != -1)
        {
            var child:IVisualElement = target.getElementAt(selectedIndex);
            
            var newWidth:Number = w;
            var newHeight:Number = h;
            
            if (!isNaN(child.percentWidth))
            {
                var maxWidth:Number = child.getMaxBoundsWidth();
                if (newWidth > maxWidth)
                    newWidth = maxWidth;
            }
            else
            {
                // If the child implements IUIComponent then check if an explicit
                // width is set. If it is then we will respect the explict width of 
                // the child instead of treating it like 100%.
                // If the child is not IUIComponent then use the preferred size.
                // The difference is, for non-IUIComponents they will need to 
                // set their width to 100% to be sized to the width of the 
                // ViewStack whereas IUIComponents will get that for free. The 
                // special case for IUIComponents is put in to mimic the 
                // behavior of the Halo ViewStack.
                var explicitWidth:Number = (child is IUIComponent) ? 
                                                IUIComponent(child).explicitWidth :
                                                child.getPreferredBoundsWidth();
                if (newWidth > explicitWidth)
                    newWidth = explicitWidth;
            }
            
            if (!isNaN(child.percentHeight))
            {
                var maxHeight:Number = child.getMaxBoundsHeight();
                if (newHeight > maxHeight)
                    newHeight = maxHeight;
            }
            else
            {
                // Comment above for explicit width applies here for height.
                var explicitHeight:Number = (child is IUIComponent) ?
                                                IUIComponent(child).explicitHeight :
                                                child.getPreferredBoundsHeight();
                if (newHeight > explicitHeight)
                    newHeight = explicitHeight;
            }
            
            if (child.width != newWidth || child.height != newHeight)
                child.setLayoutBoundsSize(newWidth, newHeight);
            if (child.x != left || child.y != top)
                child.setLayoutBoundsPosition(left, top);
            
        }
        
    }
    
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private 
     *  Convenience function for subclasses that invalidates the
     *  target's size and displayList so that both layout's <code>measure()</code>
     *  and <code>updateDisplayList</code> methods get called.
     * 
     *  <p>Typically a layout invalidates the target's size and display list so that
     *  it gets a chance to recalculate the target's default size and also size and
     *  position the target's elements. For example changing the <code>gap</code>
     *  property on a <code>VerticalLayout</code> will internally call this method
     *  to ensure that the elements are re-arranged with the new setting and the
     *  target's default size is recomputed.</p> 
     */
    private function invalidateTargetSizeAndDisplayList():void
    {
        var g:GroupBase = target;
        if (!g)
            return;
        
        g.invalidateSize();
        g.invalidateDisplayList();
    }
    
    /**
     *  @private
     */
    override protected function calculateDropIndicatorBounds(dropLocation:DropLocation):Rectangle
    {
        var dropIndex:int = dropLocation.dropIndex;
        var count:int = 1;
        
        var emptySpaceTop:Number = 0;
        if (target.numElements > 0)
        {
            emptySpaceTop = (dropIndex < count) ? getElementBounds(dropIndex).top : 
                getElementBounds(dropIndex - 1).bottom;
        }
        
        // Calculate the size of the bounds, take minium and maximum into account
        var width:Number = Math.max(target.width, target.contentWidth) - paddingLeft - paddingRight;
        var height:Number = 0;
        if (dropIndicator is IVisualElement)
        {
            var element:IVisualElement = IVisualElement(dropIndicator);
            height = Math.max(Math.min(height, element.getMaxBoundsHeight(false)), element.getMinBoundsHeight(false));
        }
        
        var x:Number = paddingLeft;
        
        var y:Number = emptySpaceTop + Math.round((-height)/2);
        // Allow 1 pixel overlap with container border
        y = Math.max(-1, Math.min(target.contentHeight - height + 1, y));
        return new Rectangle(x, y, width, height);
    }
    
    /**
     *  A reference to the currently visible child container.
     *  The default is a reference to the first child.
     *  If there are no children, this property is <code>null</code>.
     */
    private function getSelectedChild():IVisualElement
    {
        if (selectedIndex == -1 || !target)
            return null;
        
        return IVisualElement(target.getElementAt(selectedIndex));
    }
    
    
}

}
