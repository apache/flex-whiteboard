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
import flash.system.ApplicationDomain;

import org.apache.flex.classloader.ClassLoader;

/**
 * Simple Class Loader Mock, to test abstract functions
 */
public class MockClassLoader extends ClassLoader
{
    /**
     * Constructor
     */
    public function MockClassLoader(parent:ClassLoader = null, domain:ApplicationDomain = null)
    {
        super(parent, domain);
    }


    /**
     * Load the classes from there container e.g. SWF/SWC etc
     */
    override protected function loadContainer():void
    {

    }


    /**
     * Find a class form the container, and return it
     *
     * @throws ReferenceError
     */
    override protected function findDefinition(name:String):Object
    {
        if (name == "com.jpmorgan.ib.cfpe.classloader.MockClass")
            return MockClass;
        else
            throw new ReferenceError();
    }

}
}
