package model
{
    import flash.events.EventDispatcher;

    public class NonBindableObject extends EventDispatcher
    {
        public function NonBindableObject()
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
        
        public var property0:Number;
        
        public var property1:String;
        
        public var property2:String;
        
        public var property3:Number;
        
        public var property4:String;
        
        public var property5:String;
        
        public var property6:Number;
        
        public var property7:String;
        
        public var property8:String;
        
        public var property9:Number;
        
        public var property10:String;
        
        public var property11:String;
        
        public var property12:Number;
        
        public var property13:String;
        
        public var property14:String;
        
        public var property15:Number;
        
        public var property16:String;
        
        public var property17:String;
        
        public var property18:Number;
        
        public var property19:String;
        
        public var property20:String;
        
        public var property21:Number;
        
        public var property22:String;
        
        public var property23:String;
        
        public var property24:Number;
        
        public var property25:String;
        
        public var property26:String;
        
        public var property27:Number;
        
        public var property28:String;
        
        public var property29:String;
    }
}