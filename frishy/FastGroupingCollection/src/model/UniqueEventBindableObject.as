package model
{
    import flash.events.Event;
    import flash.events.EventDispatcher;
    
    import mx.events.PropertyChangeEvent;

    public class UniqueEventBindableObject extends EventDispatcher
    {
        public function UniqueEventBindableObject()
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
                trace('[Bindable("property' + i + 'Changed")]');
                trace('public function get property' + i + '():' + type + '');
                trace('{');
                    trace('return _property' + i + ';');
                trace('}');
                trace('');
                trace('public function set property' + i + '(value:' + type + '):void');
                trace('{');
                    trace('if (_property' + i + ' == value)');
                        trace('return;');
                    trace('');
                    trace('_property' + i + ' = value;');
                    trace('if (hasEventListener("property' + i + 'Changed"))');
                        trace('dispatchEvent(new Event("property' + i + 'Changed"));');
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
        
        private var _property0:Number;
        
        [Bindable("property0Changed")]
        public function get property0():Number
        {
            return _property0;
        }
        
        public function set property0(value:Number):void
        {
            if (_property0 == value)
                return;
            
            _property0 = value;
            if (hasEventListener("property0Changed"))
                dispatchEvent(new Event("property0Changed"));
            
            dispatchEvent(PropertyChangeEvent.createUpdateEvent(this, "property0", property0, property0));
        }
        
        private var _property1:String;
        
        [Bindable("property1Changed")]
        public function get property1():String
        {
            return _property1;
        }
        
        public function set property1(value:String):void
        {
            if (_property1 == value)
                return;
            
            _property1 = value;
            if (hasEventListener("property1Changed"))
                dispatchEvent(new Event("property1Changed"));
            
            dispatchEvent(PropertyChangeEvent.createUpdateEvent(this, "property1", property1, property1));
        }
        
        private var _property2:String;
        
        [Bindable("property2Changed")]
        public function get property2():String
        {
            return _property2;
        }
        
        public function set property2(value:String):void
        {
            if (_property2 == value)
                return;
            
            _property2 = value;
            if (hasEventListener("property2Changed"))
                dispatchEvent(new Event("property2Changed"));
        }
        
        private var _property3:Number;
        
        [Bindable("property3Changed")]
        public function get property3():Number
        {
            return _property3;
        }
        
        public function set property3(value:Number):void
        {
            if (_property3 == value)
                return;
            
            _property3 = value;
            if (hasEventListener("property3Changed"))
                dispatchEvent(new Event("property3Changed"));
            
            dispatchEvent(PropertyChangeEvent.createUpdateEvent(this, "property3", property3, property3));
        }
        
        private var _property4:String;
        
        [Bindable("property4Changed")]
        public function get property4():String
        {
            return _property4;
        }
        
        public function set property4(value:String):void
        {
            if (_property4 == value)
                return;
            
            _property4 = value;
            if (hasEventListener("property4Changed"))
                dispatchEvent(new Event("property4Changed"));
        }
        
        private var _property5:String;
        
        [Bindable("property5Changed")]
        public function get property5():String
        {
            return _property5;
        }
        
        public function set property5(value:String):void
        {
            if (_property5 == value)
                return;
            
            _property5 = value;
            if (hasEventListener("property5Changed"))
                dispatchEvent(new Event("property5Changed"));
        }
        
        private var _property6:Number;
        
        [Bindable("property6Changed")]
        public function get property6():Number
        {
            return _property6;
        }
        
        public function set property6(value:Number):void
        {
            if (_property6 == value)
                return;
            
            _property6 = value;
            if (hasEventListener("property6Changed"))
                dispatchEvent(new Event("property6Changed"));
        }
        
        private var _property7:String;
        
        [Bindable("property7Changed")]
        public function get property7():String
        {
            return _property7;
        }
        
        public function set property7(value:String):void
        {
            if (_property7 == value)
                return;
            
            _property7 = value;
            if (hasEventListener("property7Changed"))
                dispatchEvent(new Event("property7Changed"));
        }
        
        private var _property8:String;
        
        [Bindable("property8Changed")]
        public function get property8():String
        {
            return _property8;
        }
        
        public function set property8(value:String):void
        {
            if (_property8 == value)
                return;
            
            _property8 = value;
            if (hasEventListener("property8Changed"))
                dispatchEvent(new Event("property8Changed"));
        }
        
        private var _property9:Number;
        
        [Bindable("property9Changed")]
        public function get property9():Number
        {
            return _property9;
        }
        
        public function set property9(value:Number):void
        {
            if (_property9 == value)
                return;
            
            _property9 = value;
            if (hasEventListener("property9Changed"))
                dispatchEvent(new Event("property9Changed"));
        }
        
        private var _property10:String;
        
        [Bindable("property10Changed")]
        public function get property10():String
        {
            return _property10;
        }
        
        public function set property10(value:String):void
        {
            if (_property10 == value)
                return;
            
            _property10 = value;
            if (hasEventListener("property10Changed"))
                dispatchEvent(new Event("property10Changed"));
        }
        
        private var _property11:String;
        
        [Bindable("property11Changed")]
        public function get property11():String
        {
            return _property11;
        }
        
        public function set property11(value:String):void
        {
            if (_property11 == value)
                return;
            
            _property11 = value;
            if (hasEventListener("property11Changed"))
                dispatchEvent(new Event("property11Changed"));
        }
        
        private var _property12:Number;
        
        [Bindable("property12Changed")]
        public function get property12():Number
        {
            return _property12;
        }
        
        public function set property12(value:Number):void
        {
            if (_property12 == value)
                return;
            
            _property12 = value;
            if (hasEventListener("property12Changed"))
                dispatchEvent(new Event("property12Changed"));
        }
        
        private var _property13:String;
        
        [Bindable("property13Changed")]
        public function get property13():String
        {
            return _property13;
        }
        
        public function set property13(value:String):void
        {
            if (_property13 == value)
                return;
            
            _property13 = value;
            if (hasEventListener("property13Changed"))
                dispatchEvent(new Event("property13Changed"));
        }
        
        private var _property14:String;
        
        [Bindable("property14Changed")]
        public function get property14():String
        {
            return _property14;
        }
        
        public function set property14(value:String):void
        {
            if (_property14 == value)
                return;
            
            _property14 = value;
            if (hasEventListener("property14Changed"))
                dispatchEvent(new Event("property14Changed"));
        }
        
        private var _property15:Number;
        
        [Bindable("property15Changed")]
        public function get property15():Number
        {
            return _property15;
        }
        
        public function set property15(value:Number):void
        {
            if (_property15 == value)
                return;
            
            _property15 = value;
            if (hasEventListener("property15Changed"))
                dispatchEvent(new Event("property15Changed"));
        }
        
        private var _property16:String;
        
        [Bindable("property16Changed")]
        public function get property16():String
        {
            return _property16;
        }
        
        public function set property16(value:String):void
        {
            if (_property16 == value)
                return;
            
            _property16 = value;
            if (hasEventListener("property16Changed"))
                dispatchEvent(new Event("property16Changed"));
        }
        
        private var _property17:String;
        
        [Bindable("property17Changed")]
        public function get property17():String
        {
            return _property17;
        }
        
        public function set property17(value:String):void
        {
            if (_property17 == value)
                return;
            
            _property17 = value;
            if (hasEventListener("property17Changed"))
                dispatchEvent(new Event("property17Changed"));
        }
        
        private var _property18:Number;
        
        [Bindable("property18Changed")]
        public function get property18():Number
        {
            return _property18;
        }
        
        public function set property18(value:Number):void
        {
            if (_property18 == value)
                return;
            
            _property18 = value;
            if (hasEventListener("property18Changed"))
                dispatchEvent(new Event("property18Changed"));
        }
        
        private var _property19:String;
        
        [Bindable("property19Changed")]
        public function get property19():String
        {
            return _property19;
        }
        
        public function set property19(value:String):void
        {
            if (_property19 == value)
                return;
            
            _property19 = value;
            if (hasEventListener("property19Changed"))
                dispatchEvent(new Event("property19Changed"));
        }
        
        private var _property20:String;
        
        [Bindable("property20Changed")]
        public function get property20():String
        {
            return _property20;
        }
        
        public function set property20(value:String):void
        {
            if (_property20 == value)
                return;
            
            _property20 = value;
            if (hasEventListener("property20Changed"))
                dispatchEvent(new Event("property20Changed"));
        }
        
        private var _property21:Number;
        
        [Bindable("property21Changed")]
        public function get property21():Number
        {
            return _property21;
        }
        
        public function set property21(value:Number):void
        {
            if (_property21 == value)
                return;
            
            _property21 = value;
            if (hasEventListener("property21Changed"))
                dispatchEvent(new Event("property21Changed"));
        }
        
        private var _property22:String;
        
        [Bindable("property22Changed")]
        public function get property22():String
        {
            return _property22;
        }
        
        public function set property22(value:String):void
        {
            if (_property22 == value)
                return;
            
            _property22 = value;
            if (hasEventListener("property22Changed"))
                dispatchEvent(new Event("property22Changed"));
        }
        
        private var _property23:String;
        
        [Bindable("property23Changed")]
        public function get property23():String
        {
            return _property23;
        }
        
        public function set property23(value:String):void
        {
            if (_property23 == value)
                return;
            
            _property23 = value;
            if (hasEventListener("property23Changed"))
                dispatchEvent(new Event("property23Changed"));
        }
        
        private var _property24:Number;
        
        [Bindable("property24Changed")]
        public function get property24():Number
        {
            return _property24;
        }
        
        public function set property24(value:Number):void
        {
            if (_property24 == value)
                return;
            
            _property24 = value;
            if (hasEventListener("property24Changed"))
                dispatchEvent(new Event("property24Changed"));
        }
        
        private var _property25:String;
        
        [Bindable("property25Changed")]
        public function get property25():String
        {
            return _property25;
        }
        
        public function set property25(value:String):void
        {
            if (_property25 == value)
                return;
            
            _property25 = value;
            if (hasEventListener("property25Changed"))
                dispatchEvent(new Event("property25Changed"));
        }
        
        private var _property26:String;
        
        [Bindable("property26Changed")]
        public function get property26():String
        {
            return _property26;
        }
        
        public function set property26(value:String):void
        {
            if (_property26 == value)
                return;
            
            _property26 = value;
            if (hasEventListener("property26Changed"))
                dispatchEvent(new Event("property26Changed"));
        }
        
        private var _property27:Number;
        
        [Bindable("property27Changed")]
        public function get property27():Number
        {
            return _property27;
        }
        
        public function set property27(value:Number):void
        {
            if (_property27 == value)
                return;
            
            _property27 = value;
            if (hasEventListener("property27Changed"))
                dispatchEvent(new Event("property27Changed"));
        }
        
        private var _property28:String;
        
        [Bindable("property28Changed")]
        public function get property28():String
        {
            return _property28;
        }
        
        public function set property28(value:String):void
        {
            if (_property28 == value)
                return;
            
            _property28 = value;
            if (hasEventListener("property28Changed"))
                dispatchEvent(new Event("property28Changed"));
        }
        
        private var _property29:String;
        
        [Bindable("property29Changed")]
        public function get property29():String
        {
            return _property29;
        }
        
        public function set property29(value:String):void
        {
            if (_property29 == value)
                return;
            
            _property29 = value;
            if (hasEventListener("property29Changed"))
                dispatchEvent(new Event("property29Changed"));
        }
    }
}