package com.frishy.utils
{
    import flash.events.EventDispatcher;
    import flash.events.IEventDispatcher;
    
    import mx.core.IInvalidating;
    import mx.core.UIComponentGlobals;
    import mx.core.mx_internal;
    import mx.managers.ILayoutManagerClient;
    
    use namespace mx_internal;
    
    public class LayoutManagerClientHelper extends EventDispatcher 
        implements ILayoutManagerClient, IInvalidating
    {
        //--------------------------------------------------------------------------
        //
        //  Constructor
        //
        //--------------------------------------------------------------------------
        
        /**
         *  Constructor
         */
        public function LayoutManagerClientHelper(validatePropertiesCallback:Function = null,
                                                  validateSizeCallback:Function = null, 
                                                  validateDisplayListCallback:Function = null)
        {
            super();
            
            this.validatePropertiesCallback = validatePropertiesCallback;
            this.validateSizeCallback = validateSizeCallback;
            this.validateDisplayListCallback = validateDisplayListCallback;
        }
        
        //--------------------------------------------------------------------------
        //
        //  Variables
        //
        //--------------------------------------------------------------------------
        
        /**
         *  @private
         *  Whether validateProperties() needs to be called
         */
        private var invalidatePropertiesFlag:Boolean = false;
        
        /**
         *  @private
         *  Whether validateSize() needs to be called
         */
        private var invalidateSizeFlag:Boolean = false;
        
        /**
         *  @private
         *  Whether validateDisplayList() needs to be called
         */
        private var invalidateDisplayListFlag:Boolean = false;
        
        /**
         *  Callback for the validateProperties() pass
         */
        public var validatePropertiesCallback:Function;
        
        /**
         *  Callback for the validateSize() pass
         */
        public var validateSizeCallback:Function;
        
        /**
         *  Callback for the validateDisplayList() pass
         */
        public var validateDisplayListCallback:Function;
        
        //--------------------------------------------------------------------------
        //
        //  Properties
        //
        //--------------------------------------------------------------------------
        
        //----------------------------------
        //  needsValidation
        //----------------------------------
        
        /**
         *  Whether this object is invalid
         */
        public function get needsValidation():Boolean
        {
            // if any of the flags are invalid, then we need validation
            return (invalidatePropertiesFlag || invalidateSizeFlag || invalidateDisplayListFlag);
        }
        
        //--------------------------------------------------------------------------
        //
        //  Properties: ILayoutManagerClient
        //
        //--------------------------------------------------------------------------
        
        //----------------------------------
        //  initialized
        //----------------------------------
        
        /**
         *  @private
         *  Storage for the initialized property.
         */
        private var _initialized:Boolean = false;
        
        /**
         *  @copy mx.core.UIComponent#initialized
         */
        public function get initialized():Boolean
        {
            return _initialized;
        }
        
        /**
         *  @private
         */
        public function set initialized(value:Boolean):void
        {
            _initialized = value;
        }
        
        //----------------------------------
        //  nestLevel
        //----------------------------------
        
        /**
         *  @private
         *  Storage for the nestLevel property.
         */
        private var _nestLevel:int = 1;
        
        // no one will likely set nestLevel (but there's a setter in case
        // someone wants to.  We default nestLevel to 1 so it's a top-level component
        
        /**
         *  @copy mx.core.UIComponent#nestLevel
         */
        public function get nestLevel():int
        {
            return _nestLevel;
        }
        
        /**
         *  @private
         */
        public function set nestLevel(value:int):void
        {
            _nestLevel = value;
        }
        
        //----------------------------------
        //  processedDescriptors
        //----------------------------------
        
        /**
         *  @private
         *  Storage for the processedDescriptors property.
         */
        private var _processedDescriptors:Boolean = false;
        
        /**
         *  @copy mx.core.UIComponent#processedDescriptors
         */
        public function get processedDescriptors():Boolean
        {
            return _processedDescriptors;
        }
        
        /**
         *  @private
         */
        public function set processedDescriptors(value:Boolean):void
        {
            _processedDescriptors = value;
        }
        
        //----------------------------------
        //  updateCompletePendingFlag
        //----------------------------------
        
        /**
         *  @private
         *  Storage for the updateCompletePendingFlag property.
         */
        private var _updateCompletePendingFlag:Boolean = false;
        
        /**
         *  A flag that determines if an object has been through all three phases
         *  of layout validation (provided that any were required).
         */
        public function get updateCompletePendingFlag():Boolean
        {
            return _updateCompletePendingFlag;
        }
        
        /**
         *  @private
         */
        public function set updateCompletePendingFlag(value:Boolean):void
        {
            _updateCompletePendingFlag = value;
        }
        
        //--------------------------------------------------------------------------
        //
        //  Methods: IInvalidating
        //
        //--------------------------------------------------------------------------
        
        /**
         *  @copy mx.core.IInvalidating#invalidateProperties()
         */
        public function invalidateProperties():void
        {
            // Don't try to add the object to the display list queue until we've
            // been assigned a nestLevel, or we'll get added at the wrong place in
            // the LayoutManager's priority queue.
            if (!invalidatePropertiesFlag && nestLevel > 0)
            {
                invalidatePropertiesFlag = true;
                UIComponentGlobals.layoutManager.invalidateProperties(this);
            }
        }
        
        /**
         *  @copy mx.core.IInvalidating#invalidateSize()
         */
        public function invalidateSize():void
        {
            // Don't try to add the object to the display list queue until we've
            // been assigned a nestLevel, or we'll get added at the wrong place in
            // the LayoutManager's priority queue.
            if (!invalidateSizeFlag && nestLevel > 0)
            {
                invalidateSizeFlag = true;
                UIComponentGlobals.layoutManager.invalidateSize(this);
            }
        }
        
        /**
         *  @copy mx.core.IInvalidating#invalidateDisplayList()
         */
        public function invalidateDisplayList():void
        {
            // Don't try to add the object to the display list queue until we've
            // been assigned a nestLevel, or we'll get added at the wrong place in
            // the LayoutManager's priority queue.
            if (!invalidateDisplayListFlag && nestLevel > 0)
            {
                invalidateDisplayListFlag = true;
                UIComponentGlobals.layoutManager.invalidateDisplayList(this);
            }
        }
        
        /**
         *  @copy mx.core.IInvalidating#validateNow()
         */
        public function validateNow():void
        {
            if (invalidatePropertiesFlag)
                validateProperties();
            
            if (invalidateSizeFlag)
                validateSize();
            
            if (invalidateDisplayListFlag)
                validateDisplayList();
        }
        
        //--------------------------------------------------------------------------
        //
        //  Methods: Validation
        //
        //--------------------------------------------------------------------------
        
        /**
         *  @inheritDoc
         */
        public function validateProperties():void
        {
            if (validatePropertiesCallback != null)
                validatePropertiesCallback();
            
            invalidatePropertiesFlag = false;
        }
        
        /**
         *  @inheritDoc
         */
        public function validateSize(recursive:Boolean=false):void
        {
            if (validateSizeCallback != null)
                validateSizeCallback(recursive);
            
            invalidateSizeFlag = false;
        }
        
        public function validateDisplayList():void
        {
            if (validateDisplayListCallback != null)
                validateDisplayListCallback();
            
            invalidateDisplayListFlag = false;
        }
    }
}