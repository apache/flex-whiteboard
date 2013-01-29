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
package
{
	public class Console
	{
		public var memory:MemoryInfo;
		
		public function assert(condition:Boolean, ... scriptArgs):void {};
		public function count(... scriptArgs):void {};
		public function debug(... scriptArgs):void {};
		public function dir(... scriptArgs):void {};
		public function dirxml(... scriptArgs):void {};
		public function error(... scriptArgs):void {};
		public function group(... scriptArgs):void {};
		public function groupCollapsed(... scriptArgs):void {};
		public function groupEnd():void {};
		public function info(... scriptArgs):void {};
		public function log(... scriptArgs):void {};
		public function markTimeline(... scriptArgs):void {};
		public function time(title:String):void {};
		public function timeEnd(title:String, ... scriptArgs):void {};
		public function timeStamp(... scriptArgs):void {};
		public function trace(... scriptArgs):void {};
		public function warn(... scriptArgs):void {};			
	}
}