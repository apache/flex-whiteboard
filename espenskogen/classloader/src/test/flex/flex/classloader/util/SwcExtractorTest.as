/**
 *  CFPE
 */
package flex.classloader.util
{
import flash.events.Event;
import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;
import flash.utils.ByteArray;

import org.flexunit.asserts.assertTrue;
import org.flexunit.async.Async;

/**
 * SwcExtractor Tests
 */
public class SwcExtractorTest
{
    /**
     * Constructor
     */
    public function SwcExtractorTest()
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
            const swcExtractor:SwcExtractor = new SwcExtractor(ByteArray(loader.data));

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
            const swcExtractor:SwcExtractor = new SwcExtractor(ByteArray(loader.data));

            const swfData:ByteArray = swcExtractor.extract("catalog.xml");
        });

    }


    /* PRIVATE */

}
}
