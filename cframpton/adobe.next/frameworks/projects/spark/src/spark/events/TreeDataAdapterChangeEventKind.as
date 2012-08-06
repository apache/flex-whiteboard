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

/**
 *  The TreeDataAdapterChangeEventKind class defines constants for the valid values 
 *  of the spark.events.TreeDataAdapterChangeEvent class <code>kind</code> property.
 *  These constants indicate the kind of change that was made to the ITreeDataAdapter.
 *
 *  @see spark.events.TreeDataAdapterChangeEvent#kind
 *  @see spark.events.TreeDataAdapterChangeEvent
 *  
 *  @langversion 3.0
 *  @playerversion Flash 11
 *  @playerversion AIR 3.0
 *  @productversion Flex 5
 */
public final class TreeDataAdapterChangeEventKind
{
    include "../core/Version.as";
    
    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------
    
    /** 
     *  Indicates that the tree adapter has added a node
     *  or nodes to the tree.
     *  
     *  <p>This kind of event should set the properties of its
     *  <code>TreeDataAdapterChangeEvent</code> as follows:</p>
     * 
     *  <table class="innertable">
     *     <tr><th>Property</th><th>Value</th></tr>
     *     <tr><td><code>nodes</code></td><td>A vector of the nodes that were
     *       added to the adapter</td></tr>
     *     <tr><td><code>index</code></td><td>Index where the nodes were added</td></tr>
     *     <tr><td><code>parent</code></td><td>The parent of the newly added nodes</td></tr>
     *  </table>
     *  
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5
     */
    public static const ADD:String = "add";
    
    /** 
     *  Indicates that the tree adapter has removed a node
     *  or nodes from the tree.
     * 
     *  <p>This kind of event should set the properties of its
     *  <code>TreeDataAdapterChangeEvent</code> as follows:</p>
     * 
     *  <table class="innertable">
     *     <tr><th>Property</th><th>Value</th></tr>
     *     <tr><td><code>nodes</code></td><td>A vector of the nodes that were
     *       removed from the adapter</td></tr>
     *     <tr><td><code>index</code></td><td>Index where the nodes were removed from</td></tr>
     *     <tr><td><code>parent</code></td><td>The former parent of the removed nodes</td></tr>
     *  </table>
     *  
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5
     */
    public static const REMOVE:String = "remove";
    
    /**
     *  Indicates that the tree adapter has changed so drastically that
     *  a reset is required by the listener.
     * 
     *  <p>This kind of event should set the properties of its
     *  <code>TreeDataAdapterChangeEvent</code> as follows:</p>
     * 
     *  <table class="innertable">
     *     <tr><th>Property</th><th>Value</th></tr>
     *     <tr><td><code>nodes</code></td><td>null</td></tr>
     *     <tr><td><code>index</code></td><td>-1</td></tr>
     *     <tr><td><code>parent</code></td><td>null</td></tr>
     *  </table>
     *  
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3.0
     *  @productversion Flex 5
     */
    public static const RESET:String = "reset";
}
}
