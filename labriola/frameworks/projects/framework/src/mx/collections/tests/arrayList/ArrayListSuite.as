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

package mx.collections.tests.arrayList
{
	
	[Suite]
	[RunWith("org.flexunit.runners.Suite")]
	public class ArrayListSuite
	{
		public var test1:mx.collections.tests.arrayList.BasicFunctionsTest;
		public var test2:mx.collections.tests.arrayList.AddRemoveItemTest;
		public var test3:mx.collections.tests.arrayList.AddRemoveItemAtTest;
		public var test4:mx.collections.tests.arrayList.ConversionTest;
		public var test5:mx.collections.tests.arrayList.EventsTest;
		public var test6:mx.collections.tests.arrayList.ItemRetrievalTest;
	}
}