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
	import flash.display.Sprite;

	public class HTML {
		public static var console:Console;
		public static var window:Window;
		public static var self:Window;
		public static var name:String;
		public static var location:Location;
		public static var history:History;
		public static var selection:Selection;
	
		public static var locationbar:Object;
		public static var menubar:Object;
		public static var personalbar:Object;
		public static var scrollbars:Object;
		public static var statusbar:Object;
		public static var toolbar:Object;
		
		public static function close():void { }
		public static function stop():void { }
		public static function focus():void { }
		public static function blur():void { }
		
		public static var frames:Object
		public static var length:Object;
		public static var top:Window;
		public static var opener:Object;
		public static var parent:Window;
		public static var frameElement:Element;

		public static function open(url:String, target:String=null, features:String=null, replace:String=null):Window { return null; }
		public static function getElement(indexOrName:*):Object { return null; }
		public static function setElement(name:String, value:Object):void { }
		
		public static var navigator:Navigator;
		
		public static function alert(message:String):void { }
		public static function confirm(message:String):Boolean { return false; }
		public static function prompt(message:String, _default:String = null ):Boolean { return false; }

		public static function print():void { }
		
		public static function showModalDialog(url:String, argument:Object):Object { return null; }
		public static function postMessage(message:Object, targetOrigin:String, ports:Array ):void { }
		
		public static var onabort:Function;
		public static var onafterprint:Function;
		public static var onbeforeprint:Function;
		public static var onbeforeunload:Function;
		public static var onblur:Function;
		public static var oncanplay:Function;
		public static var oncanplaythrough:Function;
		public static var onchange:Function;
		public static var onclick:Function;
		public static var oncontextmenu:Function;
		public static var ondblclick:Function;
		public static var ondrag:Function;
		public static var ondragend:Function;
		public static var ondragenter:Function;
		public static var ondragleave:Function;
		public static var ondragover:Function;
		public static var ondragstart:Function;
		public static var ondrop:Function;
		public static var ondurationchange:Function;
		public static var onemptied:Function;
		public static var onended:Function;
		public static var onerror:Function;
		public static var onfocus:Function;
		public static var onformchange:Function;
		public static var onforminput:Function;
		public static var onhashchange:Function;
		public static var oninput:Function;
		public static var oninvalid:Function;
		public static var onkeydown:Function;
		public static var onkeypress:Function;
		public static var onkeyup:Function;
		public static var onload:Function;
		public static var onloadeddata:Function;
		public static var onloadedmetadata:Function;
		public static var onloadstart:Function;
		public static var onmessage:Function;
		public static var onmousedown:Function;
		public static var onmousemove:Function;
		public static var onmouseout:Function;
		public static var onmouseover:Function;
		public static var onmouseup:Function;
		public static var onmousewheel:Function;
		public static var onoffline:Function;
		public static var ononline:Function;
		public static var onpause:Function;
		public static var onplay:Function;
		public static var onplaying:Function;
		public static var onpagehide:Function;
		public static var onpageshow:Function;
		public static var onpopstate:Function;
		public static var onprogress:Function;
		public static var onratechange:Function;
		public static var onreadystatechange:Function;
		public static var onredo:Function;
		public static var onresize:Function;
		public static var onscroll:Function;
		public static var onseeked:Function;
		public static var onseeking:Function;
		public static var onselect:Function;
		public static var onshow:Function;
		public static var onstalled:Function;
		public static var onstorage:Function;
		public static var onsubmit:Function;
		public static var onsuspend:Function;
		public static var ontimeupdate:Function;
		public static var onundo:Function;
		public static var onunload:Function;
		public static var onvolumechange:Function;
		public static var onwaiting:Function;
		
		public static function getComputedStyle(elt:Element, pseudoElt:String):CssStyleDeclaration { return null; }
		
		public static var document:HtmlDocument;
		public static var styleMedia:StyleMedia;
		public static var screen:Screen;
		
		public static var innerWidth:int;
		public static var innerHeight:int;
		
		public static var pageXOffset:int;
		public static var pageYOffset:int;
		
		public static function scroll(x:int, y:int):void { }
		public static function scrollTo(x:int, y:int):void { }
		public static function scrollBy(x:int, y:int):void { }		
		
		public static var screenX:int;
		public static var screenY:int;
		public static var outerWidth:int;
		public static var outerHeight:int;
		
		public static function setTimeout(handler:Function):int { return 0; }
		public static function clearTimeout(handle:int):void { }
		public static function setInterval(handler:Function, timeout:Object=null):int { return 0; }
		public static function clearInterval(handle:int):void { }
		
		public static function escape(s:String):String { return null; }
		public static function decodeURIComponent(encodedURIString:String):String { return null; }
		public static function encodeURIComponent(encodedURIString:String):String { return null; }
		public static function encodeURI(URIString:String):String { return null; }
		public static function decodeURI(URIString:String):String { return null; }
		public static function unescape(charString:String):String { return null; }
		
	}
}