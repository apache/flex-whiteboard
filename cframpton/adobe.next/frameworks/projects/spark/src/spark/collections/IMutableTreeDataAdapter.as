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

/**
 *  Dispatched when the IMutableTreeDataAdapter has been updated in some way.
 *
 *  @eventType spark.events.TreeDataAdapterChangeEvent.TREE_DATA_ADAPTER_CHANGE
 * 
 *  @langversion 3.0
 *  @playerversion Flash 11
 *  @playerversion AIR 3.0
 *  @productversion Flex 5
 */
[Event(name="treeDataAdapterChange", type="spark.events.TreeDataAdapterChangeEvent")]

/**
 *  The IMutableTreeDataAdapter interface defines the required methods for
 *  manipulating the structure and nodes of a tree adapter.
 *  An implementation of IMutableTreeDataAdapter must also dispatch 
 *  <code>TreeDataAdapterChangeEvents</code> to notify other components that the
 *  tree structure or underlying data has changed.
 * 
 *  @langversion 3.0
 *  @playerversion Flash 11
 *  @playerversion AIR 3.0
 *  @productversion Flex 5
 */
public interface IMutableTreeDataAdapter extends ITreeDataAdapter
{
    /**
     *  Inserts the provided nodes as children of the parent node
     *  starting at the specified index.
     * 
     *  @param parent A tree adapter node.
     * 
     *  @param nodes The nodes to insert as children of the
     *  <code>parent</code>. If parent is null, the nodes are inserted
     *  as root nodes.
     * 
     *  @param index The index at which to insert the nodes.
     *  
     *  @throws RangeError if index is less than 0 or is greater than
     *  <code>getNodeChildrenCount(parent)</code>.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5
     */  
    function addNodeChildrenAt(parent:Object, index:int, nodes:Vector.<Object>):void; 
    
    /**
     *  Removes <code>count</code> number of children nodes starting
     *  at the specified index.
     *  If <code>parent</code> is null, then removes <code>count</code>
     *  root nodes starting at the specified index.
     * 
     *  @param parent A tree adapter node.
     * 
     *  @param index The index at which to remove the children.
     * 
     *  @param count The number of children to remove from <code>parent</code>.
     * 
     *  @return A vector of the nodes that were removed.
     * 
     *  @throws RangeError if index is less than 0, or if index or index + count is
     *  greater than <code>getNodeChildrenCount(parent)</code>.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5
     */  
    function removeNodeChildrenAt(parent:Object, index:int, count:int):Vector.<Object>;
}
}