/*
 * ////////////////////////////////////////////////////////////////////////////////
 * //
 * //  Licensed to the Apache Software Foundation (ASF) under one or more
 * //  contributor license agreements.  See the NOTICE file distributed with
 * //  this work for additional information regarding copyright ownership.
 * //  The ASF licenses this file to You under the Apache License, Version 2.0
 * //  (the "License"); you may not use this file except in compliance with
 * //  the License.  You may obtain a copy of the License at
 * //
 * //      http://www.apache.org/licenses/LICENSE-2.0
 * //
 * //  Unless required by applicable law or agreed to in writing, software
 * //  distributed under the License is distributed on an "AS IS" BASIS,
 * //  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * //  See the License for the specific language governing permissions and
 * //  limitations under the License.
 * //
 * ////////////////////////////////////////////////////////////////////////////////
 */


package org.apache.flex.classloader
{
import flash.events.Event;

/**
 * Class Loader Events
 */
public class ClassLoaderEvent extends Event
{
    public static var CLASS_CONTAINER_LOADED:String = "loaded";
    public static var CLASS_CONTAINER_ERROR:String = "error";
    public static var CLASS_CONTAINER_UNLOADED:String = "unloaded";


    public var msg:String;

    /**
     * Constructor
     */
    public function ClassLoaderEvent(type:String, msg:String = "")
    {
        super(type);

        this.msg = msg;
    }


    /**
     * Clone for re-dispatch
     */
    override public function clone():Event
    {
        return new ClassLoaderEvent(this.type, this.msg);
    }
}
}
