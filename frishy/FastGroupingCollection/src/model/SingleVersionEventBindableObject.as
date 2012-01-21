package model
{
    import flash.events.Event;
    import flash.events.EventDispatcher;
    
    import mx.events.PropertyChangeEvent;

    public class SingleVersionEventBindableObject extends EventDispatcher
    {
        public function SingleVersionEventBindableObject()
        {
            super();
        }
        
        public static function createProperties(start:int, end:int):void
        {
            for (var i:int = start; i <= end; i++)
            {
                var type:String = (i % 3 == 0 ? "Number" : "String");
                
                trace('private var _property' + i + ':' + type + ';');
                trace('');
                trace('[Bindable("versionNumberChanged")]');
                trace('public function get property' + i + '():' + type + '');
                trace('{');
                    trace('return _property' + i + ';');
                trace('}');
                trace('');
                trace('public function set property' + i + '(value:' + type + '):void');
                trace('{');
                    trace('_property' + i + ' = value;');
                trace('}');
                trace('');
            }
            
        }
        
        public static const NUM_PROPERTIES:int = 30;
        
        public function fillAllProperties():void
        {
            for (var i:int = 0; i < NUM_PROPERTIES; i++)
            {
                fillProperty(i);
            }
            
            versionNumber++;
        }
        
        public function fillNRandomProperties(numPropertiesToUpdate:int):void
        {
            for (var j:int = 0; j < numPropertiesToUpdate; j++)
            {
                fillARandomProperty();
            }
            
            versionNumber++;
        }
        
        // doesn't update version.... so no binding here
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
        
        private var _versionNumber:Number = 0;
        
        [Bindable("versionNumberChanged")]
        public function get versionNumber():int
        {
            return _versionNumber;
        }
        
        public function set versionNumber(value:int):void
        {
            if (_versionNumber == value)
                return;
            
            var oldValue:Number = _versionNumber;
            
            _versionNumber = value;
            
            dispatchEvent(new Event("versionNumberChanged"));
            
//            dispatchEvent(PropertyChangeEvent.createUpdateEvent(this, "versionNumber", oldValue, _versionNumber));
            
            // prop0 is filter
            // prop1 is sort
            // prop3 is grouping
//            dispatchEvent(PropertyChangeEvent.createUpdateEvent(this, "property0", property0, property0));
//            dispatchEvent(PropertyChangeEvent.createUpdateEvent(this, "property1", property1, property1));
            dispatchEvent(PropertyChangeEvent.createUpdateEvent(this, "property3", property3, property3));
        }
        
        
        
        
        
        private var _property0:Number;
        
        [Bindable("versionNumberChanged")]
        public function get property0():Number
        {
            return _property0;
        }
        
        public function set property0(value:Number):void
        {
            _property0 = value;
        }
        
        private var _property1:String;
        
        [Bindable("versionNumberChanged")]
        public function get property1():String
        {
            return _property1;
        }
        
        public function set property1(value:String):void
        {
            _property1 = value;
        }
        
        private var _property2:String;
        
        [Bindable("versionNumberChanged")]
        public function get property2():String
        {
            return _property2;
        }
        
        public function set property2(value:String):void
        {
            _property2 = value;
        }
        
        private var _property3:Number;
        
        [Bindable("versionNumberChanged")]
        public function get property3():Number
        {
            return _property3;
        }
        
        public function set property3(value:Number):void
        {
            _property3 = value;
        }
        
        private var _property4:String;
        
        [Bindable("versionNumberChanged")]
        public function get property4():String
        {
            return _property4;
        }
        
        public function set property4(value:String):void
        {
            _property4 = value;
        }
        
        private var _property5:String;
        
        [Bindable("versionNumberChanged")]
        public function get property5():String
        {
            return _property5;
        }
        
        public function set property5(value:String):void
        {
            _property5 = value;
        }
        
        private var _property6:Number;
        
        [Bindable("versionNumberChanged")]
        public function get property6():Number
        {
            return _property6;
        }
        
        public function set property6(value:Number):void
        {
            _property6 = value;
        }
        
        private var _property7:String;
        
        [Bindable("versionNumberChanged")]
        public function get property7():String
        {
            return _property7;
        }
        
        public function set property7(value:String):void
        {
            _property7 = value;
        }
        
        private var _property8:String;
        
        [Bindable("versionNumberChanged")]
        public function get property8():String
        {
            return _property8;
        }
        
        public function set property8(value:String):void
        {
            _property8 = value;
        }
        
        private var _property9:Number;
        
        [Bindable("versionNumberChanged")]
        public function get property9():Number
        {
            return _property9;
        }
        
        public function set property9(value:Number):void
        {
            _property9 = value;
        }
        
        private var _property10:String;
        
        [Bindable("versionNumberChanged")]
        public function get property10():String
        {
            return _property10;
        }
        
        public function set property10(value:String):void
        {
            _property10 = value;
        }
        
        private var _property11:String;
        
        [Bindable("versionNumberChanged")]
        public function get property11():String
        {
            return _property11;
        }
        
        public function set property11(value:String):void
        {
            _property11 = value;
        }
        
        private var _property12:Number;
        
        [Bindable("versionNumberChanged")]
        public function get property12():Number
        {
            return _property12;
        }
        
        public function set property12(value:Number):void
        {
            _property12 = value;
        }
        
        private var _property13:String;
        
        [Bindable("versionNumberChanged")]
        public function get property13():String
        {
            return _property13;
        }
        
        public function set property13(value:String):void
        {
            _property13 = value;
        }
        
        private var _property14:String;
        
        [Bindable("versionNumberChanged")]
        public function get property14():String
        {
            return _property14;
        }
        
        public function set property14(value:String):void
        {
            _property14 = value;
        }
        
        private var _property15:Number;
        
        [Bindable("versionNumberChanged")]
        public function get property15():Number
        {
            return _property15;
        }
        
        public function set property15(value:Number):void
        {
            _property15 = value;
        }
        
        private var _property16:String;
        
        [Bindable("versionNumberChanged")]
        public function get property16():String
        {
            return _property16;
        }
        
        public function set property16(value:String):void
        {
            _property16 = value;
        }
        
        private var _property17:String;
        
        [Bindable("versionNumberChanged")]
        public function get property17():String
        {
            return _property17;
        }
        
        public function set property17(value:String):void
        {
            _property17 = value;
        }
        
        private var _property18:Number;
        
        [Bindable("versionNumberChanged")]
        public function get property18():Number
        {
            return _property18;
        }
        
        public function set property18(value:Number):void
        {
            _property18 = value;
        }
        
        private var _property19:String;
        
        [Bindable("versionNumberChanged")]
        public function get property19():String
        {
            return _property19;
        }
        
        public function set property19(value:String):void
        {
            _property19 = value;
        }
        
        private var _property20:String;
        
        [Bindable("versionNumberChanged")]
        public function get property20():String
        {
            return _property20;
        }
        
        public function set property20(value:String):void
        {
            _property20 = value;
        }
        
        private var _property21:Number;
        
        [Bindable("versionNumberChanged")]
        public function get property21():Number
        {
            return _property21;
        }
        
        public function set property21(value:Number):void
        {
            _property21 = value;
        }
        
        private var _property22:String;
        
        [Bindable("versionNumberChanged")]
        public function get property22():String
        {
            return _property22;
        }
        
        public function set property22(value:String):void
        {
            _property22 = value;
        }
        
        private var _property23:String;
        
        [Bindable("versionNumberChanged")]
        public function get property23():String
        {
            return _property23;
        }
        
        public function set property23(value:String):void
        {
            _property23 = value;
        }
        
        private var _property24:Number;
        
        [Bindable("versionNumberChanged")]
        public function get property24():Number
        {
            return _property24;
        }
        
        public function set property24(value:Number):void
        {
            _property24 = value;
        }
        
        private var _property25:String;
        
        [Bindable("versionNumberChanged")]
        public function get property25():String
        {
            return _property25;
        }
        
        public function set property25(value:String):void
        {
            _property25 = value;
        }
        
        private var _property26:String;
        
        [Bindable("versionNumberChanged")]
        public function get property26():String
        {
            return _property26;
        }
        
        public function set property26(value:String):void
        {
            _property26 = value;
        }
        
        private var _property27:Number;
        
        [Bindable("versionNumberChanged")]
        public function get property27():Number
        {
            return _property27;
        }
        
        public function set property27(value:Number):void
        {
            _property27 = value;
        }
        
        private var _property28:String;
        
        [Bindable("versionNumberChanged")]
        public function get property28():String
        {
            return _property28;
        }
        
        public function set property28(value:String):void
        {
            _property28 = value;
        }
        
        private var _property29:String;
        
        [Bindable("versionNumberChanged")]
        public function get property29():String
        {
            return _property29;
        }
        
        public function set property29(value:String):void
        {
            _property29 = value;
        }
    }
}