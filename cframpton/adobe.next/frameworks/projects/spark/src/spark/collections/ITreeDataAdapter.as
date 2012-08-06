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
import flash.events.IEventDispatcher;

/**
 *  Exposes an arbitrary data structure as a set of trees, where each tree
 *  node has a parent and an ordered set of children.
 *  ITreeDataAdapter implementations are intended to be used with the Spark Tree
 *  component.
 * 
 *  <p>The methods in this interface operate on Object type "nodes" associated
 *  with this tree adapter.
 *  This class "adapts" an existing data structure as a tree without requiring
 *  the data structure to implement or subclass a special type (like a tree or
 *  a tree node class).
 *  For example, an application with typed objects as data can use the Spark
 *  Tree with a custom tree adapter without modifying the object's type.
 *  One need not wrap the underlying data structure's nodes with a node type
 *  defined here.
 *  If the underlying data's nodes already have parent and children properties,
 *  the corresponding ITreeDataAdapter implementation only needs to provide access
 *  to each child node.</p>
 * 
 *  <p>This interface treats root nodes as any node with a null parent (i.e.
 *  <code>getNodeParent(node)</code> returns null).
 *  The root nodes of the tree should be accessed by passing in a null <code>parent</code>.
 *  For example, <code>getNodeChildrenCount(null)</code> will return the number of root nodes and
 *  <code>getNodeChildAt(null, index)</code> returns the root node at the specified index.</p>
 * 
 *  <p>Cycles are not permitted: each child node may only appear in only once in the tree.</p>
 * 
 *  <p>ITreeDataAdapter defines read-only operations on the nodes.
 *  Implementations may allow changing the structure of the tree, but the adapter should dispatch
 *  corresponding TreeDataAdapterChangeEvents when changes occur to notify dependent components.
 *  Some manipulation methods are defined by the IMutableTreeDataAdapter interface.
 *  These methods are the ones used by Flex components to change the tree's structure.</p>
 *
 *  @langversion 3.0
 *  @playerversion Flash 11
 *  @playerversion AIR 3.0
 *  @productversion Flex 5
 */
public interface ITreeDataAdapter extends IEventDispatcher
{
    /**
     *  Returns the parent of the specified tree adapter node.
     *  Returns null if the specified node is a root node or null.
     * 
     *  @param node A tree adapter node.
     * 
     *  @return The parent of the specified node. Null, if the node is a root node
     *  or if the node is null.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5
     */      
    function getNodeParent(node:Object):Object;
    
    /**
     *  True if the type of the node is limited to being a leaf node, i.e. it
     *  will never have children.
     *  For example, if this adapter represented a file system, then files
     *  would be leaf nodes and directories, even empty directories, would not.
     *  If the node is null, this method returns false.
     * 
     *  @param node A tree adapter node.
     * 
     *  @return True if the node is a leaf node. If the node is null, returns false.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5
     */  
    function isLeafNode(node:Object):Boolean;

    /**
     *  Returns the number of children of the specified parent node.
     *  Returns the number of root nodes, if parent is null.
     *  Returns 0, if <code>isLeafNode(parent)</code> is true.
     * 
     *  @param parent A tree adapter node.
     * 
     *  @return The number of children of the parent node. The number of root
     *  nodes if parent is null. 0, if <code>isLeafNode(parent)</code> is true.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5
     */  
    function getNodeChildrenCount(parent:Object):int;
    
    /**
     *  Returns the zero-indexed position of the specified node
     *  within the context of its parent.
     * 
     *  @param node A tree adapter node.
     * 
     *  @return The zero-indexed position of the provided node, -1 if
     *  the node is invalid.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5
     */  
    function getNodeChildIndex(node:Object):int;
    
    /**
     *  Returns the child node at the specified position.
     *  If parent is null, returns the root node at the specified position.
     *  Throws a RangeError if the index is invalid.
     *
     *  @param parent A tree adapter node. If null, a root node
     *  at the specified index will be returned.
     * 
     *  @param index The index in the children list from which to retrieve the node.
     * 
     *  @return The child node at the specified position. If parent is null, then
     *  this method returns the root node at the specified position.
     * 
     *  @throws RangeError if <code>index &lt; 0</code> or <code>index >= length</code>.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5
     */  
    function getNodeChildAt(parent:Object, index:int):Object;
    
    /**
     *  Returns the number of parent ancestors between this node and a root node.
     *  The depth of a root node is 0.
     *  Returns -1, if the specified node is null.
     * 
     *  @param node A tree adapter node.
     * 
     *  @return The number of parent ancestors between this node and a root
     *  node, -1 if node doesn't have a root node ancestor.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5
     */ 
    function getNodeDepth(node:Object):int;
}
}