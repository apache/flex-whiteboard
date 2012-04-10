////////////////////////////////////////////////////////////////////////////////
//
//  Licensed to the Apache Software Foundation (ASF) under one or more
//  contributor license agreements.  See the NOTICE file distributed with
//  this work for additional information regarding copyright ownership.
//  The ASF licenses this file to You under the Apache License, Version 2.0
//  (the "License"); you may not use this file except in compliance with
//  the License.  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
////////////////////////////////////////////////////////////////////////////////

package mx.collections.tests.arrayList {
	import flash.events.EventDispatcher;
	
	import mx.collections.ArrayList;
	import mx.events.PropertyChangeEvent;
	
	import org.flexunit.assertThat;
	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertFalse;
	import org.flexunit.asserts.assertTrue;
	import org.hamcrest.collection.hasItem;
	import org.hamcrest.core.not;

	public class AddRemoveItemAtTest {
		
		[Test]
		public function addItemAtShouldInsertElementIntoArray():void {
			var array:Array = [ 7, 8, 9 ];
			var arrayList:ArrayList = new ArrayList( array );
			const value:int = 5;
			
			arrayList.addItemAt( value, 2 );
			assertEquals( 4, arrayList.length );
			assertEquals( value, array[ 2 ] );
		}

		public function addItemAtShouldAddEventListenerForEventDispatchers():void {
			const value:EventDispatcher = new EventDispatcher();
			var array:Array = [value];
			var arrayList:ArrayList = new ArrayList( array );
			
			assertFalse( value.hasEventListener( PropertyChangeEvent.PROPERTY_CHANGE ) );
			arrayList.addItemAt( value, 0 );
			assertTrue( value.hasEventListener( PropertyChangeEvent.PROPERTY_CHANGE ) );
		}

		[Test(expects="RangeError")]
		public function shouldReceiveRangeErrorAttemptingToAddItemAtNegativeIndex():void {
			var array:Array = [];
			var arrayList:ArrayList = new ArrayList( array );
			const value:int = 5;
			
			arrayList.addItemAt( value, -1 );
		}
		
		[Test(expects="RangeError")]
		public function shouldReceiveRangeErrorAttemptingToAddItemAtPastEndOfArray():void {
			var array:Array = [];
			var arrayList:ArrayList = new ArrayList( array );
			const value:int = 5;
			
			arrayList.addItemAt( value, 2 );
		}
		
		[Test]
		public function removeItemAtShouldRemoveItemFromArray():void {
			const value:int = 5;
			var array:Array = [ value ];
			var arrayList:ArrayList = new ArrayList( array );
			
			assertThat( array, hasItem( value ) );
			
			arrayList.removeItemAt( 0 );
			assertThat( array, not( hasItem( value ) ) );
		}

		public function removeItemAtShouldRemoveEventListenerForEventDispatchers():void {
			const value:EventDispatcher = new EventDispatcher();
			var array:Array = [value];
			var arrayList:ArrayList = new ArrayList( array );
			
			assertTrue( value.hasEventListener( PropertyChangeEvent.PROPERTY_CHANGE ) );
			arrayList.removeItemAt( 0 );
			assertFalse( value.hasEventListener( PropertyChangeEvent.PROPERTY_CHANGE ) );
		}
		
		[Test]
		public function removeItemAtShouldRemoveReturnRemovedItem():void {
			const value:int = 5;
			var array:Array = [ value ];
			var arrayList:ArrayList = new ArrayList( array );
			
			assertEquals( value, arrayList.removeItemAt( 0 ) );
		}

		[Test]
		public function removeItemAtShouldRemoveArbitraryNode():void {
			const value:int = 5;
			var array:Array = [ 3, 7, 9, value, 11, 13 ];
			var arrayList:ArrayList = new ArrayList( array );
			
			assertThat( array, hasItem( value ) );
			
			arrayList.removeItemAt( 3 );

			assertThat( array, not( hasItem( value ) ) );
		}

		[Test]
		public function removeItemAtShouldRemoveLastNode():void {
			const value:int = 5;
			var array:Array = [ 3, 7, 9, 11, 13, value ];
			var arrayList:ArrayList = new ArrayList( array );
			
			assertThat( array, hasItem( value ) );
			
			arrayList.removeItemAt( 5 );
			
			assertThat( array, not( hasItem( value ) ) );
		}

		[Test(expects="RangeError")]
		public function removeItemAtShouldThrowRangeErrorIfOutOfRangeIndexSupplied():void {
			const value:int = 5;
			var array:Array = [ value ];
			var arrayList:ArrayList = new ArrayList( array );

			arrayList.removeItemAt( 3 );
		}

		public function AddRemoveItemAtTest() {
		}
	}
}