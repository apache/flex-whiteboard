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

package mx.collections.tests.vectorList {
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	
	import mx.collections.VectorList;
	
	import org.flexunit.assertThat;
	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertFalse;
	import org.flexunit.asserts.assertStrictlyEquals;
	import org.flexunit.asserts.assertTrue;
	import org.hamcrest.collection.hasItem;
	import org.hamcrest.core.not;
	import org.hamcrest.object.sameInstance;

	public class AddRemoveItemTest {
		
		private static const EMPTY:int = 0;

		[Test(expects="TypeError")]
		public function addItemShouldNotAddItemToMismatchedVectorOfNonConvertibleTypes():void {
			var vector:Vector.<Sprite> = new <Sprite>[];
			var vectorList:VectorList = new VectorList( vector );
			
			const value:String = "Test";
			
			vectorList.addItem( value );
		}
		
		[Test]
		public function addItemShouldAddFirstItemToEmptyVector():void {
			var vector:Vector.<int> = new <int>[];
			var vectorList:VectorList = new VectorList( vector );
			const value:int = 5;
			
			assertThat( vector, not( hasItem( value ) ) );
			
			vectorList.addItem( value );
			assertEquals( 1, vectorList.length );
			assertThat( vector, hasItem( value ) );
		}
		
		[Test]
		public function addItemShouldAddItemToMismatchedVectorOfConvertibleTypes():void {
			//I actually find this an irritating behavior of Vector, but we need to ensure we aren't messing with it.
			var vector:Vector.<int> = new <int>[];
			var vectorList:VectorList = new VectorList( vector );
			
			const value:String = "5";
			
			assertThat( vector, not( hasItem( value ) ) );
			vectorList.addItem( value );
			assertThat( vector, hasItem( value ) );
		}
		
		[Test]
		public function addItemShouldAddLastItemToPopulatedVector():void {
			var vector:Vector.<int> = new <int>[ 7, 8, 9 ];
			var vectorList:VectorList = new VectorList( vector );
			const value:int = 5;
			
			assertEquals( 3, vectorList.length );
			
			vectorList.addItem( value );
			assertEquals( 4, vectorList.length );
			assertEquals( value, vector[ 3 ] );
		}
		
		[Test(expects="RangeError")]
		public function shouldReceiveErrorAttemptingToAddItemToFixedLengthVector():void {
			var vector:Vector.<int> = new Vector.<int>( 1, true );
			var vectorList:VectorList = new VectorList( vector );
			const value:int = 5;
			
			vectorList.addItem( value );
		}

		[Test]
		public function removeItemShouldRemoveSimpleItemFromVector():void {
			var vector:Vector.<int> = new <int>[];
			var vectorList:VectorList = new VectorList( vector );
			const value:int = 5;

			vectorList.addItem( value );
			assertThat( vector, hasItem( value ) );

			vectorList.removeItem( value );
			assertThat( vector, not( hasItem( value ) ) );
		}

		[Test]
		public function removeItemShouldRemoveSingleSimpleItemFromVector():void {
			var vector:Vector.<int> = new <int>[];
			var vectorList:VectorList = new VectorList( vector );
			const value:int = 5;
			
			vectorList.addItem( value );
			vectorList.addItem( value );
			assertThat( vector, hasItem( value ) );
			
			vectorList.removeItem( value );
			assertThat( vector, hasItem( value ) );
			assertEquals( 1, vector.length );
		}

		[Test]
		public function removeItemShouldRemoveComplexItemFromVector():void {
			var vector:Vector.<EventDispatcher> = new <EventDispatcher>[];
			var vectorList:VectorList = new VectorList( vector );
			const value:EventDispatcher = new EventDispatcher();
			
			vectorList.addItem( value );
			assertThat( vector, hasItem( value ) );
			
			vectorList.removeItem( value );
			assertThat( vector, not( hasItem( value ) ) );
		}

		[Test]
		public function removeItemShouldRemoveReturnTrueIfItemFound():void {
			var vector:Vector.<EventDispatcher> = new <EventDispatcher>[];
			var vectorList:VectorList = new VectorList( vector );
			const value:EventDispatcher = new EventDispatcher();
			
			vectorList.addItem( value );
			assertTrue( vectorList.removeItem( value ) );
		}

		[Test]
		public function removeItemShouldRemoveReturnFalseIfItemNotFound():void {
			var vector:Vector.<EventDispatcher> = new <EventDispatcher>[];
			var vectorList:VectorList = new VectorList( vector );
			const value:EventDispatcher = new EventDispatcher();
			
			assertFalse( vectorList.removeItem( value ) );
		}

		[Test]
		public function removeAllShouldEmptyVector():void {
			var vector:Vector.<int> = new <int>[ 5, 7, 9, 11, 13 ];
			var vectorList:VectorList = new VectorList( vector );
			
			assertEquals( 5, vector.length );
			
			vectorList.removeAll();

			assertEquals( EMPTY, vector.length );
		}

		public function AddRemoveItemTest() {
		}
	}
}