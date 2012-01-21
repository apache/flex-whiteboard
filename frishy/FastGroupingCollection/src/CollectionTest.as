package
{
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.TimerEvent;
    import flash.utils.Timer;
    import flash.utils.getTimer;
    
    import mx.collections.ArrayCollection;
    import mx.collections.ICollectionView;
    import mx.collections.IList;
    import mx.collections.IViewCursor;
    import model.NonBindableObject;
    import model.PropertyChangeBindableObject;
    import model.SingleVersionEventBindableObject;
    import model.UniqueEventBindableObject;

    public class CollectionTest extends EventDispatcher
    {
        public function CollectionTest()
        {
        }
        
        public function fillCollectionNonBindable(list:IList, numItems:int, fillObjects:Boolean):void
        {
            for (var i:int = 0; i < numItems; i++)
            {
                var newObject:NonBindableObject = new NonBindableObject();
                if (fillObjects)
                    newObject.fillAllProperties();
                list.addItem(newObject);
            }
        }
        
        public function fillCollectionPropertyChangeBindable(list:IList, numItems:int, fillObjects:Boolean):void
        {
            for (var i:int = 0; i < numItems; i++)
            {
                var newObject:PropertyChangeBindableObject = new PropertyChangeBindableObject();
                if (fillObjects)
                    newObject.fillAllProperties();
                list.addItem(newObject);
            }
        }
        
        public function fillCollectionUniqueEventBindable(list:IList, numItems:int, fillObjects:Boolean):void
        {
            for (var i:int = 0; i < numItems; i++)
            {
                var newObject:UniqueEventBindableObject = new UniqueEventBindableObject();
                if (fillObjects)
                    newObject.fillAllProperties();
                list.addItem(newObject);
            }
        }
        
        public function fillCollectionSingleVersionEventBindable(list:IList, numItems:int, fillObjects:Boolean):void
        {
            for (var i:int = 0; i < numItems; i++)
            {
                var newObject:SingleVersionEventBindableObject = new SingleVersionEventBindableObject();
                if (fillObjects)
                    newObject.fillAllProperties();
                list.addItem(newObject);
            }
        }
        
        public function fillArrayNonBindable(list:Array, numItems:int, fillObjects:Boolean):void
        {
            for (var i:int = 0; i < numItems; i++)
            {
                var newObject:NonBindableObject = new NonBindableObject();
                if (fillObjects)
                    newObject.fillAllProperties();
                list.push(newObject);
            }
        }
        
        public function fillArrayPropertyChangeBindable(list:Array, numItems:int, fillObjects:Boolean):void
        {
            for (var i:int = 0; i < numItems; i++)
            {
                var newObject:PropertyChangeBindableObject = new PropertyChangeBindableObject();
                if (fillObjects)
                    newObject.fillAllProperties();
                list.push(newObject);
            }
        }
        
        public function fillArrayUniqueEventBindable(list:Array, numItems:int, fillObjects:Boolean):void
        {
            for (var i:int = 0; i < numItems; i++)
            {
                var newObject:UniqueEventBindableObject = new UniqueEventBindableObject();
                if (fillObjects)
                    newObject.fillAllProperties();
                list.push(newObject);
            }
        }
        
        public function fillArraySingleVersionEventBindable(list:Array, numItems:int, fillObjects:Boolean):void
        {
            for (var i:int = 0; i < numItems; i++)
            {
                var newObject:SingleVersionEventBindableObject = new SingleVersionEventBindableObject();
                if (fillObjects)
                    newObject.fillAllProperties();
                list.push(newObject);
            }
        }
        
        public function fillVectorNonBindable(list:Vector.<Object>, numItems:int, fillObjects:Boolean):void
        {
            for (var i:int = 0; i < numItems; i++)
            {
                var newObject:NonBindableObject = new NonBindableObject();
                if (fillObjects)
                    newObject.fillAllProperties();
                list.push(newObject);
            }
        }
        
        public function fillVectorPropertyChangeBindable(list:Vector.<Object>, numItems:int, fillObjects:Boolean):void
        {
            for (var i:int = 0; i < numItems; i++)
            {
                var newObject:PropertyChangeBindableObject = new PropertyChangeBindableObject();
                if (fillObjects)
                    newObject.fillAllProperties();
                list.push(newObject);
            }
        }
        
        public function fillVectorUniqueEventBindable(list:Vector.<Object>, numItems:int, fillObjects:Boolean):void
        {
            for (var i:int = 0; i < numItems; i++)
            {
                var newObject:UniqueEventBindableObject = new UniqueEventBindableObject();
                if (fillObjects)
                    newObject.fillAllProperties();
                list.push(newObject);
            }
        }
        
        public function fillVectorSingleVersionEventBindable(list:Vector.<Object>, numItems:int, fillObjects:Boolean):void
        {
            for (var i:int = 0; i < numItems; i++)
            {
                var newObject:SingleVersionEventBindableObject = new SingleVersionEventBindableObject();
                if (fillObjects)
                    newObject.fillAllProperties();
                list.push(newObject);
            }
        }
        
        
        public static const TIMER_INTERVAL:int = 250;
        
        public function startRandomPropertyUpdatesCollection(list:IList, numIterations:int, numItemsPerSecond:int, numPropertiesPerUpdate:int):Array
        {
            var timer:Timer = new Timer(TIMER_INTERVAL, numIterations);
            var numTicksPerSecond:Number = 1000/TIMER_INTERVAL;
            var numItemsPerTick:int = numItemsPerSecond/numTicksPerSecond;
            var timerResults:Array = [];
            timer.addEventListener(TimerEvent.TIMER, function(event:TimerEvent):void
            {
                var listToUse:IList = (list is ArrayCollection && ArrayCollection(list).filterFunction != null) ? ArrayCollection(list).list : list;
                
                if (listToUse.length == 0)
                    return;
                
                var startTime:int = getTimer();
                for (var i:int = 0; i < numItemsPerTick; i++)
                {
                    var randomObjectIndex:int = Math.floor(Math.random() * listToUse.length);
                    var objectToModify:Object = listToUse.getItemAt(randomObjectIndex);
                    
                    objectToModify.fillNRandomProperties(numPropertiesPerUpdate);
                }
                timerResults.push(getTimer() - startTime);
            });
            timer.addEventListener(TimerEvent.TIMER_COMPLETE, timerCompleteEventHandler);
            
            timer.start();
            return timerResults;
        }
        
        public function startRandomPropertyUpdatesArray(list:Array, numIterations:int, numItemsPerSecond:int, numPropertiesPerUpdate:int):Array
        {
            var timer:Timer = new Timer(TIMER_INTERVAL, numIterations);
            var numTicksPerSecond:Number = 1000/TIMER_INTERVAL;
            var numItemsPerTick:int = numItemsPerSecond/numTicksPerSecond;
            var timerResults:Array = [];
            timer.addEventListener(TimerEvent.TIMER, function(event:TimerEvent):void
            {
                if (list.length == 0)
                    return;
                var startTime:Number = getTimer();
                for (var i:int = 0; i < numItemsPerTick; i++)
                {
                    var randomObjectIndex:int = Math.floor(Math.random() * list.length);
                    var objectToModify:Object = list[randomObjectIndex];
                    
                    objectToModify.fillNRandomProperties(numPropertiesPerUpdate);
                }
                timerResults.push(getTimer() - startTime);
            });
            timer.addEventListener(TimerEvent.TIMER_COMPLETE, timerCompleteEventHandler);
            
            timer.start();
            return timerResults;
        }
        
        public function startRandomPropertyUpdatesVector(list:Vector.<Object>, numIterations:int, numItemsPerSecond:int, numPropertiesPerUpdate:int):Array
        {
            var timer:Timer = new Timer(TIMER_INTERVAL, numIterations);
            var numTicksPerSecond:Number = 1000/TIMER_INTERVAL;
            var numItemsPerTick:int = numItemsPerSecond/numTicksPerSecond;
            var timerResults:Array = [];
            timer.addEventListener(TimerEvent.TIMER, function(event:TimerEvent):void
            {
                if (list.length == 0)
                    return;
                var startTime:Number = getTimer();
                for (var i:int = 0; i < numItemsPerTick; i++)
                {
                    var randomObjectIndex:int = Math.floor(Math.random() * list.length);
                    var objectToModify:Object = list[randomObjectIndex];
                    
                    objectToModify.fillNRandomProperties(numPropertiesPerUpdate);
                }
                timerResults.push(getTimer() - startTime);
            });
            timer.addEventListener(TimerEvent.TIMER_COMPLETE, timerCompleteEventHandler);
            
            timer.start();
            return timerResults;
        }
        
        public function startRandomAdditionsNonBindableCollection(list:IList, numIterations:int, numItemsPerSecond:int, fillObjects:Boolean):Array
        {
            var timer:Timer = new Timer(TIMER_INTERVAL, numIterations);
            var numTicksPerSecond:Number = 1000/TIMER_INTERVAL;
            var numItemsPerTick:int = numItemsPerSecond/numTicksPerSecond;
            var timerResults:Array = [];
            timer.addEventListener(TimerEvent.TIMER, function(event:TimerEvent):void
            {
                var startTime:Number = getTimer();
                for (var i:int = 0; i < numItemsPerTick; i++)
                {
                    var newObject:NonBindableObject = new NonBindableObject();
                    if (fillObjects)
                        newObject.fillAllProperties();
                    list.addItem(newObject);
                }
                timerResults.push(getTimer() - startTime);
            });
            timer.addEventListener(TimerEvent.TIMER_COMPLETE, timerCompleteEventHandler);
            
            timer.start();
            return timerResults;
        }
        
        public function startRandomAdditionsPropertyChangeBindableCollection(list:IList, numIterations:int, numItemsPerSecond:int, fillObjects:Boolean):Array
        {
            var timer:Timer = new Timer(TIMER_INTERVAL, numIterations);
            var numTicksPerSecond:Number = 1000/TIMER_INTERVAL;
            var numItemsPerTick:int = numItemsPerSecond/numTicksPerSecond;
            var timerResults:Array = [];
            timer.addEventListener(TimerEvent.TIMER, function(event:TimerEvent):void
            {
                var startTime:Number = getTimer();
                for (var i:int = 0; i < numItemsPerTick; i++)
                {
                    var newObject:PropertyChangeBindableObject = new PropertyChangeBindableObject();
                    if (fillObjects)
                        newObject.fillAllProperties();
                    list.addItem(newObject);
                }
                timerResults.push(getTimer() - startTime);
            });
            timer.addEventListener(TimerEvent.TIMER_COMPLETE, timerCompleteEventHandler);
            
            timer.start();
            return timerResults;
        }
        
        public function startRandomAdditionsUniqueEventBindableCollection(list:IList, numIterations:int, numItemsPerSecond:int, fillObjects:Boolean):Array
        {
            var timer:Timer = new Timer(TIMER_INTERVAL, numIterations);
            var numTicksPerSecond:Number = 1000/TIMER_INTERVAL;
            var numItemsPerTick:int = numItemsPerSecond/numTicksPerSecond;
            var timerResults:Array = [];
            timer.addEventListener(TimerEvent.TIMER, function(event:TimerEvent):void
            {
                var startTime:Number = getTimer();
                for (var i:int = 0; i < numItemsPerTick; i++)
                {
                    var newObject:UniqueEventBindableObject = new UniqueEventBindableObject();
                    if (fillObjects)
                        newObject.fillAllProperties();
                    list.addItem(newObject);
                }
                timerResults.push(getTimer() - startTime);
            });
            timer.addEventListener(TimerEvent.TIMER_COMPLETE, timerCompleteEventHandler);
            
            timer.start();
            return timerResults;
        }
        
        public function startRandomAdditionsSingleVersionEventBindableCollection(list:IList, numIterations:int, numItemsPerSecond:int, fillObjects:Boolean):Array
        {
            var timer:Timer = new Timer(TIMER_INTERVAL, numIterations);
            var numTicksPerSecond:Number = 1000/TIMER_INTERVAL;
            var numItemsPerTick:int = numItemsPerSecond/numTicksPerSecond;
            var timerResults:Array = [];
            timer.addEventListener(TimerEvent.TIMER, function(event:TimerEvent):void
            {
                var startTime:Number = getTimer();
                for (var i:int = 0; i < numItemsPerTick; i++)
                {
                    var newObject:SingleVersionEventBindableObject = new SingleVersionEventBindableObject();
                    if (fillObjects)
                        newObject.fillAllProperties();
                    list.addItem(newObject);
                }
                timerResults.push(getTimer() - startTime);
            });
            timer.addEventListener(TimerEvent.TIMER_COMPLETE, timerCompleteEventHandler);
            
            timer.start();
            return timerResults;
        }
        
        public function startRandomAdditionsNonBindableArray(list:Array, numIterations:int, numItemsPerSecond:int, fillObjects:Boolean):Array
        {
            var timer:Timer = new Timer(TIMER_INTERVAL, numIterations);
            var numTicksPerSecond:Number = 1000/TIMER_INTERVAL;
            var numItemsPerTick:int = numItemsPerSecond/numTicksPerSecond;
            var timerResults:Array = [];
            timer.addEventListener(TimerEvent.TIMER, function(event:TimerEvent):void
            {
                var startTime:Number = getTimer();
                for (var i:int = 0; i < numItemsPerTick; i++)
                {
                    var newObject:NonBindableObject = new NonBindableObject();
                    if (fillObjects)
                        newObject.fillAllProperties();
                    list.push(newObject);
                }
                timerResults.push(getTimer() - startTime);
            });
            timer.addEventListener(TimerEvent.TIMER_COMPLETE, timerCompleteEventHandler);
            
            timer.start();
            return timerResults;
        }
        
        public function startRandomAdditionsPropertyChangeBindableArray(list:Array, numIterations:int, numItemsPerSecond:int, fillObjects:Boolean):Array
        {
            var timer:Timer = new Timer(TIMER_INTERVAL, numIterations);
            var numTicksPerSecond:Number = 1000/TIMER_INTERVAL;
            var numItemsPerTick:int = numItemsPerSecond/numTicksPerSecond;
            var timerResults:Array = [];
            timer.addEventListener(TimerEvent.TIMER, function(event:TimerEvent):void
            {
                var startTime:Number = getTimer();
                for (var i:int = 0; i < numItemsPerTick; i++)
                {
                    var newObject:PropertyChangeBindableObject = new PropertyChangeBindableObject();
                    if (fillObjects)
                        newObject.fillAllProperties();
                    list.push(newObject);
                }
                timerResults.push(getTimer() - startTime);
            });
            timer.addEventListener(TimerEvent.TIMER_COMPLETE, timerCompleteEventHandler);
            
            timer.start();
            return timerResults;
        }
        
        public function startRandomAdditionsUniqueEventBindableArray(list:Array, numIterations:int, numItemsPerSecond:int, fillObjects:Boolean):Array
        {
            var timer:Timer = new Timer(TIMER_INTERVAL, numIterations);
            var numTicksPerSecond:Number = 1000/TIMER_INTERVAL;
            var numItemsPerTick:int = numItemsPerSecond/numTicksPerSecond;
            var timerResults:Array = [];
            timer.addEventListener(TimerEvent.TIMER, function(event:TimerEvent):void
            {
                var startTime:Number = getTimer();
                for (var i:int = 0; i < numItemsPerTick; i++)
                {
                    var newObject:UniqueEventBindableObject = new UniqueEventBindableObject();
                    if (fillObjects)
                        newObject.fillAllProperties();
                    list.push(newObject);
                }
                timerResults.push(getTimer() - startTime);
            });
            timer.addEventListener(TimerEvent.TIMER_COMPLETE, timerCompleteEventHandler);
            
            timer.start();
            return timerResults;
        }
        
        public function startRandomAdditionsSingleVersionEventBindableArray(list:Array, numIterations:int, numItemsPerSecond:int, fillObjects:Boolean):Array
        {
            var timer:Timer = new Timer(TIMER_INTERVAL, numIterations);
            var numTicksPerSecond:Number = 1000/TIMER_INTERVAL;
            var numItemsPerTick:int = numItemsPerSecond/numTicksPerSecond;
            var timerResults:Array = [];
            timer.addEventListener(TimerEvent.TIMER, function(event:TimerEvent):void
            {
                var startTime:Number = getTimer();
                for (var i:int = 0; i < numItemsPerTick; i++)
                {
                    var newObject:SingleVersionEventBindableObject = new SingleVersionEventBindableObject();
                    if (fillObjects)
                        newObject.fillAllProperties();
                    list.push(newObject);
                }
                timerResults.push(getTimer() - startTime);
            });
            timer.addEventListener(TimerEvent.TIMER_COMPLETE, timerCompleteEventHandler);
            
            timer.start();
            return timerResults;
        }
        
        public function startRandomAdditionsNonBindableVector(list:Vector.<Object>, numIterations:int, numItemsPerSecond:int, fillObjects:Boolean):Array
        {
            var timer:Timer = new Timer(TIMER_INTERVAL, numIterations);
            var numTicksPerSecond:Number = 1000/TIMER_INTERVAL;
            var numItemsPerTick:int = numItemsPerSecond/numTicksPerSecond;
            var timerResults:Array = [];
            timer.addEventListener(TimerEvent.TIMER, function(event:TimerEvent):void
            {
                var startTime:Number = getTimer();
                for (var i:int = 0; i < numItemsPerTick; i++)
                {
                    var newObject:NonBindableObject = new NonBindableObject();
                    if (fillObjects)
                        newObject.fillAllProperties();
                    list.push(newObject);
                }
                timerResults.push(getTimer() - startTime);
            });
            timer.addEventListener(TimerEvent.TIMER_COMPLETE, timerCompleteEventHandler);
            
            timer.start();
            return timerResults;
        }
        
        public function startRandomAdditionsPropertyChangeBindableVector(list:Vector.<Object>, numIterations:int, numItemsPerSecond:int, fillObjects:Boolean):Array
        {
            var timer:Timer = new Timer(TIMER_INTERVAL, numIterations);
            var numTicksPerSecond:Number = 1000/TIMER_INTERVAL;
            var numItemsPerTick:int = numItemsPerSecond/numTicksPerSecond;
            var timerResults:Array = [];
            timer.addEventListener(TimerEvent.TIMER, function(event:TimerEvent):void
            {
                var startTime:Number = getTimer();
                for (var i:int = 0; i < numItemsPerTick; i++)
                {
                    var newObject:PropertyChangeBindableObject = new PropertyChangeBindableObject();
                    if (fillObjects)
                        newObject.fillAllProperties();
                    list.push(newObject);
                }
                timerResults.push(getTimer() - startTime);
            });
            timer.addEventListener(TimerEvent.TIMER_COMPLETE, timerCompleteEventHandler);
            
            timer.start();
            return timerResults;
        }
        
        public static const TEST_COMPLETE:String = "testComplete";
        
        private function timerCompleteEventHandler(event:TimerEvent):void
        {
            dispatchEvent(new Event(TEST_COMPLETE));
        }
        
        public function startRandomAdditionsUniqueEventBindableVector(list:Vector.<Object>, numIterations:int, numItemsPerSecond:int, fillObjects:Boolean):Array
        {
            var timer:Timer = new Timer(TIMER_INTERVAL, numIterations);
            var numTicksPerSecond:Number = 1000/TIMER_INTERVAL;
            var numItemsPerTick:int = numItemsPerSecond/numTicksPerSecond;
            var timerResults:Array = [];
            timer.addEventListener(TimerEvent.TIMER, function(event:TimerEvent):void
            {
                var startTime:Number = getTimer();
                for (var i:int = 0; i < numItemsPerTick; i++)
                {
                    var newObject:UniqueEventBindableObject = new UniqueEventBindableObject();
                    if (fillObjects)
                        newObject.fillAllProperties();
                    list.push(newObject);
                }
                timerResults.push(getTimer() - startTime);
            });
            timer.addEventListener(TimerEvent.TIMER_COMPLETE, timerCompleteEventHandler);
            
            timer.start();
            return timerResults;
        }
        
        public function startRandomAdditionsSingleVersionEventBindableVector(list:Vector.<Object>, numIterations:int, numItemsPerSecond:int, fillObjects:Boolean):Array
        {
            var timer:Timer = new Timer(TIMER_INTERVAL, numIterations);
            var numTicksPerSecond:Number = 1000/TIMER_INTERVAL;
            var numItemsPerTick:int = numItemsPerSecond/numTicksPerSecond;
            var timerResults:Array = [];
            timer.addEventListener(TimerEvent.TIMER, function(event:TimerEvent):void
            {
                var startTime:Number = getTimer();
                for (var i:int = 0; i < numItemsPerTick; i++)
                {
                    var newObject:SingleVersionEventBindableObject = new SingleVersionEventBindableObject();
                    if (fillObjects)
                        newObject.fillAllProperties();
                    list.push(newObject);
                }
                timerResults.push(getTimer() - startTime);
            });
            timer.addEventListener(TimerEvent.TIMER_COMPLETE, timerCompleteEventHandler);
            
            timer.start();
            return timerResults;
        }
        
        public function iterateOverAllElementsCollectionView(list:ICollectionView, numIterations:int):void
        {
            for (var iter:int = 0; iter < numIterations; iter++)
            {
                var cursor:IViewCursor = list.createCursor();
                
                var hasNext:Boolean = !cursor.afterLast;
                while (hasNext)
                {
                    var objectGotten:Object = cursor.current;
                    hasNext = cursor.moveNext();
                }
            }
        }
        
        public function iterateOverAllElementsCollectionGetItemAt(list:IList, numIterations:int):void
        {
            for (var iter:int = 0; iter < numIterations; iter++)
            {
                var len:int = list.length;
                for (var i:int = 0; i < len; i++)
                {
                    var objectGotten:Object = list.getItemAt(i);
                }
            }
        }
        
        public function iterateOverAllElementsCollectionBracketIndex(list:IList, numIterations:int):void
        {
            for (var iter:int = 0; iter < numIterations; iter++)
            {
                var len:int = list.length;
                for (var i:int = 0; i < len; i++)
                {
                    var objectGotten:Object = list[i];
                }
            }
        }
        
        public function iterateOverAllElementsCollectionForEach(list:IList, numIterations:int):void
        {
            for (var iter:int = 0; iter < numIterations; iter++)
            {
                for each (var object:Object in list)
                {
                    // do nothing
                }
            }
        }
        
        public function iterateOverAllElementsArrayFor(list:Array, numIterations:int):void
        {
            for (var iter:int = 0; iter < numIterations; iter++)
            {
                var len:int = list.length;
                for (var i:int = 0; i < len; i++)
                {
                    var objectGotten:Object = list[i];
                }
            }
        }
        
        public function iterateOverAllElementsArrayForEach(list:Array, numIterations:int):void
        {
            for (var iter:int = 0; iter < numIterations; iter++)
            {
                for each (var object:Object in list)
                {
                    // do nothing
                }
            }
        }
        
        public function iterateOverAllElementsVectorFor(list:Vector.<Object>, numIterations:int):void
        {
            for (var iter:int = 0; iter < numIterations; iter++)
            {
                var len:int = list.length;
                for (var i:int = 0; i < len; i++)
                {
                    var objectGotten:Object = list[i];
                }
            }
        }
        
        public function iterateOverAllElementsVectorForEach(list:Vector.<Object>, numIterations:int):void
        {
            for (var iter:int = 0; iter < numIterations; iter++)
            {
                for each (var object:Object in list)
                {
                    // do nothing
                }
            }
        }
        
        // test Array, Vector, ArrayList, ArrayCollection, GroupingCollection, VectorList
        
        // test one large write with full objects
        // test lots of updates
        // test lots of additions
        // test lots of updates and additions
        // test different ways to get items (getItemAt(), [], for each, for var)
        
        // test all above with filters, sort, and filters and sort
        // test with Grouping changes too
        
        // test all above with Bindable propertyChange object, individual event binding, no binding
    }
}