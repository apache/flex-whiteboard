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

package mx.collections.tests.arrayCollection {
	import mx.collections.ICollectionView;
	import mx.collections.IList;
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;
	
	import org.flexunit.assertThat;
	import org.flexunit.asserts.assertNull;
	import org.hamcrest.object.instanceOf;
	import org.hamcrest.object.sameInstance;

	public class BasicFunctionsTest {

		[Test]
		public function shouldImplementICollectionView():void {
			var collection:ArrayCollection = new ArrayCollection();
			assertThat( collection, instanceOf( ICollectionView ) );
		}

		[Test]
		public function instantiatingWithoutSourceShouldBuildOwnArrayList():void {
			var collection:ArrayCollection = new ArrayCollection();
			
			assertThat( collection.list, instanceOf( ArrayList ) );
		}

		[Test]
		public function instantiatingWithArrayShouldYieldListWithArray():void {
			var array:Array = [];
			var collection:ArrayCollection = new ArrayCollection( array );
			
			assertThat( array, sameInstance( ArrayList( collection.list ).source ) );
		}

		[Test]
		public function sourceShouldReturnArrayListSourceWhenListViable():void {
			var array:Array = [];
			var collection:ArrayCollection = new ArrayCollection( array );
			
			assertThat( array, sameInstance( collection.source ) );
		}

		[Test]
		public function sourceShouldReturnNullWhenListIsNull():void {
			var collection:ArrayCollection = new ArrayCollection();
			collection.list = null;
			
			assertNull( collection.source );
		}

		public function BasicFunctionsTest() {
		}
	}
}