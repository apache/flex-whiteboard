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

import mx.resources.IResourceManager;
import mx.resources.ResourceManager;

import spark.events.TreeDataAdapterChangeEvent;
import spark.events.TreeDataAdapterChangeEventKind;

//--------------------------------------
//  Events
//--------------------------------------

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

//--------------------------------------
//  Other metadata
//--------------------------------------

[DefaultProperty("rootNodes")]

/**
 *  The XMLTreeAdapter class is an ITreeAdapter implementation that adapts
 *  XML objects to be used in Flex components.
 * 
 *  <p>XML with no child tags is treated as a leaf.
 *  The only exception is if it has the "isBranch" attribute set to "true".</p>
 * 
 *  @langversion 3.0
 *  @playerversion Flash 11
 *  @playerversion AIR 3.0
 *  @productversion Flex 5
 */
public class XMLTreeDataAdapter extends EventDispatcher implements IMutableTreeDataAdapter
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
     *  @param rootNodes An XMLList of the root nodes. By default, this is set to an empty list.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5
     */
    public function XMLTreeDataAdapter(rootNodes:XMLList = null)
    {
        this.rootNodes = rootNodes;
    }
    
    //--------------------------------------------------------------------------
    //
    // Variables
    // 
    //--------------------------------------------------------------------------
    
    /**
     *  Used for accessing localized Error messages.
     */
    private var resourceManager:IResourceManager =
        ResourceManager.getInstance();
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  rootNodes
    //----------------------------------
    
    private var _rootNodes:XMLList;
    
    [Bindable("rootNodesChanged")]
    
    /**
     *  An XMLList containing the root nodes.
     *  The adapter does not track changes to the provided XMLList.
     *  If the list changes, this property will need to be set again.
     * 
     *  @default an empty XMLList
     * 
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5
     */
    public function get rootNodes():XMLList
    {
        return _rootNodes.copy();
    }
    
    /**
     *  @private
     */
    public function set rootNodes(value:XMLList):void
    {
        // Defensively copy the incoming value; tolerate null value
        const valueCopy:XMLList = (value) ? value.copy() : new XMLList();
        
        _rootNodes = valueCopy;
        
        dispatchTreeAdapterChangeEvent(TreeDataAdapterChangeEventKind.RESET);
        dispatchChangeEvent("rootNodesChanged");
    }
    
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Helper function to dispatch change events only
     *  when someone's listening.
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
    private function dispatchTreeAdapterChangeEvent(
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
     *  Throws a RangeError if the index is invalid.
     */ 
    private function checkIndex(index:int, list:XMLList):void
    {
        if (index < 0 || index >= list.length())
        {
            var message:String = resourceManager.getString(
                "collections", "outOfBounds", [ index ]);
            throw new RangeError(message);
        }
    }
    
    //--------------------------------------------------------------------------
    //
    //  ITreeAdapter Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @inheritDoc
     * 
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5
     */
    public function getNodeParent(node:Object):Object
    {
        if (!node || !(node is XML) || _rootNodes.contains(node))
            return null;
        
        return node.parent();
    }
    
    /**
     *  @inheritDoc
     * 
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5
     */
    public function isLeafNode(node:Object):Boolean
    {
        if (!node || !(node is XML))
            return false;
        
        // FIXME (klin): Should we generalize this? (e.g. "branchAttr"?)
        var branchFlag:XMLList = node.@isBranch;
        if (branchFlag.length() == 1)
        {
            //check flag and return
            if (branchFlag[0] == "true")
                return false;
            else (branchFlag[0] == "false")
                return true;
        }
        
        return node.children().length() == 0;
    }
    
    /**
     *  Checks to see if a node is a branch.
     *  A node is a branch if it is non-null and isLeafNode(node) is false.
     *  Passing in null always returns true.
     */
    private function isBranchNode(node:Object):Boolean
    {
        // null node always returns true, because null means the "parent" of the root nodes.
        if (!node)
            return true;
        
        if (node && (node is XML) && !isLeafNode(node))
            return true;
        
        return false;
    }
    
    /**
     *  @inheritDoc
     * 
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5
     */
    public function getNodeChildrenCount(parent:Object):int
    {
        if (!isBranchNode(parent))
            return 0;
        
        var children:XMLList = parent ? parent.children() : _rootNodes;
        return children.length();
    }
    
    /**
     *  @inheritDoc
     * 
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5
     */
    public function getNodeChildIndex(node:Object):int
    {
        if (!node || !(node is XML))
            return -1;
        
        // check if this node is a root node.
        var numRoots:int = _rootNodes.length();
        for (var i:int = 0; i < numRoots; i++) 
        {
            if (_rootNodes[i] == node)
                return i;
        }
        
        return node.childIndex();
    }
    
    /**
     *  @inheritDoc
     * 
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5
     */
    public function getNodeChildAt(parent:Object, index:int):Object
    {
        if (!isBranchNode(parent))
            return null;
        
        var children:XMLList = parent ? parent.children() : _rootNodes;
        checkIndex(index, children);
        
        return children[index];
    }
    
    /**
     *  @inheritDoc
     * 
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5
     */
    public function getNodeDepth(node:Object):int
    {
        if (!node || !(node is XML))
            return -1;
        
        var p:Object = getNodeParent(node);
        var depth:int = 0;
        while (p)
        {
            depth += 1;
            p = getNodeParent(p);
        }
        
        return depth;
    }
    
    //--------------------------------------------------------------------------
    //
    //  IMutableTreeAdapter Methods
    //
    //--------------------------------------------------------------------------
    
    /** 
     *  @inheritDoc
     * 
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5
     */
    public function addNodeChildrenAt(parent:Object, index:int, nodes:Vector.<Object>):void
    {
        if (!isBranchNode(parent))
            return;
        
        var children:XMLList = parent ? parent.children() : _rootNodes;
        checkIndex(index, children);
        
        if (!nodes || nodes.length <= 0)
            return;
        
        // insertItemsAt() returns false and does nothing if any of the items is not xml.
        if (XMLListUtil.insertNodesAt(children, index, nodes))
        {
            dispatchTreeAdapterChangeEvent(TreeDataAdapterChangeEventKind.ADD,
                nodes.concat(), index, parent);
        }
    }
    
    /**
     *  @inheritDoc
     * 
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5
     */
    public function removeNodeChildrenAt(parent:Object, index:int, count:int):Vector.<Object>
    {
        if (!isBranchNode(parent))
            return null;
        
        var children:XMLList = parent ? parent.children() : _rootNodes;
        checkIndex(index, children);
        
        if (count <= 0)
            return null;

        var removedNodes:Vector.<Object> = XMLListUtil.removeNodesAt(children, index, count);
        dispatchTreeAdapterChangeEvent(TreeDataAdapterChangeEventKind.REMOVE,
                                       removedNodes.concat(), index, parent);
        return removedNodes;
    }
   
}
}

//--------------------------------------------------------------------------
//
//  XMLListUtil
//
//--------------------------------------------------------------------------

/**
 *  A utility class for manipulating XMLLists.
 */
class XMLListUtil
{
    /**
     *  Inserts the xml nodes into the provided XMLList at the specified index.
     *  All provided nodes must be xml nodes.
     * 
     *  @return true if the operation was successful.
     */
    public static function insertNodesAt(xmlList:XMLList, index:int, nodes:Vector.<Object>):Boolean
    {
        var insertList:XMLList = new XMLList();
        for each (var node:Object in nodes)
        {
            // all nodes must be of type XML or XMLList
            if (!(node is XML) && !(node is XMLList && node.length() == 1))
                return false;
            
            insertList += node;
        }
        
        if (index == 0)
            xmlList[0] = insertList + xmlList[0];
        else
            xmlList[index - 1] += insertList;
        
        return true;
    }
    
    /**
     *  Removes count xml nodes starting from the specified index.
     * 
     *  @return vector of the removed nodes
     */
    public static function removeNodesAt(xmlList:XMLList, index:int, count:int):Vector.<Object>
    {
        var removedXML:Vector.<Object> = new Vector.<Object>();
        const endIndex:int = index + count;
        
        if (index < 0 || endIndex > xmlList.length())
            return removedXML;
        
        for (var i:int = endIndex - 1; i >= index; i--)
        {
            removedXML.push(xmlList[i]);
            delete xmlList[i];
        }
        return removedXML;
    }
}