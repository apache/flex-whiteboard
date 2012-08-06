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

package spark.managers
{
import mx.managers.IToolTipManagerClient;

import spark.core.IToolTip;

[ExcludeClass]

/**
 *  @private
 */
public interface IToolTipManagerImpl
{
    //--------------------------------------------------------------------------
    //
    //  Class Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  enabled
    //----------------------------------
    
    /**
     *  @private
     */
   function get enabled():Boolean;
    
    /**
     *  @private
     */
    function set enabled(value:Boolean):void;
    
    //----------------------------------
    //  currentTarget
    //----------------------------------
    
    /**
     *  @private
     */
    function get currentTarget():IToolTipManagerClient;
    
    /**
     *  @private
     */
    function set currentTarget(value:IToolTipManagerClient):void;

    //----------------------------------
    //  currentToolTip
    //----------------------------------
    
    /**
     *  @private
     */
    function get currentToolTip():IToolTip;
    
    /**
     *  @private
     */
    function set currentToolTip(value:IToolTip):void;		
    
    //----------------------------------------------------------------------
    //
    //  Class Methods
    //
    //----------------------------------------------------------------------		
    
    //----------------------------------------------
    //  Component registration / deregistration
    //----------------------------------------------
    
    /**
     *  @private
     */
    function registerTarget(target:IToolTipManagerClient):void;
    
    /**
     *  @private
     */			
    function unregisterTarget(target:IToolTipManagerClient):void;
}
}
