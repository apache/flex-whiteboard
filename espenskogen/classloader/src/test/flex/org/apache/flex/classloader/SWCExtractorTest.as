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
import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;
import flash.utils.ByteArray;

import org.apache.flex.classloader.util.SWCExtractor;

import org.flexunit.asserts.assertTrue;
import org.flexunit.async.Async;

/**
 * SwcExtractor Tests
 */
public class SWCExtractorTest
{
    /**
     * Constructor
     */
    public function SWCExtractorTest()
    {
    }

    /**
     * Tried to use an Async BeforeClass here, to load the swcData, but could not hold
     * the test execution until after the loader has loaded
     */

    /* TESTS */


    [Test]
    public function testMe():void
    {
        assertTrue(true);
    }


    [Test(async)]
    public function testExtractLibrary():void
    {
        const loader:URLLoader = new URLLoader();
        loader.dataFormat = URLLoaderDataFormat.BINARY;
        loader.load(new URLRequest("dependencies/RuntimeClass.swc"));

        Async.handleEvent(this, loader, Event.COMPLETE, function ():void
        {
            const swcExtractor:SWCExtractor = new SWCExtractor(ByteArray(loader.data));

            const swfData:ByteArray = swcExtractor.extract("library.swf");
        });
    }


    [Test(async)]
    public function testExtractCatalog():void
    {
        const loader:URLLoader = new URLLoader();
        loader.dataFormat = URLLoaderDataFormat.BINARY;
        loader.load(new URLRequest("dependencies/RuntimeClass.swc"));

        Async.handleEvent(this, loader, Event.COMPLETE, function ():void
        {
            const swcExtractor:SWCExtractor = new SWCExtractor(ByteArray(loader.data));

            const swfData:ByteArray = swcExtractor.extract("catalog.xml");
        });

    }


    /* PRIVATE */

}
}
