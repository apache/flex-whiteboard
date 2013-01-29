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