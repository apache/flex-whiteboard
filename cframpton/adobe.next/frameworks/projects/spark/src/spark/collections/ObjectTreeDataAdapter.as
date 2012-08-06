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

// FIXME (klin): Should replace childrenField with "childrenPath" using the IDataPath, or we
// could add childrenFunction. Same with parentField.

package spark.collections
{
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.utils.Dictionary;

import mx.events.PropertyChangeEvent;
import mx.resources.IResourceManager;
import mx.resources.ResourceManager;

import spark.events.TreeDataAdapterChangeEvent;
import spark.events.TreeDataAdapterChangeEventKind;

//--------------------------------------
//  Events
//--------------------------------------

/**
 *  ObjectTreeDataAdapter will dispatch different kinds of TreeDataAdapterChangeEvents
 *  when changes occur.
 *  <code>TreeDataAdapterChangeEventKind.RESET</code> events are dispatched whenever the adapter
 *  fundamentally changes including changes to childrenField, parentField, or rootNodes.
 *  <code>TreeDataAdapterChangeEventKind.ADD</code> and
 *  <code>TreeDataAdapterChangeEventKind.REMOVE</code> events are dispatched when the adapter
 *  has nodes added or removed from it through <code>addNodeChildrenAt()</code>
 *  and <code>removeNodeChildrenAt()</code>. 
 *
 *  @eventType spark.events.TreeDataAdapterChangeEvent.TREE_DATA_ADAPTER_CHANGE
 */
[Event(name="treeDataAdapterChange", type="spark.events.TreeDataAdapterChangeEvent")]

//--------------------------------------
//  Other metadata
//--------------------------------------

[DefaultProperty("rootNodes")]

/**
 *  The ObjectTreeDataAdapter class provides tree API for Objects including getting
 *  the children and parent of an Object.
 *  The tree has a list of "root" Objects whose parent is null.
 *  Each object that has children must have a property with a name that matches the
 *  value of the <code>childrenField</code> property.
 *  The value of a branch's object <code>childrenField</code> must either be an
 *  Array or a Vector. 
 *  By default, <code>childrenField</code> is "children".
 * 
 *  <p>ObjectTreeDataAdapter keeps track of each child's parent node.
 *  By default, the child to parent mapping is stored in an internal cache.
 *  If the objects from the source already have a references to their parent 
 *  objects, setting the <code>parentField</code>property will make parent 
 *  look-ups more efficient.
 *  This will also disable caching of the child to parent relationships.</p>
 */
public class ObjectTreeDataAdapter extends EventDispatcher implements IMutableTreeDataAdapter
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
     *  @param rootNodes A vector of root nodes to populate this tree.
     *  By default, this is null.
     * 
     *  @param childrenField The name of the property used to retrieve
     *  the children of a parent object. By default, this is "children".
     * 
     *  @param parentField The name of the property used to retrieve the
     *  parent of a node. By default, this is null.
     */
    public function ObjectTreeDataAdapter(rootNodes:Vector.<Object> = null,
                                          childrenField:String = "children",
                                          parentField:String = null)
    {
        super();
        // set these without causing a RESET event.
        _childrenField = childrenField;
        _parentField = parentField;
        this.rootNodes = rootNodes;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    
    /**
     *  A map of each child node to its parent.
     *  A root node is mapped to null.
     *  If parentMap is null, the caching behavior is disabled.
     */
    private var parentMap:Dictionary = new Dictionary(true);
    
    /**
     *  A map of each node to its depth.
     *  A root node is mapped to 0.
     */
    private var depthMap:Dictionary = new Dictionary(true);
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  childrenField
    //----------------------------------
    
    private var _childrenField:String = "children";
    
    [Bindable(event="childrenFieldChanged")]
    
    /**
     *  The name of the property used to retrieve
     *  the list of children from each data node.
     *  The value of a branch's object <code>childrenField</code> must
     *  either be an Array or a Vector. 
     *  Changing this property will dispatch a
     *  <code>TreeAdapterChangeEventKind.RESET</code> event.
     * 
     *  @default "children"
     */
    public function get childrenField():String
    {
        return _childrenField;
    }
    
    /**
     *  @inheritDoc
     */
    public function set childrenField(value:String):void
    {
        if (_childrenField == value)
            return;
        
        _childrenField = value;
        
        reset();
        dispatchChangeEvent("childrenFieldChanged");
    }
    
    //----------------------------------
    //  parentField
    //----------------------------------
    
    private var _parentField:String = null;
    
    [Bindable(event="parentField")]
    
    /**
     *  The name of the property used to retrieve the parent of a data node.
     *  By default this property is null, and ObjectTreeDataAdapter stores the
     *  child to parent mapping in an internal cache.
     *  Setting this property will disable the caching behavior and can improve
     *  the efficiency of calculating the parent.
     *  Changing this property will dispatch a
     *  <code>TreeDataAdapterChangeEventKind.RESET</code> event.
     * 
     *  @default null
     */
    public function get parentField():String
    {
        return _parentField;
    }
    
    /**
     *  @inheritDoc
     */
    public function set parentField(value:String):void
    {
        if (_parentField == value)
            return;
        
        _parentField = value;
        
        reset();
        dispatchChangeEvent("parentFieldChanged");
    }
    
    //----------------------------------
    //  rootNodes
    //----------------------------------
    
    private var _rootNodes:Vector.<Object> = new Vector.<Object>(0, true);
    
    [Bindable("rootNodesChanged")]
    
    /**
     *  The vector of objects that represents the root nodes of this tree.
     *  The adapter does not track changes to this vector.
     *  If any changes are made to this vector, the rootNodes property should
     *  be set again.
     * 
     *  @default An empty vector.
     */
    public function get rootNodes():Vector.<Object>
    {
        return _rootNodes.concat();
    }
    
    /**
     *  @inheritDoc
     */
    public function set rootNodes(value:Vector.<Object>):void
    {
        // Don't need to short-circuit, because if _rootNodes == value, we should get the new
        // set of nodes anyway.
        // Defensively copy the incoming value; tolerate null value
        const valueCopy:Vector.<Object> = (value) ? value.concat() : new Vector.<Object>(0, true);
        
        _rootNodes = valueCopy;
        
        reset();
        dispatchChangeEvent("rootNodesChanged");
    }
    
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Throws a RangeError if the index is invalid.
     */ 
    private function checkIndex(index:int, list:Object):void
    {
        if (index < 0 || index >= list.length)
        {
            var message:String = ResourceManager.getInstance().getString(
                "collections", "outOfBounds", [ index ]);
            throw new RangeError(message);
        }
    }
    
    /**
     *  Helper function to dispatch change events only when someone's listening.
     */
    private function dispatchChangeEvent(type:String):void
    {
        if (hasEventListener(type))
            dispatchEvent(new Event(type));
    }
    
    /**
     *  Helper function to dispatch TreeAdapterChangeEvents.
     *  Checks to see if anyone is listening first.
     */
    private function dispatchTreeDataAdapterChangeEvent(
        kind:String,
        nodes:Vector.<Object> = null,
        index:int = -1,
        parent:Object = null):void
    {
        if (hasEventListener(TreeDataAdapterChangeEvent.TREE_DATA_ADAPTER_CHANGE))
        {
            var e:TreeDataAdapterChangeEvent =
                new TreeDataAdapterChangeEvent(
                    TreeDataAdapterChangeEvent.TREE_DATA_ADAPTER_CHANGE,
                    false, false,
                    kind, nodes,
                    index, parent);
            dispatchEvent(e);
        }
    }
    
    /**
     *  Depth-first search for the parent.
     */
    private function findParent(parent:Object, targetNode:Object):Object
    {
        if (isLeafNode(parent))
            return null;
        
        var children:Object = getChildren(parent);
        
        // targetNode is an immediate child of this parent
        if (ArrayVectorUtil.getItemIndex(children, targetNode) != -1)
        {
            parentMap[targetNode] = parent;
            return parent;
        }
        
        // Recursively call findParent() on each child.
        var childrenLength:int = children.length;
        for (var i:int = 0; i < childrenLength; i++) 
        {
            var child:Object = ArrayVectorUtil.getItemAt(children, i);
            parentMap[child] = parent;
            var p:Object = findParent(child, targetNode);
            if (p)
                return p;
        }
        
        return null;
    }
    
    /**
     *  Retrieves the set of children from the specified parent object.
     *  This return value could be either an Array or Vector, so ArrayVectorUtil
     *  should be used to perform operations on it.
     */
    private function getChildren(parent:Object):Object
    {
        // FIXME (klin): This method will be used to enable
        // childrenFunction or childrenPath?...
        if (!parent)
            return _rootNodes;
        
        return parent[childrenField];
    }
    
    /**
     *  Resets the parent and depth maps.
     */
    private function reset():void
    {
        parentMap = parentField ? null : new Dictionary(true);
        depthMap = new Dictionary(true);
        
        if (parentMap)
        {        
            const roots:Vector.<Object> = _rootNodes;
            const numRoots:int = roots.length;
            for (var i:int = 0; i < numRoots; i++)
            {
                parentMap[roots[i]] = null;
            }
        }
        dispatchTreeDataAdapterChangeEvent(TreeDataAdapterChangeEventKind.RESET);
    }
    
    //--------------------------------------------------------------------------
    //
    //  ITreeDataAdapter Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @inheritDoc
     */
    public function getNodeParent(node:Object):Object
    {
        if (!node)
            return null;
        
        // FIXME (klin): Should enable parentFunction or parentPath here.
        if (!parentMap)
            return node[parentField];
        
        // If we haven't calculated the node's parent,
        // search for it and build the cache along the way.
        return (node in parentMap) ? parentMap[node] : findParent(null, node);
    }
    
    /**
     *  @inheritDoc
     */
    public function isLeafNode(node:Object):Boolean
    {
        if (!node)
            return false;
        
        return !(childrenField in node) || (node[childrenField] == undefined);
    }
    
    /**
     *  @inheritDoc
     */
    public function getNodeChildrenCount(parent:Object):int
    {
        if (isLeafNode(parent))
            return 0;
        
        var children:Object = getChildren(parent);
        return (children) ? children.length : 0;
    }
    
    /**
     *  @inheritDoc
     */
    public function getNodeChildIndex(node:Object):int
    {
        if (!node)
            return -1;
        
        var p:Object = getNodeParent(node);
        return ArrayVectorUtil.getItemIndex(getChildren(p), node);
    }
    
    /**
     *  @inheritDoc
     */
    public function getNodeChildAt(parent:Object, index:int):Object
    {
        if (isLeafNode(parent))
            return null;
        
        var children:Object = getChildren(parent);
        checkIndex(index, children);
        
        var node:Object = ArrayVectorUtil.getItemAt(children, index);
        // Store parent whenever getNodeChildAt() is called.
        // 99% of the time, we never need to search for the node's parent.
        if (parentMap)
            parentMap[node] = parent;
        return node;
    }

    /**
     *  @inheritDoc
     */
    public function getNodeDepth(node:Object):int
    {
        if (!node)
            return -1;
        
        if (node in depthMap)
            return depthMap[node];
        
        var p:Object = getNodeParent(node);
        var depth:int = p ? getNodeDepth(p) + 1 : 0;
        depthMap[node] = depth;
        return depth;
    }
    
    //--------------------------------------------------------------------------
    //
    //  IMutableDataTreeAdapter Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @inheritDoc
     */
    public function addNodeChildrenAt(parent:Object, index:int, nodes:Vector.<Object>):void
    {
        if (isLeafNode(parent))
            return;
        
        var children:Object = getChildren(parent);
        
        if (index < 0 || index > children.length)
        {
            var message:String = ResourceManager.getInstance().getString(
                "collections", "outOfBounds", [ index ]);
            throw new RangeError(message);
        }
        
        ArrayVectorUtil.insertItemsAt(children, index, nodes);
        
        if (parentMap)
        {
            for each (var node:Object in nodes)
            {
                parentMap[node] = parent;
            }
        }
        
        dispatchTreeDataAdapterChangeEvent(TreeDataAdapterChangeEventKind.ADD, nodes.concat(), index, parent);
    }
    
    /**
     *  @inheritDoc
     */
    public function removeNodeChildrenAt(parent:Object, index:int, count:int):Vector.<Object>
    {
        if (isLeafNode(parent))
            return null;
        
        var children:Object = getChildren(parent);
        
        checkIndex(index, children);
        
        var removedNodes:Vector.<Object> = ArrayVectorUtil.removeItemsAt(children, index, count);
        
        if (parentMap)
        {
            for each (var node:Object in removedNodes)
            {
                delete parentMap[node];
            }
        }
        
        dispatchTreeDataAdapterChangeEvent(TreeDataAdapterChangeEventKind.REMOVE, removedNodes, index, parent);
        return removedNodes;
    }
}
}

//--------------------------------------------------------------------------
//
//  ArrayVectorUtil
//
//--------------------------------------------------------------------------

/**
 *  Helper class to perform common operations on arrays and vectors of any type.
 *  Any errors that may be thrown are ignored.
 */
class ArrayVectorUtil
{
    /**
     *  Returns the 0-based index of the specified item
     *  in the source array or vector.
     */
    public static function getItemIndex(source:Object, item:Object):int
    {
        if (!source)
            return -1;
        
        try
        {
            return source.indexOf(item);
        }
        catch (e:Error)
        {
        }
        
        return -1;
    }
    
    /**
     *  Returns the item at the specified index from 
     *  the array or vector.
     */
    public static function getItemAt(source:Object, index:int):Object
    {
        if (!source)
            return null;
        
        try
        {
            return source[index];
        }
        catch (e:Error)
        {
        }
        
        return null;
    }
    
    /**
     *  Inserts the specified items into the source array or vector.
     */
    public static function insertItemsAt(source:Object, index:int, items:Vector.<Object>):void
    {
        if (!source || !items || items.length < 1)
            return;
        
        try
        {
            const numItems:int = items.length;
            const oldLength:int = source.length;
            const endIndex:int = index + numItems;
            source.length += numItems;
            
            // shift existing elements down
            for (var i:int = oldLength - 1; i >= index; i--)
                source[i + numItems] = source[i];
            
            // insert new elements
            var j:int = 0;
            for (i = index; i < endIndex; i++)
                source[i] = items[j++];
        }
        catch (e:Error)
        {
        }
    }
    
    /**
     *  Removes the specified items from the source array or vector.
     */
    public static function removeItemsAt(source:Object, index:int, count:int):Vector.<Object>
    {
        if (!source || count < 1)
            return new Vector.<Object>(0, true);
        
        try
        {
            var removedItems:Object = source.splice(index, count);
            var rVec:Vector.<Object> = new Vector.<Object>(count);
            for (var i:int = 0; i < count; i++) 
            {
                rVec[i] = removedItems[i];
            }
        }
        catch (e:Error)
        {
        }
        
        return rVec;
    }
}