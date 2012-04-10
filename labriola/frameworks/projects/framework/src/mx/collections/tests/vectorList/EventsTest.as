package mx.collections.tests.vectorList {
	import flash.events.EventDispatcher;
	
	import mx.collections.VectorList;
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;
	import mx.events.PropertyChangeEvent;
	import mx.events.PropertyChangeEventKind;
	
	import org.flexunit.events.rule.EventRule;
	import org.hamcrest.collection.arrayWithSize;
	import org.hamcrest.collection.hasItem;
	import org.hamcrest.core.allOf;
	import org.hamcrest.object.hasPropertyWithValue;
	import org.hamcrest.object.instanceOf;

	public class EventsTest {
		
		[Rule]
		public var expectEvent:EventRule = new EventRule();

		[Test]
		public function shouldReceiveCollectionResetWhenSettingSourceToValidValue():void {
			var vectorList:VectorList = new VectorList();

			expectEvent.from( vectorList ).
				hasType( CollectionEvent.COLLECTION_CHANGE ).
				instanceOf( CollectionEvent ).
				hasPropertyWithValue( "kind", CollectionEventKind.RESET ).
				once();

			vectorList.source = new <int>[ 1, 2, 3, 4 ];
		}

		[Test]
		public function shouldReceiveCollectionResetWhenSettingSourceToNull():void {
			var vectorList:VectorList = new VectorList();
			
			expectEvent.from( vectorList ).
				hasType( CollectionEvent.COLLECTION_CHANGE ).
				instanceOf( CollectionEvent ).
				hasPropertyWithValue( "kind", CollectionEventKind.RESET ).
				once();
			
			vectorList.source = null;
		}

		[Test]
		public function shouldReceiveCollectionEventWhenAddingItem():void {
			const value:int = 5;
			var vectorList:VectorList = new VectorList( new <int>[ 1, 2, 3, 4 ] );
			
			expectEvent.from( vectorList ).
				hasType( CollectionEvent.COLLECTION_CHANGE ).
				instanceOf( CollectionEvent ).
				hasPropertyWithValue( "kind", CollectionEventKind.ADD ).
				hasPropertyWithValue( "items", allOf( arrayWithSize( 1 ), hasItem( value ) ) ). 
				once();
			
			vectorList.addItem( value );
		}
		
		[Test]
		public function shouldReceivePropertyChangeEventWhenAddingItem():void {
			const value:int = 5;
			var index:int = 0;
			var vectorList:VectorList = new VectorList( new <int>[ 1, 2, 3, 4 ] );
			
			index = vectorList.length;
			
			expectEvent.from( vectorList ).
				hasType( PropertyChangeEvent.PROPERTY_CHANGE ).
				instanceOf( PropertyChangeEvent ).
				hasPropertyWithValue( "property", index ).
				hasPropertyWithValue( "newValue", value ). 
				once();
			
			vectorList.addItem( value );
		}

		[Test]
		public function shouldReceiveCollectionEventWhenAddingItemAtIndex():void {
			const value:int = 5;
			const index:int = 2;
			var vectorList:VectorList = new VectorList( new <int>[ 1, 2, 3, 4 ] );
			
			expectEvent.from( vectorList ).
				hasType( CollectionEvent.COLLECTION_CHANGE ).
				instanceOf( CollectionEvent ).
				hasPropertyWithValue( "kind", CollectionEventKind.ADD ).
				hasPropertyWithValue( "items", allOf( arrayWithSize( 1 ), hasItem( value ) ) ). 
				once();
			
			vectorList.addItemAt( value, index );
		}
		
		[Test]
		public function shouldReceivePropertyChangeEventWhenAddingItemAtIndex():void {
			const value:int = 5;
			const index:int = 2;
			var vectorList:VectorList = new VectorList( new <int>[ 1, 2, 3, 4 ] );
			
			expectEvent.from( vectorList ).
				hasType( PropertyChangeEvent.PROPERTY_CHANGE ).
				instanceOf( PropertyChangeEvent ).
				hasPropertyWithValue( "property", index ).
				hasPropertyWithValue( "newValue", value ). 
				once();
			
			vectorList.addItemAt( value, index );
		}

		[Test]
		public function childPropertyChangeEventsShouldPropagateWhenAddedToVectorList():void {
			const index:uint = 1;
			const propertyName:String = "dummy";
			const propertyOldVal:String = "dummyOldVal";
			const propertyNewVal:String = "dummyNewVal";

			var vector:Vector.<EventDispatcher> = new Vector.<EventDispatcher>();
			var eventDispatcher:EventDispatcher = new EventDispatcher();
			var vectorList:VectorList = new VectorList( vector );
			
			vectorList.addItem( new EventDispatcher() );
			vectorList.addItemAt( eventDispatcher, index );
			
			expectEvent.from( vectorList ).
				hasType( PropertyChangeEvent.PROPERTY_CHANGE ).
				instanceOf( PropertyChangeEvent ).
				hasPropertyWithValue( "kind", PropertyChangeEventKind.UPDATE ).
				hasPropertyWithValue( "newValue", propertyNewVal ). 
				hasPropertyWithValue( "oldValue", propertyOldVal ). 
				hasPropertyWithValue( "property", index + '.' + propertyName ). 
				hasPropertyWithValue( "source", eventDispatcher ). 
				once();
			
			eventDispatcher.dispatchEvent( PropertyChangeEvent.createUpdateEvent( eventDispatcher, propertyName , propertyOldVal, propertyNewVal ) );
		}

		[Test]
		public function childPropertyChangeEventsShouldStopPropagatingWhenRemovedFromVectorList():void {
			const index:uint = 1;
			const propertyName:String = "dummy";
			const propertyOldVal:String = "dummyOldVal";
			const propertyNewVal:String = "dummyNewVal";
			
			var vector:Vector.<EventDispatcher> = new Vector.<EventDispatcher>();
			var eventDispatcher:EventDispatcher = new EventDispatcher();
			var vectorList:VectorList = new VectorList( vector );
			
			vectorList.addItem( new EventDispatcher() );
			vectorList.addItemAt( eventDispatcher, index );
			vectorList.removeItemAt( index );
			
			expectEvent.from( vectorList ).
				hasType( PropertyChangeEvent.PROPERTY_CHANGE ).
				never();
			
			eventDispatcher.dispatchEvent( PropertyChangeEvent.createUpdateEvent( eventDispatcher, propertyName , propertyOldVal, propertyNewVal ) );
		}

		[Test(description="This is an example of a test that codifies existing behavior, but it may be WRONG behavior")]
		public function collectChangeEventsShouldBeReceivedWhenChildPropertyChangeEventOccurs():void {
			const propertyName:String = "dummy";
			const propertyOldVal:String = "dummyOldVal";
			const propertyNewVal:String = "dummyNewVal";
			
			var vector:Vector.<EventDispatcher> = new Vector.<EventDispatcher>();
			var eventDispatcher:EventDispatcher = new EventDispatcher();
			var vectorList:VectorList = new VectorList( vector );
			
			vectorList.addItem( eventDispatcher );
			
			expectEvent.from( vectorList ).
				hasType( CollectionEvent.COLLECTION_CHANGE ).
				instanceOf( CollectionEvent ).
				hasPropertyWithValue( "kind", CollectionEventKind.UPDATE ).
				hasPropertyWithValue( "location", -1 ). 
				hasPropertyWithValue( "oldLocation", -1 ). 
				once();
			
			eventDispatcher.dispatchEvent( PropertyChangeEvent.createUpdateEvent( eventDispatcher, propertyName , propertyOldVal, propertyNewVal ) );
		}

		[Test]
		public function childPropertyChangeEventsShouldPropagateWhenAddedViaSourceToVectorList():void {
			const index:uint = 1;
			const propertyName:String = "dummy";
			const propertyOldVal:String = "dummyOldVal";
			const propertyNewVal:String = "dummyNewVal";
			
			var vector:Vector.<EventDispatcher> = new Vector.<EventDispatcher>();
			var eventDispatcher:EventDispatcher = new EventDispatcher();
			vector.push( new EventDispatcher() );
			vector.push( eventDispatcher );

			var vectorList:VectorList = new VectorList( vector );
			
			expectEvent.from( vectorList ).
				hasType( PropertyChangeEvent.PROPERTY_CHANGE ).
				instanceOf( PropertyChangeEvent ).
				hasPropertyWithValue( "kind", PropertyChangeEventKind.UPDATE ).
				hasPropertyWithValue( "newValue", propertyNewVal ). 
				hasPropertyWithValue( "oldValue", propertyOldVal ). 
				hasPropertyWithValue( "property", index + '.' + propertyName ). 
				hasPropertyWithValue( "source", eventDispatcher ). 
				once();
			
			eventDispatcher.dispatchEvent( PropertyChangeEvent.createUpdateEvent( eventDispatcher, propertyName , propertyOldVal, propertyNewVal ) );
		}
		
		[Test]
		public function childPropertyChangeEventsShouldStopPropagatingWhenRemovedViaSourceFromVectorList():void {
			const index:uint = 1;
			const propertyName:String = "dummy";
			const propertyOldVal:String = "dummyOldVal";
			const propertyNewVal:String = "dummyNewVal";
			
			var vector:Vector.<EventDispatcher> = new Vector.<EventDispatcher>();
			var eventDispatcher:EventDispatcher = new EventDispatcher();
			vector.push( new EventDispatcher() );
			vector.push( eventDispatcher );

			var vectorList:VectorList = new VectorList( vector );
			vectorList.source = new Vector.<EventDispatcher>();
			
			expectEvent.from( vectorList ).
				hasType( PropertyChangeEvent.PROPERTY_CHANGE ).
				never();
			
			eventDispatcher.dispatchEvent( PropertyChangeEvent.createUpdateEvent( eventDispatcher, propertyName , propertyOldVal, propertyNewVal ) );
		}
		
		[Test(description="We should really consider if this is the behavior we want here. Right now mimics fixed ArrayList")]
		public function itemUpdatedShouldDispatchPropertyChangeEvent():void {
			const propertyName:String = "dummy";
			const propertyOldVal:String = "dummyOldVal";
			const propertyNewVal:String = "dummyNewVal";
			
			var vector:Vector.<EventDispatcher> = new Vector.<EventDispatcher>();
			var eventDispatcher:EventDispatcher = new EventDispatcher();
			var vectorList:VectorList = new VectorList( vector );
			
			vectorList.addItem( eventDispatcher );
			
			expectEvent.from( vectorList ).
				hasType( PropertyChangeEvent.PROPERTY_CHANGE ).
				instanceOf( PropertyChangeEvent ).
				hasPropertyWithValue( "kind", PropertyChangeEventKind.UPDATE ).
				hasPropertyWithValue( "newValue", propertyNewVal ). 
				hasPropertyWithValue( "oldValue", propertyOldVal ). 
				hasPropertyWithValue( "property", "-1" + '.' + propertyName ). 
				hasPropertyWithValue( "source", eventDispatcher ). 
				once();

			vectorList.itemUpdated( eventDispatcher, propertyName, propertyOldVal, propertyNewVal );
		}

		[Test(description="We should really consider if this is the behavior we want here. Right now mimics ArrayList")]
		public function itemUpdatedShouldDispatchCollectionChangeEvent():void {
			const propertyName:String = "dummy";
			const propertyOldVal:String = "dummyOldVal";
			const propertyNewVal:String = "dummyNewVal";
			
			var vector:Vector.<EventDispatcher> = new Vector.<EventDispatcher>();
			var eventDispatcher:EventDispatcher = new EventDispatcher();
			var vectorList:VectorList = new VectorList( vector );
			
			vectorList.addItem( eventDispatcher );
			
			expectEvent.from( vectorList ).
				hasType( CollectionEvent.COLLECTION_CHANGE ).
				instanceOf( CollectionEvent ).
				hasPropertyWithValue( "kind", CollectionEventKind.UPDATE ).
				hasPropertyWithValue( "location", -1 ). 
				hasPropertyWithValue( "oldLocation", -1 ). 
				once();
			
			vectorList.itemUpdated( eventDispatcher, propertyName, propertyOldVal, propertyNewVal );
		}

		[Test]
		public function removeAllShouldDispatchResetEvent():void {
			var vector:Vector.<int> = new <int>[ 5, 7, 9, 11, 13 ];
			var vectorList:VectorList = new VectorList( vector );

			expectEvent.from( vectorList ).
				hasType( CollectionEvent.COLLECTION_CHANGE ).
				instanceOf( CollectionEvent ).
				hasPropertyWithValue( "kind", CollectionEventKind.RESET ).
				hasPropertyWithValue( "location", -1 ). 
				hasPropertyWithValue( "oldLocation", -1 ). 
				once();

			vectorList.removeAll();
		}

		[Test]
		public function removeItemAtShouldDispatchCollectionRemoveEvent():void {
			const position:int = 3;
			const value:int = 11;
			var vector:Vector.<int> = new <int>[ 5, 7, 9, value, 13 ];
			var vectorList:VectorList = new VectorList( vector );
			
			expectEvent.from( vectorList ).
				hasType( CollectionEvent.COLLECTION_CHANGE ).
				instanceOf( CollectionEvent ).
				hasPropertyWithValue( "kind", CollectionEventKind.REMOVE ).
				hasPropertyWithValue( "location", position ). 
				hasPropertyWithValue( "items", allOf( arrayWithSize( 1 ), hasItem( value ) ) ). 
				once();
			
			vectorList.removeItemAt( position );
		}

		[Test]
		public function removeItemAtShouldDispatchPropertyChangeEvent():void {
			const position:int = 3;
			const value:int = 11;
			var vector:Vector.<int> = new <int>[ 5, 7, 9, value, 13 ];
			var vectorList:VectorList = new VectorList( vector );
			
			expectEvent.from( vectorList ).
				hasType( PropertyChangeEvent.PROPERTY_CHANGE ).
				instanceOf( PropertyChangeEvent ).
				hasPropertyWithValue( "oldValue", value ). 
				hasPropertyWithValue( "property", position ). 
				once();
			
			vectorList.removeItemAt( position );
		}

		[Test]
		public function addItemAtShouldDispatchPropertyChangeEvent():void {
			const position:int = 3;
			const value:int = 11;
			var vector:Vector.<int> = new <int>[ 5, 7, 9, 13 ];
			var vectorList:VectorList = new VectorList( vector );
			
			expectEvent.from( vectorList ).
				hasType( PropertyChangeEvent.PROPERTY_CHANGE ).
				instanceOf( PropertyChangeEvent ).
				hasPropertyWithValue( "newValue", value ). 
				hasPropertyWithValue( "property", position ). 
				once();
			
			vectorList.addItemAt( value, position );
		}

		[Test]
		public function setItemAtShouldDispatchPropertyChangeEvent():void {
			const position:int = 2;
			const oldValue:int = 11;
			const newValue:int = 11;
			var vector:Vector.<int> = new <int>[ 5, 7, oldValue, 13 ];
			var vectorList:VectorList = new VectorList( vector );
			
			expectEvent.from( vectorList ).
				hasType( PropertyChangeEvent.PROPERTY_CHANGE ).
				instanceOf( PropertyChangeEvent ).
				hasPropertyWithValue( "oldValue", oldValue ). 
				hasPropertyWithValue( "newValue", newValue ). 
				hasPropertyWithValue( "property", position ). 
				once();
			
			vectorList.setItemAt( newValue, position );
		}

		[Test]
		public function setItemAtShouldDispatchCollectionRemoveEvent():void {
			const position:int = 2;
			const oldValue:int = 11;
			const newValue:int = 11;
			var vector:Vector.<int> = new <int>[ 5, 7, oldValue, 13 ];
			var vectorList:VectorList = new VectorList( vector );
			
			expectEvent.from( vectorList ).
				hasType( CollectionEvent.COLLECTION_CHANGE ).
				instanceOf( CollectionEvent ).
				hasPropertyWithValue( "kind", CollectionEventKind.REPLACE ).
				hasPropertyWithValue( "location", position ). 
				hasPropertyWithValue( "items", allOf( arrayWithSize( 1 ), 
													  hasItem( allOf( instanceOf( PropertyChangeEvent ),
																	  hasPropertyWithValue( "oldValue", oldValue ),
																	  hasPropertyWithValue( "newValue", newValue ),
																	  hasPropertyWithValue( "property", position ) ) ) ) ). 
				once();
			
			vectorList.setItemAt( newValue, position );
		}


		public function EventsTest() {
		}
	}
}