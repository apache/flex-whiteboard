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