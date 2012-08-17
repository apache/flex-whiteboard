/**
 *  CFPE
 */
package com.jpmorgan.ib.cfpe.classloader
{
import flash.utils.getTimer;

import mx.core.BitmapAsset;

import org.flexunit.asserts.assertEquals;
import org.flexunit.async.Async;

/**
 *  SwcClassLoader Tests
 */
public class SwcClassLoaderTest
{
    /**
     * Constructor
     */
    public function SwcClassLoaderTest()
    {
    }

    [Before]
    public function setUp():void
    {

    }

    [After]
    public function tearDown():void
    {
        classLoader.unload();
        classLoader = null;
    }


    /* TESTS */


    [Test(async)]
    public function testConstructWithMissingSWF():void
    {
        classLoader = new SwcClassLoader("dependencies/nowhere.swc");
        classLoader.load();
        Async.proceedOnEvent(this, classLoader, ClassLoaderEvent.CLASS_CONTAINER_ERROR);
    }

    [Test(async)]
    public function testConstructWithSWF():void
    {
        classLoader = new SwcClassLoader("dependencies/RuntimeClass.swc");
        classLoader.load();
        Async.proceedOnEvent(this, classLoader, ClassLoaderEvent.CLASS_CONTAINER_LOADED, 10000);
    }


    [Test(async)]
    public function testLoadClass():void
    {
        classLoader = new SwcClassLoader("dependencies/RuntimeClass.swc");
        const tickCount:int = getTimer();
        classLoader.load();

        Async.handleEvent(this, classLoader, ClassLoaderEvent.CLASS_CONTAINER_LOADED, function ():void
                {
                    const time:int = getTimer() - tickCount;
                    trace(time);
                    const RuntimeClass:Class = classLoader.getClass("com.jpmorgan.ib.cfpe.classloader.runtime.RuntimeClass");
                    const runtimeClass:Object = new RuntimeClass();

                    assertEquals(runtimeClass.toString(), "RuntimeClass");
                }, 10000
        );
    }


    [Test(async, expects="ReferenceError")]
    public function testClassNotFound():void
    {
        classLoader = new SwcClassLoader("dependencies/RuntimeClass.swc");
        classLoader.load();

        Async.handleEvent(this, classLoader, ClassLoaderEvent.CLASS_CONTAINER_LOADED, function ():void
                {
                    const RuntimeClass:Class = classLoader.getClass("NoClassCalledThis");
                }, 10000
        );
    }


    [Test(expects="ReferenceError")]
    public function testClassNotLoaded():void
    {
        classLoader = new SwcClassLoader("dependencies/RuntimeClass.swc");
        const RuntimeClass:Class = classLoader.getClass("com.jpmorgan.ib.cfpe.classloader.runtime.RuntimeClass");
    }


    [Test(async)]
    public function testLoadFunction():void
    {
        classLoader = new SwcClassLoader("dependencies/RuntimeClass.swc");
        classLoader.load();

        Async.handleEvent(this, classLoader, ClassLoaderEvent.CLASS_CONTAINER_LOADED, function ():void
                {
                    const runtimeFunction:Function = classLoader.getFunction("com.jpmorgan.ib.cfpe.classloader.runtime.runtimeFunction");
                    const result:String = runtimeFunction();

                    assertEquals("Hello!", result);
                }, 10000
        );
    }


    [Test(async)]
    public function testLoadNamespace():void
    {
        classLoader = new SwcClassLoader("dependencies/RuntimeClass.swc");
        classLoader.load();

        Async.handleEvent(this, classLoader, ClassLoaderEvent.CLASS_CONTAINER_LOADED, function ():void
                {
                    const runtimenamespace:Namespace = classLoader.getNamespace("com.jpmorgan.ib.cfpe.classloader.runtime.runtimenamespace");

                    assertEquals("someURL", runtimenamespace.uri);
                }, 10000
        );
    }


    [Test(async)]
    public function testLoadBitmapAsset():void
    {
        classLoader = new SwcClassLoader("dependencies/RuntimeClass.swc");
        classLoader.load();

        Async.handleEvent(this, classLoader, ClassLoaderEvent.CLASS_CONTAINER_LOADED, function ():void
                {
                    const bitmapAsset:BitmapAsset = classLoader.getBitmapAsset("com.jpmorgan.ib.cfpe.classloader.runtime.RuntimeAssets_RuntimeBitmapAsset");

                    assertEquals(0xFFFFFF, bitmapAsset.bitmapData.getPixel(10, 10));
                }, 10000
        );
    }


    /* PRIVATE */

    private var classLoader:ClassLoader;
}
}
