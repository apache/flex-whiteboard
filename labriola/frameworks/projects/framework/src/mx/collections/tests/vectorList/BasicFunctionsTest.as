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
	import mx.collections.IList;
	import mx.collections.VectorList;
	import mx.core.IPropertyChangeNotifier;
	
	import org.flexunit.assertThat;
	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertFalse;
	import org.flexunit.asserts.assertNotNull;
	import org.flexunit.asserts.assertStrictlyEquals;
	import org.flexunit.asserts.assertTrue;
	import org.hamcrest.collection.hasItem;
	import org.hamcrest.core.not;
	import org.hamcrest.object.instanceOf;

	public class BasicFunctionsTest {

		private static const EMPTY:int = 0;
	
		[Test]
		public function shouldImplementIList():void {
			var vectorList:VectorList = new VectorList( null );
			assertThat( vectorList, instanceOf( IList ) );
		}

		[Test]
		public function shouldImplementIPropertyChangeNotifier():void {
			var vectorList:VectorList = new VectorList( null );
			assertThat( vectorList, instanceOf( IPropertyChangeNotifier ) );
		}

		[Test]
		public function lengthShouldBeEmptyWithNullSource():void {
			var vectorList:VectorList = new VectorList( null );
			assertEquals( EMPTY, vectorList.length );
		}

		[Test(expects="TypeError")]
		public function shouldReceiveErrorWithNonVectorType():void {
			var vectorList:VectorList = new VectorList( [] );
		}

		[Test]
		public function lengthShouldBeEmptyWhenEmptyVectorProvided():void {
			var vectorList:VectorList = new VectorList( new Vector.<int>() );
			assertEquals( EMPTY, vectorList.length );
		}

		[Test]
		public function lengthShouldBe1WhenVectorLength1Provided():void {
			var vectorList:VectorList = new VectorList( new Vector.<int>(1) );
			assertEquals( 1, vectorList.length );
		}

		[Test]
		public function sourcePropertyShouldBeStrictlyEqualToProvidedVector():void {
			var vector:Vector.<int> = new Vector.<int>();
			var vectorList:VectorList = new VectorList( vector );
			assertStrictlyEquals( vector, vectorList.source );
		}

		[Test]
		public function shouldSetUIDAtConstruction():void {
			var vectorList:VectorList = new VectorList( new <int>[] );

			assertNotNull( vectorList.uid );
			assertTrue( vectorList.uid.length > 0 );
		}

		[Test]
		public function multipleVectorListsShouldNotShareAUID():void {
			var vectorList1:VectorList = new VectorList( new <int>[] );
			var vectorList2:VectorList = new VectorList( new <int>[] );
			var vectorList3:VectorList = new VectorList( new <int>[] );
			
			assertTrue( vectorList1.uid != vectorList2.uid );
			assertTrue( vectorList2.uid != vectorList3.uid );
			assertTrue( vectorList1.uid != vectorList3.uid );
		}

		[Test]
		public function shouldBeAbleToSetUID():void {
			const newUID:String = "3.14159265358";
			var vectorList:VectorList = new VectorList( new <int>[] );
			
			assertFalse( vectorList.uid == newUID );
			
			vectorList.uid = newUID;
			assertTrue( vectorList.uid == newUID );
		}

		[Test]
		public function setItemAtShouldUpdateValueAtPosition():void {
			const value:int = 5;
			const position:int = 2;
			var vector:Vector.<int> = new <int>[ 3, 7, 9, 11, 13 ];
			var vectorList:VectorList = new VectorList( vector );
			
			assertThat( vector, not( hasItem( value ) ) );
			vectorList.setItemAt( value, position );
			assertThat( vector, hasItem( value ) );
			assertEquals( value, vector[ position ] );
		}

		[Test]
		public function setItemAtShouldReturnOldValueWhenSettingNewValue():void {
			const newValue:int = 5;
			const oldValue:int = 9;
			const position:int = 2;
			var vector:Vector.<int> = new <int>[ 3, 7, oldValue, 11, 13 ];
			var vectorList:VectorList = new VectorList( vector );
			
			
			assertEquals( oldValue, vectorList.setItemAt( newValue, position ) );
		}

		[Test(expects="RangeError")]
		public function setItemAtShouldThrowRangeErrorForOutOfBoundsIndex():void {
			const value:int = 100;
			const position:int = 2;
			var vector:Vector.<int> = new <int>[ 3 ];
			var vectorList:VectorList = new VectorList( vector );
			
			vectorList.setItemAt( value, position );
		}
	}
}