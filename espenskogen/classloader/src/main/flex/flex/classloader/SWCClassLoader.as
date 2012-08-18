/**
 *  CFPE
 */
package flex.classloader
{
import classloader.*;

import com.jpmorgan.ib.cfpe.classloader.util.SwcExtractor;

import flash.display.Loader;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;
import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;
import flash.system.ApplicationDomain;
import flash.system.LoaderContext;
import flash.utils.ByteArray;

/**
 * Implements a Class Loader which loads Classes within a SWC container from a URL
 *
 * <p>When using Embedded assets in the SWC for use with getBitmapAsset, getSoundAsset etc; it is advisable to
 * explicitly remove the resource file asset from the SWC, to avoid storing the asset twice i.e. once for the file
 * and once of the Asset class wrapping the file.</p>
 */
public class SWCClassLoader extends ClassLoader
{
    /**
     * Constructor
     */
    public function SWCClassLoader(swcURL:String, parent:ClassLoader = null, domain:ApplicationDomain = null)
    {
        super(parent, domain);

        this._swcURL = swcURL;
    }


    /* PUBLIC */

    protected var loader:URLLoader;

    protected var _swcURL:String;

    /**
     * Load the classes from SWF
     */
    override protected function loadContainer():void
    {
        loader = new URLLoader();
        loader.dataFormat = URLLoaderDataFormat.BINARY;
        loader.addEventListener(Event.COMPLETE, completeHandler);
        loader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
        loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);

        libraryLoader = new Loader();
        libraryLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, libraryLoadCompleteHandler);
        libraryLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
        libraryLoader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
        libraryLoader.contentLoaderInfo.addEventListener(Event.UNLOAD, unloadHandler);

        // Load the SWC
        const request:URLRequest = new URLRequest(_swcURL);
        loader.load(request);
    }


    /**
     *  UnLoad the classes from there container e.g. SWF/SWC etc
     */
    override protected function unloadContainer():void
    {
        if (_domain)
        {
            _domain = null;
        }

        if (loader)
        {
            loader.removeEventListener(Event.COMPLETE, completeHandler);
            loader.removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
            loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);

            loader = null;
        }


        if (libraryLoader)
        {
            libraryLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, libraryLoadCompleteHandler);
            libraryLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
            libraryLoader.contentLoaderInfo.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);

            libraryLoader.unloadAndStop(true);
            libraryLoader = null;
        }
    }


    /**
     * Find a class form the SWF, and return it
     *
     * @throws ReferenceError
     */
    override protected function findDefinition(name:String):Object
    {
        try
        {
            return libraryLoader.contentLoaderInfo.applicationDomain.getDefinition(name);
        }
        catch (error:Error)
        {
            throw new ReferenceError(_swcURL);
        }

        return null;
    }


    /**
     * Handle load complete
     *
     * @param event
     */
    protected function completeHandler(event:Event):void
    {
        // Extract SWF library
        const extractor:SwcExtractor = new SwcExtractor(loader.data);
        const swfData:ByteArray = extractor.extract("library.swf");

        // Load the SWF
        const context:LoaderContext = new LoaderContext(false, _domain);
        libraryLoader.loadBytes(swfData, context);
    }


    /**
     * Handle library load complete
     *
     * @param event
     */
    protected function libraryLoadCompleteHandler(event:Event):void
    {
        _loaded = true;

        dispatchEvent(new ClassLoaderEvent(ClassLoaderEvent.CLASS_CONTAINER_LOADED));
    }



    /**
     * Handle error
     *
     * @param event
     */
    protected function ioErrorHandler(event:IOErrorEvent):void
    {
        dispatchEvent(new ClassLoaderEvent(ClassLoaderEvent.CLASS_CONTAINER_ERROR, event.text));
    }

    /**
     * Handle error
     *
     * @param event
     */
    protected function securityErrorHandler(event:SecurityErrorEvent):void
    {
        dispatchEvent(new ClassLoaderEvent(ClassLoaderEvent.CLASS_CONTAINER_ERROR, event.text));
    }


    /* PRIVATE */

    private var libraryLoader:Loader;



    /**
     * Handle unload
     *
     * @param event
     */
    private function unloadHandler(event:Event):void
    {
        dispatchEvent(new ClassLoaderEvent(ClassLoaderEvent.CLASS_CONTAINER_UNLOADED));

        if (libraryLoader)
        {
            libraryLoader.removeEventListener(Event.UNLOAD, unloadHandler);
        }
    }
}
}
