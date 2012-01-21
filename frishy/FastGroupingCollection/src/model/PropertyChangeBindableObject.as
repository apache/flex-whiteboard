package model
{
    import flash.events.EventDispatcher;
    
    import mx.events.PropertyChangeEvent;

    public class PropertyChangeBindableObject extends EventDispatcher
    {
        public function PropertyChangeBindableObject()
        {
            super();
        }
        
        public static const NUM_PROPERTIES:int = 30;
        
        public function fillAllProperties():void
        {
            for (var i:int = 0; i < NUM_PROPERTIES; i++)
            {
                fillProperty(i);
            }
        }
        
        public function fillNRandomProperties(numPropertiesToUpdate:int):void
        {
            for (var j:int = 0; j < numPropertiesToUpdate; j++)
            {
                fillARandomProperty();
            }
        }
        
        private function fillARandomProperty():void
        {
            var propertyIndex:int = Math.floor(Math.random() * NUM_PROPERTIES);
            fillProperty(propertyIndex);
        }
        
        private function fillProperty(propertyIndex:int):void
        {
            if (propertyIndex % 3 == 0)
            {
                // Number
                this["property" + propertyIndex] = Math.random();
            }
            else
            {
                this["property" + propertyIndex] = Math.random().toString();
            }
        }
        
        [Bindable]
        public var property0:Number;
        
        [Bindable]
        public var property1:String;
        
        [Bindable]
        public var property2:String;
        
//        [Bindable]
//        public var property3:Number;
        private var _property3:Number;
        
        [Bindable("propertyChange")]
        public function get property3():Number
        {
            return _property3;
        }
        
        public function set property3(value:Number):void
        {
            if (value == _property3)
                return;
            
            var oldValue:Number = _property3;
            _property3 = value;
            
            dispatchEvent(PropertyChangeEvent.createUpdateEvent(this, "property3", oldValue, _property3));
        }
        
        [Bindable]
        public var property4:String;
        
        [Bindable]
        public var property5:String;
        
        [Bindable]
        public var property6:Number;
        
        [Bindable]
        public var property7:String;
        
        [Bindable]
        public var property8:String;
        
        [Bindable]
        public var property9:Number;
        
        [Bindable]
        public var property10:String;
        
        [Bindable]
        public var property11:String;
        
        [Bindable]
        public var property12:Number;
        
        [Bindable]
        public var property13:String;
        
        [Bindable]
        public var property14:String;
        
        [Bindable]
        public var property15:Number;
        
        [Bindable]
        public var property16:String;
        
        [Bindable]
        public var property17:String;
        
        [Bindable]
        public var property18:Number;
        
        [Bindable]
        public var property19:String;
        
        [Bindable]
        public var property20:String;
        
        [Bindable]
        public var property21:Number;
        
        [Bindable]
        public var property22:String;
        
        [Bindable]
        public var property23:String;
        
        [Bindable]
        public var property24:Number;
        
        [Bindable]
        public var property25:String;
        
        [Bindable]
        public var property26:String;
        
        [Bindable]
        public var property27:Number;
        
        [Bindable]
        public var property28:String;
        
        [Bindable]
        public var property29:String;
    }
}