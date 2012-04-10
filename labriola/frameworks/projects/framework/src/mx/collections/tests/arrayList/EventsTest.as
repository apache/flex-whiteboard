package mx.collections.tests.arrayList {
	import flash.events.EventDispatcher;
	
	import mx.collections.ArrayList;
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
			var arrayList:ArrayList = new ArrayList();

			expectEvent.from( arrayList ).
				hasType( CollectionEvent.COLLECTION_CHANGE ).
				instanceOf( CollectionEvent ).
				hasPropertyWithValue( "kind", CollectionEventKind.RESET ).
				once();

			arrayList.source = [ 1, 2, 3, 4 ];
		}

		[Test]
		public function shouldReceiveCollectionResetWhenSettingSourceToNull():void {
			var arrayList:ArrayList = new ArrayList();
			
			expectEvent.from( arrayList ).
				hasType( CollectionEvent.COLLECTION_CHANGE ).
				instanceOf( CollectionEvent ).
				hasPropertyWithValue( "kind", CollectionEventKind.RESET ).
				once();
			
			arrayList.source = null;
		}

		[Test]
		public function shouldReceiveCollectionEventWhenAddingItem():void {
			const value:int = 5;
			var arrayList:ArrayList = new ArrayList( [ 1, 2, 3, 4 ] );
			
			expectEvent.from( arrayList ).
				hasType( CollectionEvent.COLLECTION_CHANGE ).
				instanceOf( CollectionEvent ).
				hasPropertyWithValue( "kind", CollectionEventKind.ADD ).
				hasPropertyWithValue( "items", allOf( arrayWithSize( 1 ), hasItem( value ) ) ). 
				once();
			
			arrayList.addItem( value );
		}
		
		[Test]
		public function shouldReceivePropertyChangeEventWhenAddingItem():void {
			const value:int = 5;
			var index:int = 0;
			var arrayList:ArrayList = new ArrayList( [ 1, 2, 3, 4 ] );
			
			index = arrayList.length;
			
			expectEvent.from( arrayList ).
				hasType( PropertyChangeEvent.PROPERTY_CHANGE ).
				instanceOf( PropertyChangeEvent ).
				hasPropertyWithValue( "property", index ).
				hasPropertyWithValue( "newValue", value ). 
				once();
			
			arrayList.addItem( value );
		}

		[Test]
		public function shouldReceiveCollectionEventWhenAddingItemAtIndex():void {
			const value:int = 5;
			const index:int = 2;
			var arrayList:ArrayList = new ArrayList( [ 1, 2, 3, 4 ] );
			
			expectEvent.from( arrayList ).
				hasType( CollectionEvent.COLLECTION_CHANGE ).
				instanceOf( CollectionEvent ).
				hasPropertyWithValue( "kind", CollectionEventKind.ADD ).
				hasPropertyWithValue( "items", allOf( arrayWithSize( 1 ), hasItem( value ) ) ). 
				once();
			
			arrayList.addItemAt( value, index );
		}
		
		[Test]
		public function shouldReceivePropertyChangeEventWhenAddingItemAtIndex():void {
			const value:int = 5;
			const index:int = 2;
			var arrayList:ArrayList = new ArrayList( [ 1, 2, 3, 4 ] );
			
			expectEvent.from( arrayList ).
				hasType( PropertyChangeEvent.PROPERTY_CHANGE ).
				instanceOf( PropertyChangeEvent ).
				hasPropertyWithValue( "property", index ).
				hasPropertyWithValue( "newValue", value ). 
				once();
			
			arrayList.addItemAt( value, index );
		}

		[Test]
		public function childPropertyChangeEventsShouldPropagateWhenAddedToArrayList():void {
			const index:uint = 1;
			const propertyName:String = "dummy";
			const propertyOldVal:String = "dummyOldVal";
			const propertyNewVal:String = "dummyNewVal";

			var array:Array = [];
			var eventDispatcher:EventDispatcher = new EventDispatcher();
			var arrayList:ArrayList = new ArrayList( array );
			
			arrayList.addItem( new EventDispatcher() );
			arrayList.addItemAt( eventDispatcher, index );
			
			expectEvent.from( arrayList ).
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
		public function childPropertyChangeEventsShouldStopPropagatingWhenRemovedFromArrayList():void {
			const index:uint = 1;
			const propertyName:String = "dummy";
			const propertyOldVal:String = "dummyOldVal";
			const propertyNewVal:String = "dummyNewVal";
			
			var array:Array = [];
			var eventDispatcher:EventDispatcher = new EventDispatcher();
			var arrayList:ArrayList = new ArrayList( array );
			
			arrayList.addItem( new EventDispatcher() );
			arrayList.addItemAt( eventDispatcher, index );
			arrayList.removeItemAt( index );
			
			expectEvent.from( arrayList ).
				hasType( PropertyChangeEvent.PROPERTY_CHANGE ).
				never();
			
			eventDispatcher.dispatchEvent( PropertyChangeEvent.createUpdateEvent( eventDispatcher, propertyName , propertyOldVal, propertyNewVal ) );
		}

		[Test(description="This is an example of a test that codifies existing behavior, but it may be WRONG behavior")]
		public function collectChangeEventsShouldBeReceivedWhenChildPropertyChangeEventOccurs():void {
			const propertyName:String = "dummy";
			const propertyOldVal:String = "dummyOldVal";
			const propertyNewVal:String = "dummyNewVal";
			
			var array:Array = [];
			var eventDispatcher:EventDispatcher = new EventDispatcher();
			var arrayList:ArrayList = new ArrayList( array );
			
			arrayList.addItem( eventDispatcher );
			
			expectEvent.from( arrayList ).
				hasType( CollectionEvent.COLLECTION_CHANGE ).
				instanceOf( CollectionEvent ).
				hasPropertyWithValue( "kind", CollectionEventKind.UPDATE ).
				hasPropertyWithValue( "location", -1 ). 
				hasPropertyWithValue( "oldLocation", -1 ). 
				once();
			
			eventDispatcher.dispatchEvent( PropertyChangeEvent.createUpdateEvent( eventDispatcher, propertyName , propertyOldVal, propertyNewVal ) );
		}

		[Test]
		public function childPropertyChangeEventsShouldPropagateWhenAddedViaSourceToArrayList():void {
			const index:uint = 1;
			const propertyName:String = "dummy";
			const propertyOldVal:String = "dummyOldVal";
			const propertyNewVal:String = "dummyNewVal";
			
			var array:Array = [];
			var eventDispatcher:EventDispatcher = new EventDispatcher();
			array.push( new EventDispatcher() );
			array.push( eventDispatcher );

			var arrayList:ArrayList = new ArrayList( array );
			
			expectEvent.from( arrayList ).
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
		public function childPropertyChangeEventsShouldStopPropagatingWhenRemovedViaSourceFromArrayList():void {
			const index:uint = 1;
			const propertyName:String = "dummy";
			const propertyOldVal:String = "dummyOldVal";
			const propertyNewVal:String = "dummyNewVal";
			
			var array:Array = [];
			var eventDispatcher:EventDispatcher = new EventDispatcher();
			array.push( new EventDispatcher() );
			array.push( eventDispatcher );

			var arrayList:ArrayList = new ArrayList( array );
			arrayList.source = new Array();
			
			expectEvent.from( arrayList ).
				hasType( PropertyChangeEvent.PROPERTY_CHANGE ).
				never();
			
			eventDispatcher.dispatchEvent( PropertyChangeEvent.createUpdateEvent( eventDispatcher, propertyName , propertyOldVal, propertyNewVal ) );
		}
		
		[Test(description="This test relies upon the patched version of ArrayList in my whiteboard")]
		public function itemUpdatedShouldDispatchPropertyChangeEvent():void {
			const propertyName:String = "dummy";
			const propertyOldVal:String = "dummyOldVal";
			const propertyNewVal:String = "dummyNewVal";
			
			var array:Array = [];
			var eventDispatcher:EventDispatcher = new EventDispatcher();
			var arrayList:ArrayList = new ArrayList( array );
			
			arrayList.addItem( eventDispatcher );
			
			expectEvent.from( arrayList ).
				hasType( PropertyChangeEvent.PROPERTY_CHANGE ).
				instanceOf( PropertyChangeEvent ).
				hasPropertyWithValue( "kind", PropertyChangeEventKind.UPDATE ).
				hasPropertyWithValue( "newValue", propertyNewVal ). 
				hasPropertyWithValue( "oldValue", propertyOldVal ). 
				hasPropertyWithValue( "property", "-1" + '.' + propertyName ). 
				hasPropertyWithValue( "source", eventDispatcher ). 
				once();

			arrayList.itemUpdated( eventDispatcher, propertyName, propertyOldVal, propertyNewVal );
		}

		[Test(description="We should really consider if this is the behavior we want here.")]
		public function itemUpdatedShouldDispatchCollectionChangeEvent():void {
			const propertyName:String = "dummy";
			const propertyOldVal:String = "dummyOldVal";
			const propertyNewVal:String = "dummyNewVal";
			
			var array:Array = [];
			var eventDispatcher:EventDispatcher = new EventDispatcher();
			var arrayList:ArrayList = new ArrayList( array );
			
			arrayList.addItem( eventDispatcher );
			
			expectEvent.from( arrayList ).
				hasType( CollectionEvent.COLLECTION_CHANGE ).
				instanceOf( CollectionEvent ).
				hasPropertyWithValue( "kind", CollectionEventKind.UPDATE ).
				hasPropertyWithValue( "location", -1 ). 
				hasPropertyWithValue( "oldLocation", -1 ). 
				once();
			
			arrayList.itemUpdated( eventDispatcher, propertyName, propertyOldVal, propertyNewVal );
		}

		[Test]
		public function removeAllShouldDispatchResetEvent():void {
			var array:Array = [ 5, 7, 9, 11, 13 ];
			var arrayList:ArrayList = new ArrayList( array );

			expectEvent.from( arrayList ).
				hasType( CollectionEvent.COLLECTION_CHANGE ).
				instanceOf( CollectionEvent ).
				hasPropertyWithValue( "kind", CollectionEventKind.RESET ).
				hasPropertyWithValue( "location", -1 ). 
				hasPropertyWithValue( "oldLocation", -1 ). 
				once();

			arrayList.removeAll();
		}

		[Test]
		public function removeItemAtShouldDispatchCollectionRemoveEvent():void {
			const position:int = 3;
			const value:int = 11;
			var array:Array = [ 5, 7, 9, value, 13 ];
			var arrayList:ArrayList = new ArrayList( array );
			
			expectEvent.from( arrayList ).
				hasType( CollectionEvent.COLLECTION_CHANGE ).
				instanceOf( CollectionEvent ).
				hasPropertyWithValue( "kind", CollectionEventKind.REMOVE ).
				hasPropertyWithValue( "location", position ). 
				hasPropertyWithValue( "items", allOf( arrayWithSize( 1 ), hasItem( value ) ) ). 
				once();
			
			arrayList.removeItemAt( position );
		}

		[Test]
		public function removeItemAtShouldDispatchPropertyChangeEvent():void {
			const position:int = 3;
			const value:int = 11;
			var array:Array = [ 5, 7, 9, value, 13 ];
			var arrayList:ArrayList = new ArrayList( array );
			
			expectEvent.from( arrayList ).
				hasType( PropertyChangeEvent.PROPERTY_CHANGE ).
				instanceOf( PropertyChangeEvent ).
				hasPropertyWithValue( "oldValue", value ). 
				hasPropertyWithValue( "property", position ). 
				once();
			
			arrayList.removeItemAt( position );
		}

		[Test]
		public function addItemAtShouldDispatchPropertyChangeEvent():void {
			const position:int = 3;
			const value:int = 11;
			var array:Array = [ 5, 7, 9, 13 ];
			var arrayList:ArrayList = new ArrayList( array );
			
			expectEvent.from( arrayList ).
				hasType( PropertyChangeEvent.PROPERTY_CHANGE ).
				instanceOf( PropertyChangeEvent ).
				hasPropertyWithValue( "newValue", value ). 
				hasPropertyWithValue( "property", position ). 
				once();
			
			arrayList.addItemAt( value, position );
		}

		[Test]
		public function setItemAtShouldDispatchPropertyChangeEvent():void {
			const position:int = 2;
			const oldValue:int = 11;
			const newValue:int = 11;
			var array:Array = [ 5, 7, oldValue, 13 ];
			var arrayList:ArrayList = new ArrayList( array );
			
			expectEvent.from( arrayList ).
				hasType( PropertyChangeEvent.PROPERTY_CHANGE ).
				instanceOf( PropertyChangeEvent ).
				hasPropertyWithValue( "oldValue", oldValue ). 
				hasPropertyWithValue( "newValue", newValue ). 
				hasPropertyWithValue( "property", position ). 
				once();
			
			arrayList.setItemAt( newValue, position );
		}

		[Test]
		public function setItemAtShouldDispatchCollectionRemoveEvent():void {
			const position:int = 2;
			const oldValue:int = 11;
			const newValue:int = 11;
			var array:Array = [ 5, 7, oldValue, 13 ];
			var arrayList:ArrayList = new ArrayList( array );
			
			expectEvent.from( arrayList ).
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
			
			arrayList.setItemAt( newValue, position );
		}


		public function EventsTest() {
		}
	}
}