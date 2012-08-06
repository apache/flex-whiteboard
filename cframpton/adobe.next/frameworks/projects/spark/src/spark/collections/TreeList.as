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

package spark.collections
{
import flash.events.Event;
import flash.events.EventDispatcher;

import mx.collections.IList;
import mx.events.CollectionEvent;
import mx.events.CollectionEventKind;
import mx.events.PropertyChangeEvent;
import mx.events.PropertyChangeEventKind;
import mx.resources.IResourceManager;
import mx.resources.ResourceManager;

import spark.events.TreeDataAdapterChangeEvent;
import spark.events.TreeDataAdapterChangeEventKind;

[ExcludeClass]

/**
 *  Exposes a tree defined by an ITreeDataAdapter as an IList to be
 *  displayed with Spark data containers like Tree and DataGrid.
 *  Initially, the list only contains the tree's root nodes.
 *  The <code>openNode()</code> method inserts a node's children into the list
 *  after the parent, and the <code>closeNode()</code> method removes a node's
 *  children from the list.
 * 
 *  <p>The <code>openNodes</code> property can be used to access and set
 *  the current list of open nodes.</p>
 * 
 *  <p>Note: TreeList only implements the read-only methods of the IList 
 *  interface.
 *  Any modifications to the tree structure should be done via the tree adapter.
 *  TreeList will handle TreeDataAdapterChangeEvents dispatched from the tree.</p>
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.0
 *  @productversion Flex 4.5
 */
public class TreeList extends EventDispatcher implements IList
{
    include "../core/Version.as";
    
    //--------------------------------------------------------------------------
    //
    //  Class Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Converts a vector of objects to an array.
     */
    private static function vectorToArray(vec:Vector.<Object>):Array
    {
        var vecLength:int = vec.length;
        var arr:Array = new Array(vecLength);
        
        for (var i:int = 0; i < length; i++) 
        {
            arr[i] = vec[i];
        }
        
        return arr;        
    }
    
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    
    /**    
     *  Constructor.
     * 
     *  @param tree The tree exposed by this TreeList.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function TreeList(tree:ITreeDataAdapter = null)
    {
        super();
        this.tree = tree;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Representation of the currently exposed parts of the tree.
     *  Also contains the currently open nodes (whether or not they are exposed).
     */
    private var exposedTree:ExposedTree;

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    private function dispatchChangeEvent(type:String):void
    {
        if (hasEventListener(type))
            dispatchEvent(new Event(type));
    }
    
    /**
     *  @private
     */
    private function dispatchCollectionChangeEvent(kind:String = null, location:int = -1,
                                                   oldLocation:int = -1, items:Array = null):void
    {
        const event:CollectionEvent = new CollectionEvent(
            CollectionEvent.COLLECTION_CHANGE,
            false, false, kind,
            location, oldLocation, items);
        dispatchEvent(event);
    }
    
    //----------------------------------
    //  openNodes
    //----------------------------------
    
    /**
     *  In TreeList, any manipulation of the openNodes vector should be done
     *  through _openNodes because of the defensive copy made by the getter.
     *  Subclasses that use openNodes can only manipulate the *values*.
     */
    private var _openNodes:Vector.<Object> = new Vector.<Object>();
    
    [Bindable("openNodesChanged")]
    
    /**
     *  Returns the set of open nodes.
     *  Setting this property will refresh the view and cause a
     *  <code>CollectionEventKind.REFRESH</code> <code>CollectionEvent</code>
     *  to be dispatched.
     *  If this property is set to null, getting it will still return an empty vector.
     *  
     *  @default An empty Vector.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function get openNodes():Vector.<Object>
    {
        return _openNodes.concat();
    }
    
    /**
     *  @private
     */
    public function set openNodes(value:Vector.<Object>):void
    {
        if (_openNodes == value)
            return;
        
        const valueCopy:Vector.<Object> = (value) ? value.concat() : new <Object>[];
        
        _openNodes = valueCopy;
        
        refresh();
        dispatchChangeEvent("openNodesChanged");
    }
    
    //----------------------------------
    //  tree
    //----------------------------------
    
    private var _tree:ITreeDataAdapter;
    
    /**
     *  The tree adapter exposed by this TreeList.
     *  Setting this property will clear the set of open nodes, populate 
     *  the view with the root nodes of the new tree adapter, and dispatch a
     *  <code>CollectionEventKind.RESET</code> <code>CollectionEvent</code>.
     *   
     *  @default null
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function get tree():ITreeDataAdapter
    {
        return _tree;
    }
    
    /**
     *  @private
     */
    public function set tree(value:ITreeDataAdapter):void
    {
        if (_tree == value)
            return;
        
        if (_tree)
        {
            _tree.removeEventListener(TreeDataAdapterChangeEvent.TREE_DATA_ADAPTER_CHANGE,
                                      treeDataAdapterChangeHandler);
        }
        
        _tree = value;
        if (_tree)
        {
            _tree.addEventListener(TreeDataAdapterChangeEvent.TREE_DATA_ADAPTER_CHANGE,
                                   treeDataAdapterChangeHandler);
        }
        
        reset();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Clears the nodes and opens the specified open nodes.
     */
    private function refresh():void
    {
        if (!exposedTree)
        {
            exposedTree = new ExposedTree();
        }
        
        exposedTree.tree = _tree;
        
        for each (var openNode:Object in _openNodes)
        {
            exposedTree.open(openNode);
        }
        
        dispatchCollectionChangeEvent(CollectionEventKind.REFRESH);
    }
    
    
    /**
     *  Clears the nodes and open nodes.
     *  If there's a new adapter, adds the new roots to the list.
     */
    private function reset():void
    {
        if (!exposedTree)
            exposedTree = new ExposedTree();
        
        exposedTree.tree = tree;
        _openNodes.length = 0;
        
        dispatchCollectionChangeEvent(CollectionEventKind.RESET);
    }
    
    /**   
     *  Add all of the specified parent node's children and open descendants to 
     *  this list and mark the node as "open".
     *  The node's descendants are inserted after the specified node.
     *  If the node is not exposed, then this method only adds the node to the 
     *  set of open nodes. 
     *  If the specified node is already open, then this method does nothing.
     * 
     *  <p>Calling this method can cause a <code>CollectionEventKind.ADD</code>
     *  <code>CollectionEvent</code> to be dispatched.
     *  Note that the CollectionEvent's <code>items</code> is an empty array with 
     *  length equal to the number of nodes that have been added</p>
     * 
     *  @param node An ITreeDataAdapter node.
     * 
     *  FIXME (klin): Probably don't need return value.
     *  @return true If the node is exposed, a branch, and opened successfully.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function openNode(node:Object):Boolean
    {
        if (!tree || !node || tree.isLeafNode(node) || _openNodes.indexOf(node) != -1)
            return false;

        _openNodes.push(node);
        
        var nodeIndex:int = exposedTree.getNodeFlatIndex(node);
        var numExposedNodes:int = exposedTree.open(node);
        var isNodeExposed:Boolean = nodeIndex != -1;
        
        // Only dispatch a collection event if there were nodes added. 
        if (isNodeExposed && numExposedNodes > 0)
        {
            var emptyArr:Array = new Array(numExposedNodes);
            dispatchCollectionChangeEvent(CollectionEventKind.ADD, nodeIndex + 1, -1, emptyArr);
            return true;
        }
        
        return isNodeExposed;
    }
    
    /**
     *  Remove all of the specified node's descendants from this list and mark the
     *  node as "closed".
     *  The node's descendants are assumed to follow the node itself in this IList.
     *  If the node is not exposed, then this method only removes the node from
     *  the set of open nodes. 
     *  If the specified node is not currently open, then this method does nothing.
     * 
     *  <p>Calling this method can cause a <code>CollectionEventKind.REMOVE</code>
     *  <code>CollectionEvent</code> to be dispatched.
     *  Note that the CollectionEvent's <code>items</code> is an empty array with 
     *  length equal to the number of nodes that have been removed.</p>
     * 
     *  @param node An ITreeDataAdapter node.
     * 
     *  FIXME (klin): Probably don't need return value.
     *  @return true if the node is exposed, a branch and was closed.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function closeNode(node:Object):Boolean
    {
        if (!tree || !node || tree.isLeafNode(node)) 
            return false;
        
        var openIndex:int = _openNodes.indexOf(node);
        if (openIndex == -1)
            return false;

        _openNodes[openIndex] = _openNodes[_openNodes.length - 1];
        _openNodes.pop();
        
        var nodeIndex:int = exposedTree.getNodeFlatIndex(node);
        var numHiddenNodes:int = exposedTree.close(node);
        var isNodeExposed:Boolean = nodeIndex != -1;
        
        // Only dispatch a collection event if there were nodes removed. 
        if (isNodeExposed && numHiddenNodes > 0)
        {
            var emptyArr:Array = new Array(numHiddenNodes);
            dispatchCollectionChangeEvent(CollectionEventKind.REMOVE, nodeIndex + 1, -1, emptyArr);
            return true;
        }
        
        return isNodeExposed;
    }

    /**
     *  True, if the specified node is currently open. 
     *  The node may not be exposed.
     * 
     *  @param node An ITreeDataAdapter node.
     * 
     *  @return true, if the node is open. The node need not be exposed to be 
     *  marked open.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function isNodeOpen(node:Object):Boolean
    {
        if (!tree || !node)
            return false;
        
        return _openNodes.indexOf(node) != -1;
    }
    
    /**
     *  Returns true only if this node's parent and ancestors are all opened.
     * 
     *  @param node An ITreeDataAdapter node.
     * 
     *  @return true, if the node's parent and ancestors are all opened or the node
     *  is a root node.
     */
    public function isNodeExposed(node:Object):Boolean
    {
        if (!tree || !node)
            return false;
        
        var nodeIndex:int = this.getItemIndex(node);
        return nodeIndex != -1;
    }
    
    /**
     *  This function replaces any old children of the provided node and
     *  replaces them with its new children.
     *  This function may dispatch a remove CollectionEvent followed by an add
     *  CollectionEvent.
     * 
     *  @param node An ITreeDataAdapter node.
     */
    public function invalidateNode(node:Object):void
    {
        if (!tree || !node)
            return;
        
        // FIXME (klin): need to do more here...
        if (isNodeOpen(node))
        {
            closeNode(node);
            openNode(node);
        }
    }
    
    /**
     *  Handles change events from the tree.
     */
    private function treeDataAdapterChangeHandler(event:TreeDataAdapterChangeEvent):void
    {
        switch (event.kind)
        {
            case TreeDataAdapterChangeEventKind.ADD:
            {
                treeDataAdapterAddHandler(event);
                break;
            }
                
            case TreeDataAdapterChangeEventKind.REMOVE: 
            {
                treeDataAdapterRemoveHandler(event);
                break;
            }
                
            case TreeDataAdapterChangeEventKind.RESET:
            {
                reset();
                break;
            }
        }
    }
    
    /**
     *  @private
     */
    private function treeDataAdapterAddHandler(event:TreeDataAdapterChangeEvent):void
    {
        if (!tree)
            return;
        
        const parent:Object = event.parent;
        const nodes:Vector.<Object> = event.nodes;
        const index:int = event.index;
        const count:int = (nodes) ? nodes.length : 0;
        
        if (count <= 0 || index < 0 || index > (tree.getNodeChildrenCount(parent) - count))
            return;
        
        exposedTree.insertNodesAt(parent, index, count);
        
        if (!parent || (isNodeExposed(parent) && isNodeOpen(parent)))
        {
            dispatchCollectionChangeEvent(CollectionEventKind.ADD,
                                          exposedTree.getNodeFlatIndex(nodes[0]),
                                          -1,
                                          vectorToArray(nodes))
        }
    }
    
    /**
     *  @private
     */
    private function treeDataAdapterRemoveHandler(event:TreeDataAdapterChangeEvent):void
    {
        if (!tree)
            return;
     
        const parent:Object = event.parent;
        const nodes:Vector.<Object> = event.nodes;
        const index:int = event.index;
        const count:int = (nodes) ? nodes.length : 0;
        
        if (count <= 0 || index < 0 || index >= (tree.getNodeChildrenCount(parent) + count))
            return;
        
        var removeCount:int = exposedTree.removeNodesAt(parent, index, count);
        
        if (!parent || (isNodeExposed(parent) && isNodeOpen(parent)))
        {
            // Must use (parent, index) position to get the flat index because
            // the node has been removed.
            // This should still work if index == tree.getNodeChildrenCount(parent).
            var removeIndex:int = exposedTree.getFlatIndex(parent, index);
            var emptyArr:Array = new Array(removeCount);
            dispatchCollectionChangeEvent(CollectionEventKind.REMOVE,
                                          removeIndex,
                                          -1,
                                          emptyArr)
        }
    }
    
    //--------------------------------------------------------------------------
    //
    //  IList Implementation (read-only)
    // 
    //--------------------------------------------------------------------------
    
    /**
     *  @inheritDoc
     *     
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function get length():int
    {
        if (!tree)
            return 0;
        
        return exposedTree.length;
    }
    
    /**
     *  @inheritDoc
     *     
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function getItemAt(index:int, prefetch:int=0):Object
    {
        if (!tree)
            return null;
        
        if (index < 0 || index >= length)
        {
            var message:String = ResourceManager.getInstance().getString(
                "collections", "outOfBounds", [ index ]);
            throw new RangeError(message);
        }
        
        return exposedTree.getNodeAt(index);
    }
    
    
    /**
     *  @inheritDoc
     *     
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function getItemIndex(item:Object):int
    {
        if (!tree || !item)
            return -1;
        
        return exposedTree.getNodeFlatIndex(item);
    }
    
    /**
     *  @inheritDoc
     *     
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function itemUpdated(item:Object, property:Object=null, oldValue:Object=null, newValue:Object=null):void
    {
        const pce:PropertyChangeEvent = new PropertyChangeEvent(PropertyChangeEvent.PROPERTY_CHANGE);
        pce.kind = PropertyChangeEventKind.UPDATE;
        pce.source = item;
        pce.property = property;
        pce.oldValue = oldValue;
        pce.newValue = newValue;
        dispatchCollectionChangeEvent(CollectionEventKind.UPDATE, -1, -1, [pce]);
    }
    
    /**
     *  @override
     *  
     *  Note: It is not recommended that components which use TreeList call toArray
     *  because of performance reasons. 
     * 
     *  Returns an Array that is populated in the same order as the IList
     *  implementation.
     *  This method can throw an ItemPendingError.
     *
     *  @return The array.
     *  
     *  @throws mx.collections.errors.ItemPendingError If the data is not yet completely loaded
     *  from a remote location.
     *     
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function toArray():Array
    {
        const length:int = this.length;
        if (!tree || length == 0)
            return [];
        
        var arr:Array = new Array(length);
        for (var i:int = 0; i < length; i++) 
        {
            arr[i] = getItemAt(i);            
        }
        
        return arr;
    }

    /**
     *  @override
     *  
     *  This method is not supported in TreeList.
     *  Mutation should be done through the tree adapter.
     *     
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function addItem(item:Object):void
    {
        // addItem not supported in TreeList
    }
    
    /**
     *  @override
     *  
     *  This method is not supported in TreeList.
     *  Mutation should be done through the tree adapter.
     *     
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function addItemAt(item:Object, index:int):void
    {
        // addItemAt not supported in TreeList
    }
    
    /**
     *  @override
     *  
     *  This method is not supported in TreeList.
     *  Mutation should be done through the tree adapter.
     *     
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function removeAll():void
    {
        // removeAll is not supported in TreeList
    }

    /**
     *  @override
     *  
     *  This method is not supported in TreeList.
     *  Mutation should be done through the tree adapter.
     *     
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function removeItemAt(index:int):Object
    {
        // removeItemAt is not supported in TreeList
        return null;
    }
    
    /**
     *  @override
     *  
     *  This method is not supported in TreeList.
     *  Mutation should be done through the tree adapter.
     *     
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function setItemAt(item:Object, index:int):Object
    {
        // setItemAt is not supported in TreeList
        return null;
    }
}
}

//--------------------------------------------------------------------------
//
//  TreeNode
//
//--------------------------------------------------------------------------

/**
 *  A sparse representation of a tree adapter node and its children.
 *  Stores the tree adapter node, whether the node is open, the number of exposed descendants, and
 *  a sparse list of possibly open children.
 *  If the node is open, numExposedDescendants should be set to the number of descendants exposed
 *  by this node.
 *  If the node is closed, numExposedDescendants is 0.
 *  The children vector can be sparsely populated by TreeNode representations of the tree adapter
 *  node's children.
 *  Typically, the children vector will only contain nodes that are opened.
 *  The pseudo-root (root of roots) is represented by a TreeNode with a null node property.
 *  
 *  <p>In our implementation, all exposed and open nodes are represented with the tree of TreeNodes. 
 *  The exposed nodes may be calculated by walking the tree of TreeNodes.
 *  Exposed nodes are defined as nodes where its ancestors and parent are all open.
 *  Thus, some open nodes represented within the tree of TreeNodes may not be exposed.</p>
 */
class TreeNode
{
    /**
     *  Constructor.
     */
    public function TreeNode(node:Object = null, siblingIndex:int = -1,
                             isOpen:Boolean = false, numExposedDescendants:int = 0)
    {
        this.node = node;
        this.siblingIndex = siblingIndex;
        this.isOpen = isOpen;
        this.numExposedDescendants = numExposedDescendants;
    }
               
    public var node:Object;
    public var siblingIndex:int; // index relative to its siblings, from tree.getNodeChildIndex().
    public var children:Vector.<TreeNode> = new Vector.<TreeNode>(); // possible open children
    public var isOpen:Boolean;
    public var numExposedDescendants:int; 
    
    /**
     *  Inserts a child TreeNode into this TreeNode's children vector
     *  in ascending sibling index order.
     */
    public function addTreeNode(node:TreeNode):void
    {
        var children:Vector.<TreeNode> = this.children;
        var childrenLength:int = children.length;
        
        for (var j:int = 0; j < childrenLength; j++) 
        {
            if (children[j].siblingIndex > node.siblingIndex)
            {
                children.splice(j, 0, node);
                return;
            }
        }
        
        children.splice(childrenLength, 0, node);
    }
    
    /**
     *  Returns the TreeNode corresponding to the specified node.
     */
    public function findTreeNode(node:Object):TreeNode
    {
        for each (var tn:TreeNode in children)
        {
            if (tn.node == node)
                return tn;
        }
        
        return null;
    }
}

import spark.collections.ITreeDataAdapter;

//--------------------------------------------------------------------------
//
//  ExposedTree
//
//--------------------------------------------------------------------------

/**
 *  A sparse representation of the exposed part of the tree.
 *  Also keeps track of open nodes even if they are not exposed.
 *  Enables basic operations like expanding/collapsing subtrees and handling tree adapter changes.
 *  In our implementation, all exposed and open nodes are represented in this list.
 *  Exposed nodes are defined as nodes where its ancestors and parent are all open.
 *  Thus, some open nodes represented within the ExposedTree may not be exposed.
 * 
 *  The ExposedTree also can calculate the position of a node in the flattened tree (a node's "flat
 *  index") and vice versa.
 *  ExposedTree.getNodeFlatIndex() calculates the flat index of a provided node.
 *  An ExposedTreeIterator is used to find a node based on its index.
 *  The iterator is used to optimize for the case when getItemAt() is called with consecutive
 *  indices (e.g. [1, 2, 3, 4, 5]).
 */
final class ExposedTree
{
    
    /**
     *  Constructor.
     */
    public function ExposedTree(tree:ITreeDataAdapter = null)
    {
        this.tree = tree;
        reset();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    /**
     *  The pseudo-root of the tree.
     *  This invisible root is just for convenience when working with trees with multiple roots.
     */
    private var root:TreeNode;
    
    //----------------------------------
    //  tree
    //----------------------------------
    
    private var _tree:ITreeDataAdapter;
    
    /**
     *  The underlying tree this ExposedTree represents.
     */
    public function get tree():ITreeDataAdapter
    {
        return _tree;
    }
    
    /**
     *  @private
     */    
    public function set tree(value:ITreeDataAdapter):void
    {
        _tree = value;
        reset();
    }
    
    //----------------------------------
    //  length
    //----------------------------------
    
    /**
     *  The number of currently exposed nodes.
     */
    public function get length():int
    {
        return root.numExposedDescendants;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Utility Methods
    //
    //--------------------------------------------------------------------------
    
    private var iterator:ExposedTreeIterator;
    private var lastNode:Object;
    private var lastNodeFlatIndex:int = -1;
    
    /**
     *  Clears bookmarks used by the ExposedTree to speed up getNodeAt() and getNodeFlatIndex().
     */
    private function clearBookmarks():void
    {
        // iterator used by getNodeAt().
        iterator = null;
        
        // (node, index) pair used by getNodeFlatIndex().
        lastNode = null;
        lastNodeFlatIndex = -1;
    }
    
    /**
     *  Resets the ExposedTree.
     *  Creates a new pseudo-root and exposes the roots of the tree adapter.
     */
    private function reset():void
    {
        if (!root)
        {
            root = new TreeNode(null, 0, true, 0);
        }
        else
        {
            root.children = new Vector.<TreeNode>();
            root.numExposedDescendants = 0;
        }
        
        if (tree)
            root.numExposedDescendants = tree.getNodeChildrenCount(null);
        
        clearBookmarks();
    }
    
    /**
     *  Returns path to specified node.
     *  (ex. [root, p0, p1, p2, ..., node])
     */
    private function nodeToTreePath(node:Object):Vector.<Object>
    {
        if (!tree || !node)
            return null;
        
        var path:Vector.<Object> = new Vector.<Object>();
        var p:Object = tree.getNodeParent(node);
        
        path.push(node);
        while (p)
        {
            path.push(p);
            p = tree.getNodeParent(p);
        }
        
        return path.reverse();
    }
    
    /**
     *  Returns a vector of TreeNodes corresponding to the path from the root TreeNode
     *  to the parent corresponding to the specified node (e.g. [root, ..., node's parentTN]).
     *  If any TreeNode does not exist along the way, this method returns null.
     * 
     *  <p>If includeNode is true, the TreeNode representing the specified node is also included 
     *  (e.g. [root, ..., node's parentTN, node's TN]), but if the node's TreeNode does not exist, 
     *  this method will return null.</p>
     * 
     *  <p>If carvePath is true, TreeNodes are created when not found along the way including the
     *  node's TreeNode (e.g. [root, ..., tn.parentTN, tn]).
     *  When carvePath is true, this method should not return null as long as the node is in 
     *  the tree.</p>
     */
    private function nodeToTreeNodePath(node:Object, includeNode:Boolean = false,
                                        carvePath:Boolean = false):Vector.<TreeNode>
    {
        if (!tree)
            return null;
        
        if (!node)
            return (includeNode) ? new <TreeNode>[root] : new <TreeNode>[];
        
        var path:Vector.<Object> = nodeToTreePath(node);
        if (!path)
            return null;
        
        // The path always includes "node". While we're building the TreeNode path,
        // we only include and create a TreeNode for that "node" if carvePath is true.
        var pathLength:int = (includeNode) ? path.length : path.length - 1;
        var treeNodePath:Vector.<TreeNode> = new Vector.<TreeNode>(pathLength + 1);
        var tn:TreeNode = root;
        treeNodePath[0] = tn;
        
        for (var i:int = 0; i < pathLength; i++) 
        {
            var pn:TreeNode = tn;
            var n:Object = path[i];
            tn = tn.findTreeNode(n);
            
            if (!tn)
            {
                if (carvePath)
                {
                    tn = new TreeNode(n, tree.getNodeChildIndex(n));
                    pn.addTreeNode(tn);
                }
                else
                {
                    // This node is not exposed, so there is no TreeNode path.
                    return null;
                }
            }
            
            treeNodePath[i+1] = tn;
        }
        
        return treeNodePath;
    }
    
    /**
     *  Updates each TreeNode's numExposedDescendants property along the provided path by adding
     *  the specified delta.
     *  The deepest node is always updated, and we walk up the tree updating open 
     *  ancestors until we find an ancestor that is closed.
     */
    private function updateTreeNodePath(treeNodePath:Vector.<TreeNode>, delta:int):void
    {
        if (!treeNodePath)
            return;
        
        var pathLength:int = treeNodePath.length;
        var tn:TreeNode = treeNodePath[pathLength - 1];
        
        // The deepest node always needs to be updated because 
        // it is assumed to have changed.
        tn.numExposedDescendants += delta;
        
        for (var i:int = pathLength - 2; i >= 0; i--) 
        {
            tn = treeNodePath[i];
            if (!tn.isOpen)
                break;
            tn.numExposedDescendants += delta;
        }
    }
    
    //--------------------------------------------------------------------------
    //
    //  Public Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Returns the node with the specified flat index.
     *  Optimized for sequential calls (e.g. 5, 6, 7, 8, ...).
     */
    public function getNodeAt(flatIndex:int):Object
    {
        if (!tree || flatIndex < 0 || flatIndex >= length)
            return null;
        
        if (!iterator)
            iterator = new ExposedTreeIterator(root, this, tree);
        
        if (iterator.previousIndex == flatIndex)
            return iterator.previousNode;
        
        iterator.seek(flatIndex); // no-op if iterator is already there.
        return iterator.next();
    }
    
    /**
     *  Returns the list index in the flattened tree of the specified position
     *  in the tree.
     *  This method also happens to "work" if siblingIndex >= tree.getNodeChildrenCount(parent),
     *  which is useful in cases where the original node at siblingIndex was removed from the tree.
     */
    public function getFlatIndex(parent:Object, siblingIndex:int):int
    {
        // path to parent TreeNode
        var treeNodePath:Vector.<TreeNode> = nodeToTreeNodePath(parent, true);
        if (!treeNodePath)
            return -1;
        
        // index = -1 for pseudo-root node ("root" property).
        // for each node in the tree path:
        // index = (index + 1) + siblingIndex + 
        //   SUM(openChild's numExposedDescendants if openChild's index is < siblingIndex)
        var index:int = -1;
        var pathLength:int = treeNodePath.length;
        
        for (var i:int = 0; i < pathLength; i++) 
        {
            // find the siblingIndex of the next node in the path.
            // add that to the index
            // add 1 for the current node in the path.
            var j:int = i + 1;
            var childSiblingIndex:int = (j < pathLength) ?
                                        tree.getNodeChildIndex(treeNodePath[j].node) :
                                        siblingIndex;
            index += 1 + childSiblingIndex;
            
            // add exposed descendants for any open siblings whose index < childSiblingIndex
            var pn:TreeNode = treeNodePath[i];
            var pnChildren:Vector.<TreeNode> = pn.children;
            for each (var tn:TreeNode in pnChildren)
            {
                var tnSiblingIndex:int = tn.siblingIndex;
                
                if (tn.isOpen && (tnSiblingIndex < childSiblingIndex))
                    index += tn.numExposedDescendants;
                else if (tnSiblingIndex >= childSiblingIndex)
                    break;
            }
        }
        
        return index;
    }
    
    /**
     *  Returns the list index in the flattened tree of the specified node.
     *  This just uses getFlatIndex().
     */
    public function getNodeFlatIndex(node:Object):int
    {
        if (!tree || !node)
            return -1;

        // Use bookmarks to optimize this.
        if (lastNode && lastNode == node)
            return lastNodeFlatIndex;
        else if (iterator && iterator.previousNode == node)
            return iterator.previousIndex;

        var index:int = getFlatIndex(tree.getNodeParent(node), tree.getNodeChildIndex(node));
        if (index != -1)
        {
            lastNode = node;
            lastNodeFlatIndex = index;
        }
        return index;
    }

    
    /**
     *  Opens the specified node including any subtrees.
     *  Returns the number of descendants that have been exposed.
     */
    public function open(node:Object):int
    {
        if (!tree || !node)
            return 0;
        
        var treeNodePath:Vector.<TreeNode> = nodeToTreeNodePath(node, true, true);
        if (!treeNodePath)
            return 0;
        
        // The last TreeNode in the path represents the node that is being opened.
        var tn:TreeNode = treeNodePath[treeNodePath.length - 1];
        var count:int = tree.getNodeChildrenCount(tn.node);
        var children:Vector.<TreeNode> = tn.children;
        for each (var child:TreeNode in children)
        {
            count += child.numExposedDescendants;
        }
        tn.isOpen = true;
        updateTreeNodePath(treeNodePath, count);
        clearBookmarks();
        
        return tn.numExposedDescendants;
    }
    
    /**
     *  Closes the specified node including any subtrees.
     *  Returns the number of descendants that have been hidden.
     */
    public function close(node:Object):int
    {
        if (!tree || !node)
            return 0;
        
        var treeNodePath:Vector.<TreeNode> = nodeToTreeNodePath(node, true, true);
        if (!treeNodePath)
            return 0;
        
        // The last TreeNode in the path represents the node that is being closed.
        var tn:TreeNode = treeNodePath[treeNodePath.length - 1];
        var numRemovedExposedNodes:int = tn.numExposedDescendants;
        tn.isOpen = false;
        updateTreeNodePath(treeNodePath, -numRemovedExposedNodes);
        clearBookmarks();
        
        return numRemovedExposedNodes;
    }
    
    /**
     *  Updates the ExposedTree to include the block of inserted nodes.
     *  The insertIndex refers to the sibling-relative index where the insertion occurred.
     *  It is not a list index.
     */
    public function insertNodesAt(parent:Object, insertIndex:int, count:int):void
    {
        var treeNodePath:Vector.<TreeNode> = nodeToTreeNodePath(parent, true);
        if (!treeNodePath)
            return;
        
        // update sibling indices in children.
        var parentTN:TreeNode = treeNodePath[treeNodePath.length - 1];
        var children:Vector.<TreeNode> = parentTN.children;
        var childrenLength:int = children.length;
        for (var i:int = 0; i < childrenLength; i++) 
        {
            var childTN:TreeNode = children[i];
            if (childTN.siblingIndex >= insertIndex)
                childTN.siblingIndex += count;
        }
        
        // Update the parent and ancestors' numExposedDescendants
        updateTreeNodePath(treeNodePath, count);
        clearBookmarks();
    }
    
    /**
     *  Updates the ExposedTree to remove the block of inserted nodes and their subtrees.
     *  The removeIndex refers to the sibling-relative index where the removal occurred.
     *  It is not a list index.
     *  Returns the actual number of descendant nodes removed.
     */
    public function removeNodesAt(parent:Object, removeIndex:int, count:int):int
    {
        var treeNodePath:Vector.<TreeNode> = nodeToTreeNodePath(parent, true);
        if (!treeNodePath)
            return 0;
        
        // remove any children TreeNodes in the specified range, and update the indices of
        // children after the removed ones.
        var parentTN:TreeNode = treeNodePath[treeNodePath.length - 1];
        var removeEndIndex:int = removeIndex + count;
        var children:Vector.<TreeNode> = parentTN.children;
        var childrenLength:int = children.length;
        var spliceStart:int = -1;
        var spliceCount:int = 0;
        var totalRemovedNodes:int = 0;
        for (var i:int = 0; i < childrenLength; i++) 
        {
            var childTN:TreeNode = children[i];
            var siblingIndex:int = childTN.siblingIndex;
            if (siblingIndex >= removeIndex && siblingIndex < removeEndIndex)
            {
                if (spliceStart < 0)
                    spliceStart = i;
                spliceCount++;
                totalRemovedNodes += childTN.numExposedDescendants;
            }
            else if (siblingIndex >= removeEndIndex)
            {
                childTN.siblingIndex -= count;
            }
        }
        children.splice(spliceStart, spliceCount);
        totalRemovedNodes += count;
        
        // Update the parent and ancestors' numExposedDescendants
        updateTreeNodePath(treeNodePath, -totalRemovedNodes);
        clearBookmarks();
        return totalRemovedNodes;
    }
}

//--------------------------------------------------------------------------
//
//  ExposedTreePosition
//
//--------------------------------------------------------------------------

/**
 *  Represents a position in the tree.
 *  Each position is represented by an open parent and index to child.
 */
final class ExposedTreePosition
{
    public var parent:TreeNode;
    public var nextChildIndex:int = 0;
    
    /**
     *  Index used to find the next open child.
     *  This is the index into parent.children. Not tree.getNodeChildIndex().
     */
    public var nextExposedTreeChildIndex:int = 0;
    
    /**
     *  Returns the next open TreeNode in parent.children whose index is
     *  >= nextExposedTreeChildIndex.
     */
    public function get nextExposedTreeChild():TreeNode
    {
        var children:Vector.<TreeNode> = parent.children;
        var childrenLength:int = children.length;
        
        for (var i:int = nextExposedTreeChildIndex; i < childrenLength; i++) 
        {
            var child:TreeNode = children[i];
            if (child.isOpen)
            {
                nextExposedTreeChildIndex = i;
                return child;
            }
        }
        return null;
    }
}

//--------------------------------------------------------------------------
//
//  ExposedTreeIterator
//
//--------------------------------------------------------------------------

/**
 *  Iterator used to efficiently do an inorder traversal of an ExposedTree
 *  (see ExposedTree.getNodeAt()).
 *  The traversal starts at the first root node in the tree (index == 0).
 *  When next() is called, the node at the current index is returned and iterator moves
 *  to the next node.
 */
final class ExposedTreeIterator
{
    
    /**
     *  Constructor.
     */
    public function ExposedTreeIterator(root:TreeNode,
                                        exposedTree:ExposedTree,
                                        tree:ITreeDataAdapter)
    {
        this.rootTreeNode = root;
        this.exposedTree = exposedTree;
        this.tree = tree;
        reset();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    
    private var rootTreeNode:TreeNode;
    private var exposedTree:ExposedTree;
    private var tree:ITreeDataAdapter;
    
    /**
     *  When next() is called, the node at the current index is returned and
     *  the current index is incremented.
     *  When calling TreeList.getItemAt(index), index == currentFlatIndex - 1 because the iterator
     *  considers TreeList.root (the "pseudo-root") to be the node at index 0.
     */
    private var currentFlatIndex:int;
    
    /**
     *  Stack of positions in the tree.
     *  Each position is represented by an open parent and index to child.
     *  As the iterator advances, it returns the child and increments the index.
     *  When no more children are left to visit for a position, the position gets popped off
     *  the stack.
     *  If the current child is an open node, the iterator pushes a new position
     *  using that child onto the stack.
     */
    private var positionStack:Vector.<ExposedTreePosition>;
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    private var _previousNode:Object;
    
    /**
     *  The last object returned by next().
     */
    public function get previousNode():Object
    {
        return _previousNode;
    }
    
    /**
     *  The flat index of previousNode.
     */
    public function get previousIndex():int
    {
        return currentFlatIndex - 2;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Returns true if the next tree adapter node exists.
     */
    public function hasNext():Boolean
    {
        // exposedTree.length doesn't include the pseudo-root, but our "nextFlatIndex" does include
        // pseudo-root (at index 0). So, we subtract 1.
        return currentFlatIndex - 1 < exposedTree.length;
    }
    
    /**
     *  Returns the next node in the traversal.
     */
    public function next():Object
    {
        var currentPosition:ExposedTreePosition = positionStack[positionStack.length - 1];
        var currentNode:Object = tree.getNodeChildAt(currentPosition.parent.node,
                                                     currentPosition.nextChildIndex);
        
        _previousNode = currentNode;
        currentFlatIndex++;
        
        if (!hasNext())
            return currentNode;
        
        var nextOpenChild:TreeNode = currentPosition.nextExposedTreeChild;
        currentPosition.nextChildIndex++;
        
        // If no more children to visit, then pop back up.
        var treeNumChildren:int = tree.getNodeChildrenCount(currentPosition.parent.node);
        if (currentPosition.nextChildIndex == treeNumChildren)
        {
            positionStack.pop();
            currentPosition = null;
        }
        
        // If we are currently at an open child, then push the open child.
        if (nextOpenChild && currentNode == nextOpenChild.node)
        {
            // Current position may be null if we just popped it above. In that case,
            // we don't need to update.
            if (currentPosition)
                currentPosition.nextExposedTreeChildIndex++;
            
            // We push only if there are more children to visit.
            if (tree.getNodeChildrenCount(nextOpenChild.node) > 0)
            {
                var nextPosition:ExposedTreePosition = new ExposedTreePosition();
                nextPosition.parent = nextOpenChild;
                positionStack.push(nextPosition);
            }
        }
        
        return currentNode;
    }
    
    /**
     *  Resets the iterator to point at the first root node in the tree.
     *  Thus, the iterator always starts at currentFlatIndex==1 because the iterator
     *  considers TreeList.root (the "pseudo-root") to be the node at index 0.
     */
    private function reset():void
    {
        positionStack = new Vector.<ExposedTreePosition>();
        var rootPosition:ExposedTreePosition = new ExposedTreePosition();
        rootPosition.parent = this.rootTreeNode;
        positionStack.push(rootPosition);
        currentFlatIndex = 1;
    }
    
    /**
     *  Moves the iterator such that to point to the node at the specified index.
     *  This is equivalent to populating the positionStack such that
     *  currentFlatIndex = index + 1. 
     */
    public function seek(index:int):void
    {
        // Adjust index. Iterator's definition of "flat index" is offset by 1 from the actual list
        // index such that list index == iterator index - 1 because the ExposedTree's "root" is
        // considered by the iterator to be at position 0.
        var targetFlatIndex:int = index + 1;
        
        // Already there, so do nothing.
        if (targetFlatIndex == this.currentFlatIndex)
            return;
        
        reset();
        
        seekToPosition(targetFlatIndex);
    }
    
    /**
     *  Helper method used by seek to position the iterator at the target index.
     *  This method recursively pushes positions until the positionStack is populated
     *  with the correct positions such that next() will return the node at the target index.
     */
    private function seekToPosition(targetIndex:int):void
    {
        var currentPosition:ExposedTreePosition = positionStack[positionStack.length - 1];
       
        var openChildren:Vector.<TreeNode> = currentPosition.parent.children;
        var openChildrenLength:int = openChildren.length;
        var lastChild:TreeNode;
        
        // Simple case for no open children.
        if (openChildrenLength == 0)
        {
            currentPosition.nextChildIndex = targetIndex - currentFlatIndex;
            currentFlatIndex = targetIndex;
            return;
        }
        
        // We iterate over the open children.
        for (var i:int = 0; i < openChildrenLength; i++) 
        {
            // "child" is the current open node in the ExposedTree. "lastChild" is the previous.
            // At this point, currentFlatIndex is the flat index of "lastChild".
            var child:TreeNode = openChildren[i];
            
            if (child.isOpen)
            {
                // Move currentFlatIndex to point to this open child.
                currentFlatIndex += child.siblingIndex -
                                    (lastChild ? lastChild.siblingIndex + 1 : 0);
                
                if (targetIndex <= currentFlatIndex)
                {
                    // Case 1: If the target index is between the lastChild and child (including
                    // child), then calculate the correct index and return.
                    currentPosition.nextChildIndex = child.siblingIndex -
                                                     (currentFlatIndex - targetIndex);
                    currentFlatIndex = targetIndex;
                    return;
                }
                else
                {
                    // Advance position and currentFlatIndex to point to "child".
                    currentPosition.nextChildIndex = child.siblingIndex + 1;
                    currentPosition.nextExposedTreeChildIndex = i + 1;
                    currentFlatIndex++;
                    
                    // If the target index is within the subtree of "child".
                    if (targetIndex < (currentFlatIndex + child.numExposedDescendants))
                    {
                        // If we're done with currentPosition, clear it off the stack before continuing.
                        if (currentPosition.nextChildIndex == tree.getNodeChildrenCount(currentPosition.parent.node))
                        {
                            positionStack.pop();
                            currentPosition = null;
                        }
                        
                        // Go into "child" subtree.
                        var nextPosition:ExposedTreePosition = new ExposedTreePosition();
                        nextPosition.parent = child;
                        positionStack.push(nextPosition);
                        
                        // Call recursively.
                        seekToPosition(targetIndex);
                        return;
                    }
                    else
                    {
                        currentFlatIndex += child.numExposedDescendants;
                    }
                }
                
                lastChild = child;
            }
            
        }
        
        // The target index is in the current position, but beyond the last open child.
        currentPosition.nextChildIndex += targetIndex - currentFlatIndex;
        currentFlatIndex = targetIndex;
    }
}