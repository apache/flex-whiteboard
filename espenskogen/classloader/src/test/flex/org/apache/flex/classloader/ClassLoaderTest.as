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
import flex.classloader.*;

import flash.system.ApplicationDomain;

import org.apache.flex.classloader.ClassLoader;

import org.flexunit.asserts.assertEquals;
import org.flexunit.asserts.assertNotNull;
import org.flexunit.asserts.assertNull;

/**
 * Tests for ClassLoader
 */
public class ClassLoaderTest
{
    /**
     * Constructor
     */
    public function ClassLoaderTest()
    {
    }

    [Before]
    public function setUp():void
    {

    }

    [After]
    public function tearDown():void
    {

    }


    /* TESTS */

    [Test(expects="flash.errors.IllegalOperationError")]
    public function testAbstractLoad():void
    {
        const classLoader:ClassLoader = new ClassLoader();
        classLoader.load();
    }

    [Test]
    public function testDefaultConstructor():void
    {
        const classLoader:ClassLoader = new MockClassLoader();

        assertNull(classLoader.parent);
    }

    [Test]
    public function testConstructorWithParent():void
    {
        const parent:ClassLoader = new MockClassLoader();
        const classLoader:ClassLoader = new MockClassLoader(parent);

        assertEquals(classLoader.parent, parent);
    }


    [Test]
    public function testConstructorWithDomain():void
    {
        const domain:ApplicationDomain = new ApplicationDomain();
        const classLoader:ClassLoader = new MockClassLoader(null, domain);

        assertEquals(MockClassLoader(classLoader).domain, domain);
    }


    [Test(expects="ReferenceError")]
    public function testLoadMissingClass():void
    {
        const classLoader:ClassLoader = new MockClassLoader();

        classLoader.getClass("SomeClass");
    }


    [Test]
    public function testLoadFoundClass():void
    {
        const classLoader:ClassLoader = new MockClassLoader();

        const theClass:Class = classLoader.getClass("com.jpmorgan.ib.cfpe.classloader.MockClass");

        assertNotNull(theClass);
    }
}
}
