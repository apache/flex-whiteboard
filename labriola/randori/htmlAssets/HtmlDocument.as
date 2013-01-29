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
	public class HtmlDocument
	{
		public var activeElement:Element;
		public var alinkColor:String;
		public var all:HtmlAllCollection;
		public var bgColor:String;
		public var compatMode:String;
		public var designMode:String;
		public var dir:String;
		public var embeds:HtmlCollection;
		public var fgColor:String;
		public var height:int;
		public var linkColor:String;
		public var plugins:HtmlCollection;
		public var scripts:HtmlCollection;
		public var vlinkColor:String;
		public var width:int;
		
		public function captureEvents():void { return void; };
		public function clear():void { return void; };
		public function close():void { return void; };
		public function hasFocus():Boolean { return false; };
		public function open():void  { return void; };
		public function releaseEvents():void { return void; };
		public function write(text:String):void { return void; };
		public function writeln(text:String):void { return void; };
	}
}