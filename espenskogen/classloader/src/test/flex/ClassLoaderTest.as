/**
 *  CFPE
 */
package com.jpmorgan.ib.cfpe.classloader
{
import flash.system.ApplicationDomain;

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
