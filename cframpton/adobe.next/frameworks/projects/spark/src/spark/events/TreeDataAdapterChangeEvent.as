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

package spark.events
{

import flash.events.Event;

/**
 *  The TreeDataAdapterChangeEvent class represents events that are dispatched 
 *  when the associated tree adapter changes.
 * 
 *  <p>The nature of the change is described by the value of the <code>kind</code> property,
 *  whose valid values are defined in the TreeDataAdapterEventKind.
 *  It also determines which properties in the event are used.
 *  The following table shows the meaning of each property for each of the different values
 *  of the <code>kind</code> property:</p>
 *  
 *  <table class="innertable">
 *     <tr><th>Property</th><th>Add Event</th><th>Remove Event</th><th>Reset Event</th></tr>
 *     <tr><td><code>kind</code></td><td><code>TreeDataAdapterChangeEventKind.ADD</code></td>
 *       <td><code>TreeDataAdapterChangeEventKind.REMOVE</code></td>
 *       <td><code>TreeDataAdapterChangeEventKind.RESET</code></td></tr>
 *     <tr><td><code>nodes</code></td><td>A vector of the nodes that were added to the adapter</td>
 *       <td>A vector of the nodes that were removed from the adapter</td>
 *       <td>N/A, defaults to null</td></tr>
 *     <tr><td><code>index</code></td><td>Index where the nodes were added</td>
 *       <td>Index where the nodes were removed</td><td>N/A, defaults to -1</td></tr>
 *     <tr><td><code>parent</code></td><td>The parent of the newly added nodes</td><td>The former
 *       parent of the removed nodes</td><td>N/A, defaults to null</td></tr>
 *  </table>
 * 
 *  @see TreeDataAdapterChangeEventKind
 *  
 *  @langversion 3.0
 *  @playerversion Flash 11
 *  @playerversion AIR 3.0
 *  @productversion Flex 5
 */
public class TreeDataAdapterChangeEvent extends Event
{
    include "../core/Version.as";
    
    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------
    
    /**
     *  The <code>TreeDataAdapterChangeEvent.TREE_DATA_ADAPTER_CHANGE</code> constant
     *  defines the value of the <code>type</code> property of the event
     *  object for an event that is dispatched when a tree adapter has changed.
     *
     *  <p>The properties of the event object have the following values:</p>
     *  <table class="innertable">
     *     <tr><th>Property</th><th>Value</th></tr>
     *     <tr><td><code>bubbles</code></td><td>false</td></tr>
     *     <tr><td><code>cancelable</code></td><td>false</td></tr>
     *     <tr><td><code>currentTarget</code></td><td>The Object that defines the 
     *       event listener that handles the event. For example, if you use 
     *       <code>myButton.addEventListener()</code> to register an event listener, 
     *       myButton is the value of the <code>currentTarget</code>. </td></tr>
     *     <tr><td><code>kind</code></td><td>The kind of event.
     *       The valid values are defined in the TreeDataAdapterChangeEventKind 
     *       class as constants. This value determines which properties in
     *       the event are used.</td></tr>
     *     <tr><td><code>index</code></td><td>Index in the parent's children where the change
     *       occurred.</td></tr>
     *     <tr><td><code>nodes</code></td><td>A vector of nodes affected by the event.</td></tr>
     *     <tr><td><code>parent</code></td><td>The parent of the nodes specified in the
     *       <code>nodes</code> property.</td></tr>
     *     <tr><td><code>target</code></td><td>The Object that dispatched the event; 
     *       it is not always the Object listening for the event. 
     *       Use the <code>currentTarget</code> property to always access the 
     *       Object listening for the event.</td></tr>
     *     <tr><td><code>type</code></td><td>TreeDataAdapterChangeEvent.TREE_DATA_ADAPTER_CHANGE</td></tr>
     *  </table>
     *   
     *  @eventType treeDataAdapterChange
     *  
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5
     */
    public static const TREE_DATA_ADAPTER_CHANGE:String = "treeDataAdapterChange";
    
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Constructor.
     *
     *  @param type The event type; indicates the action that caused the event.
     *
     *  @param bubbles Specifies whether the event can bubble
     *  up the display list hierarchy.
     *
     *  @param cancelable Specifies whether the behavior
     *  associated with the event can be prevented.
     *
     *  @param kind The kind of event. The valid values are defined in the
     *  TreeDataAdapterChangeEventKind class as constants. This value determines which
     *  properties in the event are used.
     *  
     *  @param nodes Vector of nodes that are affected by the change.
     *  
     *  @param index The zero-based index in the <code>parent</code>'s
     *  children of where the change occured.
     * 
     *  @param parent The parent of the nodes specified by the <code>nodes</code>
     *  property.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5
     */
    public function TreeDataAdapterChangeEvent(type:String, bubbles:Boolean = false,
                                               cancelable:Boolean = false,
                                               kind:String = null, nodes:Vector.<Object> = null,
                                               index:int = -1, parent:Object = null)
    {
        super(type, bubbles, cancelable);
        
        this.kind = kind;
        this.nodes = nodes;
        this.index = index;
        this.parent = parent;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  kind
    //----------------------------------
    
    /**
     *  Indicates the kind of event that occurred.
     *  The property value can be one of the values in the 
     *  TreeDataAdapterChangeEventKind class, 
     *  or <code>null</code>, which indicates that the kind is unknown.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5
     */
    public var kind:String;
    
    //----------------------------------
    //  nodes
    //----------------------------------
    
    /**
     *  The tree adapter nodes that have been added or removed.
     *  When <code>kind</code> is <code>TreeDataAdapterChangeEventKind.RESET</code>, nodes is null.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5
     */
    public var nodes:Vector.<Object>;
    
    //----------------------------------
    //  index
    //----------------------------------
    
    /**
     *  The zero-based index in the <code>parent</code>'s children of where the change occured.
     *  When <code>kind</code> is <code>TreeDataAdapterChangeEventKind.RESET</code>, index is -1.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5
     */
    public var index:int;
    
    //----------------------------------
    //  parent
    //----------------------------------
    
    /**
     *  The parent or former parent of the nodes in the <code>nodes</code> property.
     *  If parent is null, then the change occured at the root level.
     *  When <code>kind</code> is <code>TreeDataAdapterChangeEventKind.RESET</code>,
     *  parent is null.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5
     */
    public var parent:Object;
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods: Event
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    override public function clone():Event
    {
        return new TreeDataAdapterChangeEvent(type, bubbles, cancelable,
            kind, nodes, index, parent);
    }
}
}