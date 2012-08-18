/**
 *  CFPE
 */
package flex.classloader
{
import flash.system.ApplicationDomain;

import mx.core.BitmapAsset;

import org.flexunit.asserts.assertEquals;
import org.flexunit.asserts.assertFalse;
import org.flexunit.async.Async;

/**
 * Tests for SwfClassLoader
 */
public class SWFClassLoaderTest
{
    /**
     * Constructor
     */
    public function SWFClassLoaderTest()
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
        classLoader = new SWFClassLoader("dependencies/nowhere.swf");
        classLoader.load();
        Async.proceedOnEvent(this, classLoader, ClassLoaderEvent.CLASS_CONTAINER_ERROR);
    }

    [Test(async)]
    public function testConstructWithSWF():void
    {
        classLoader = new SWFClassLoader("dependencies/RuntimeClass.swf");
        classLoader.load();
        Async.proceedOnEvent(this, classLoader, ClassLoaderEvent.CLASS_CONTAINER_LOADED, 10000);
    }


    [Test(async)]
    public function testLoadClass():void
    {
        classLoader = new SWFClassLoader("dependencies/RuntimeClass.swf");
        classLoader.load();

        Async.handleEvent(this, classLoader, ClassLoaderEvent.CLASS_CONTAINER_LOADED, function ():void
                {
                    const RuntimeClass:Class = classLoader.getClass("com.jpmorgan.ib.cfpe.classloader.runtime.RuntimeClass");
                    const runtimeClass:Object = new RuntimeClass();

                    assertEquals(runtimeClass.toString(), "RuntimeClass");
                }, 10000
        );
    }


    [Test(async)]
    public function testLoadImportedClass():void
    {
        classLoader = new SWFClassLoader("dependencies/RuntimeClass.swf");
        classLoader.load();

        Async.handleEvent(this, classLoader, ClassLoaderEvent.CLASS_CONTAINER_LOADED, function ():void
                {
                    const RuntimeImportedClass:Class = classLoader.getClass("com.jpmorgan.ib.cfpe.classloader.runtime.RuntimeImportedClass");

                    const runtimeImportedClass:Object = new RuntimeImportedClass();
                    assertEquals(runtimeImportedClass.toString(), "RuntimeImportedClass");
                }, 10000
        );
    }


    [Test(async, expects="ReferenceError")]
    public function testUnloadClassContainer():void
    {
        assertFalse(ApplicationDomain.currentDomain.hasDefinition("com.jpmorgan.ib.cfpe.classloader.runtime.RuntimeClass"));

        classLoader = new SWFClassLoader("dependencies/RuntimeClass.swf");
        classLoader.load();

        Async.handleEvent(this, classLoader, ClassLoaderEvent.CLASS_CONTAINER_LOADED, function ():void
                {
                    const RuntimeClass:Class = classLoader.getClass("com.jpmorgan.ib.cfpe.classloader.runtime.RuntimeClass");
                    classLoader.unload();

                }, 10000
        );

        Async.handleEvent(this, classLoader, ClassLoaderEvent.CLASS_CONTAINER_UNLOADED, function ():void
                {
                    const RuntimeClass:Class = classLoader.getClass("com.jpmorgan.ib.cfpe.classloader.runtime.RuntimeClass");
                }, 10000
        );
    }


    [Test(async)]
    public function testLoadBitmapAsset():void
    {
        classLoader = new SWFClassLoader("dependencies/RuntimeClass.swf");
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
