/**
 *  CFPE
 */
package flex.classloader
{
import classloader.*;
    import flash.display.MovieClip;
    import flash.errors.IllegalOperationError;
    import flash.events.EventDispatcher;
    import flash.system.ApplicationDomain;
    import flash.utils.ByteArray;

    import mx.core.BitmapAsset;
    import mx.core.SoundAsset;
    import mx.core.SpriteAsset;
    import mx.logging.ILogger;
    import mx.logging.Log;

    [Event(name="loaded", type="flex.classloader.ClassLoaderEvent")]
    [Event(name="error", type="flex.classloader..ClassLoaderEvent")]
    [Event(name="unloaded", type="flex.classloader.ClassLoaderEvent")]

    /**
     * Abstract base class for ClassLoaders.
     *
     * <p>Provides a Java style class loader hierarchy for dynamically loading Flex classes.</p>
     * <p>Sub classes should implement <code>findClass</code>, <code>loadContainer</code> and <code>unloadContainer</code> at a minimum</p>
     * @see http://docs.oracle.com/javase/1.4.2/docs/api/java/lang/flex.classloader.ClassLoader.html
     */
    public class ClassLoader extends EventDispatcher
    {
        /**
         * The parent class loader
         */
        public function get parent():ClassLoader
        {
            return _parent;
        }


        /**
         * Domain for the class loader
         */
        public function get domain():ApplicationDomain
        {
            return _domain;
        }


        /**
         * Has the dependency been loaded
         */
        public function get loaded():Boolean
        {
            return _loaded;
        }


        /**
         * Constructor
         */
        public function ClassLoader(parent:ClassLoader = null, domain:ApplicationDomain = null)
        {
            if (parent)
            {
                _parent = parent;
            }

            if (domain)
            {
                this._domain = domain;
            }
            else if (parent)
            {
                this._domain = _parent._domain;
            }
            else
            {
                this._domain = new ApplicationDomain(ApplicationDomain.currentDomain);
            }

        }


        /* PUBLIC */


        /**
         *  Load the classes from there container e.g. SWF/SWC etc
         */
        public function load():void
        {
            loadContainer();
        }


        /**
         *  unload the classes from there container e.g. SWF/SWC etc
         */
        public function unload():void
        {
            unloadContainer();
        }


        /**
         * Return a class definition
         *
         * <p>Because Flex Loaders are asynchronous, this method must be called after the ClassLoader as finished loading the class container e.g. SWF/SWC etc from a call to load()</p>
         *
         * @throws ReferenceError
         */
        public function getClass(name:String):Class
        {
            var result:Class

            try
            {
                result = Class(lookupDefinition(name));
            }
            catch (error:ReferenceError)
            {
                throw new ReferenceError("Class definition '" + name + "' not found");
            }

            if (!result)
            {
                throw new ReferenceError("Class definition '" + name + "' not found");
            }

            return result;
        }


        /**
         * Return a function definition
         *
         * <p>Because Flex Loaders are asynchronous, this method must be called after the ClassLoader as finished loading the class container e.g. SWF/SWC etc from a call to load()</p>
         *
         * @throws ReferenceError
         */
        public function getFunction(name:String):Function
        {
            var result:Function;

            try
            {
                result = lookupDefinition(name) as Function;
            }
            catch (error:ReferenceError)
            {
                if (error.message != "")
                {
                    throw new ReferenceError("Function definition '" + name + "' not found in '" + error.message + "'");
                }
                else
                {
                    throw new ReferenceError("Function definition '" + name + "' not found");
                }
            }

            return result;
        }


        /**
         * Return a namespace definition
         *
         * <p>Because Flex Loaders are asynchronous, this method must be called after the ClassLoader as finished loading the class container e.g. SWF/SWC etc from a call to load()</p>
         *
         * @throws ReferenceError
         */
        public function getNamespace(name:String):Namespace
        {
            var result:Namespace;

            try
            {
                result = Namespace(lookupDefinition(name));
            }
            catch (error:ReferenceError)
            {
                throw new ReferenceError("Namespace definition '" + name + "' not found");
            }

            if (!result)
            {
                throw new ReferenceError("Namespace definition '" + name + "' not found");
            }

            return result;
        }


        /**
         * Return a bitmap asset, from an embedded JPG, GIF or PNG
         *
         * <p>Because Flex Loaders are asynchronous, this method must be called after the ClassLoader as finished loading the class container e.g. SWF/SWC etc from a call to load()</p>
         *
         * @throws ReferenceError
         * @throws TypeError
         */
        public function getBitmapAsset(name:String):BitmapAsset
        {
            const LoadedBitmapAssetClass:Class = getClass(name);
            var bitmapAsset:BitmapAsset;

            try
            {
                bitmapAsset = new LoadedBitmapAssetClass();
                return bitmapAsset;
            }
            catch (error:Error)
            {
                throw new TypeError(name + " is not a Bitmap Asset");
            }

            return null;
        }


        /**
         * Return a sprite asset, from an embedded SVG image
         *
         * <p>Because Flex Loaders are asynchronous, this method must be called after the ClassLoader as finished loading the class container e.g. SWF/SWC etc from a call to load()</p>
         *
         * @throws ReferenceError
         * @throws TypeError
         */
        public function getSpriteAsset(name:String):SpriteAsset
        {
            const LoadedSpriteAssetClass:Class = getClass(name);
            var spriteAsset:SpriteAsset;

            try
            {
                spriteAsset = new LoadedSpriteAssetClass();
                return spriteAsset;
            }
            catch (error:Error)
            {
                throw new TypeError(name + " is not a Sprite Asset");
            }

            return null;
        }


        /**
         * Return a sound asset, from an embedded MP3
         *
         * <p>Because Flex Loaders are asynchronous, this method must be called after the ClassLoader as finished loading the class container e.g. SWF/SWC etc from a call to load()</p>
         *
         * @throws ReferenceError
         * @throws TypeError
         */
        public function getSoundAsset(name:String):SoundAsset
        {
            const LoadedSoundAssetClass:Class = getClass(name);
            var soundAsset:SoundAsset;

            try
            {
                soundAsset = new LoadedSoundAssetClass();
                return soundAsset;
            }
            catch (error:Error)
            {
                throw new TypeError(name + " is not a Sound Asset");
            }

            return null;
        }


        /**
         * Return a Movie Clip asset, from an embedded SWF
         *
         * <p>Because Flex Loaders are asynchronous, this method must be called after the ClassLoader as finished loading the class container e.g. SWF/SWC etc from a call to load()</p>
         *
         * @throws ReferenceError
         * @throws TypeError
         */
        public function getMovieClipAsset(name:String):MovieClip
        {
            const LoadedMovieClipClass:Class = getClass(name);
            var moveClip:MovieClip;

            try
            {
                moveClip = new LoadedMovieClipClass();
                return moveClip;
            }
            catch (error:Error)
            {
                throw new TypeError(name + " is not a MovieClip Asset");
            }

            return null;
        }


        /**
         * Return a ByteArray asset, from an embedded binary asset
         *
         * <p>Because Flex Loaders are asynchronous, this method must be called after the ClassLoader as finished loading the class container e.g. SWF/SWC etc from a call to load()</p>
         *
         * @throws ReferenceError
         * @throws TypeError
         */
        public function getByteArrayAsset(name:String):ByteArray
        {
            const LoadedByteArrayAssetClass:Class = getClass(name);
            var byteArrayAsset:ByteArray;

            try
            {
                byteArrayAsset = new LoadedByteArrayAssetClass();
                return byteArrayAsset;
            }
            catch (error:Error)
            {
                throw new TypeError(name + " is not a ByteArray Asset");
            }

            return null;
        }


        /* PROTECTED */


        protected var _parent:ClassLoader;

        protected var _domain:ApplicationDomain

        protected var _loaded:Boolean = false;


        /**
         * Load the classes from there container e.g. SWF/SWC etc
         */
        protected function loadContainer():void
        {
            throw new IllegalOperationError("Must be overridden");
        }


        /**
         *  UnLoad the classes from there container e.g. SWF/SWC etc
         */
        protected function unloadContainer():void
        {
            throw new IllegalOperationError("Must be overridden");
        }


        /**
         * Find a definition form the container, and return it
         *
         * @throws ReferenceError
         */
        protected function findDefinition(name:String):Object
        {
            throw new IllegalOperationError("Must be overridden");
        }


        /* PRIVATE */

        private static const logger:ILogger = Log.getLogger("com.jpmorgan.ib.cfpe.classloader.ClassLoader");

        /**
         * Lookup the definition form the ClassLoader hierarchy
         */
        private function lookupDefinition(name:String):Object
        {
            var definition:Object;

            if (_domain && _domain.hasDefinition(name))
            {
                definition = _domain.getDefinition(name);
            }
            else
            {
                try
                {
                    if (_parent)
                    {
                        definition = _parent.getClass(name);
                    }
                }
                catch (error:ReferenceError)
                {
                    definition = findDefinition(name);
                }
            }

            if (!_parent)
            {
                definition = findDefinition(name);
            }

            logger.info("lookupDefinition: Looked up definition for {0}: {1}", name, definition);

            return definition;
        }
    }
}
