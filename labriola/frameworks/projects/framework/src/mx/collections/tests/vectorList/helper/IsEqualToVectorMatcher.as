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

package mx.collections.tests.vectorList.helper {
	import org.hamcrest.BaseMatcher;
	
	public class IsEqualToVectorMatcher extends BaseMatcher {
		private var _value:Object;

		/**
		 * Constructor
		 *
		 * @param value Object the item being matched must be equal to
		 */
		public function IsEqualToVectorMatcher( value:Object ) {
			super();

			_value = value;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function matches(item:Object):Boolean {
			return areLengthsEqual(_value, item) && areElementsEqual(_value, item);
		}
		
		/**
		 * Checks if the given objects are of equal length
		 *
		 * @private
		 */
		private function areLengthsEqual(o1:Object, o2:Object):Boolean
		{
			return ( o1.length == o2.length );
		}
		
		/**
		 * Checks the elements of both objects are the equal
		 *
		 * @private
		 */
		private function areElementsEqual(o1:*, o2:Object):Boolean
		{
			for (var i:int = 0, n:int = o1.length; i < n; i++)
			{
				if (!o1[i] == o2[i] )
				{
					return false;
				}
			}
			return true;
		}
	}
}