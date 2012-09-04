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
// Original component created by Dan Florio (http://www.polygeek.com), and donated
// via Nick Kwiatkowski (quetwo) to the Apache Flex Project
////////////////////////////////////////////////////////////////////////////////

package org.apache.components
{

	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.system.Capabilities;
	import flash.utils.ByteArray;

	import spark.primitives.BitmapImage;

	public class ImageGate extends BitmapImage
	{

		private var _urlRequest:URLRequest;
		private var _urlLoader:URLLoader;
		private var _loader:Loader;
		private var _fileStream:FileStream;

		private var _url:String;
		private var _filename:String;
		private var _file:File;

		private var _assetURL:String;
		private var _assetURL160:String;
		private var _assetURL240:String;
		private var _assetURL320:String;

		private var _localFolder:String;

		public function ImageGate()
		{
			super();
		}

		private function findImage():void
		{

			/**
			 *     The _localFolder must be set in order to proceed.
			 */
			if (_localFolder == null)
			{
				return;
			}

			var gotAllMultiScreenURLs:Boolean = false;

			if (_assetURL160 != null
					&& _assetURL240 != null
					&& _assetURL320 != null)
			{

				gotAllMultiScreenURLs = true;
			}

			/**
			 *     If we don't have either of the _assetURL or all of the
			 *     multi-screen URLs then we can not proceed.
			 */
			if (_assetURL == null && !gotAllMultiScreenURLs)
			{
				return
			}

			if (_assetURL == '')
			{
				return
			}

			/**
			 * Check to see what the _url is going to be for this particular image.
			 *  -If _assetURL != null then use that url.
			 *  -Otherwise find the correct _url based on the current screen resolution.
			 */

			if (_assetURL != null)
			{
				_url = _assetURL;
			}
			else if (Capabilities.screenDPI >= 280)
			{
				_url = _assetURL320
			}
			else if (Capabilities.screenDPI >= 200)
			{
				_url = _assetURL240
			}
			else
			{
				_url = _assetURL160
			}

			_filename = _url.substring(_url.lastIndexOf('/') + 1);

			if (Capabilities.os.toLowerCase().indexOf('iphone') != -1 || Capabilities.os.toLowerCase().indexOf('ipad') != -1 || Capabilities.os.toLowerCase().indexOf('ipod') != -1)
			{
				// Store the downloaded files in the Cache directory on iOS devices only. This is to comply with the
				// new AppStore guidelines that are in effect as of iOS 5.1
				_file = new File(File.applicationDirectory.nativePath + "/\.\./Library/Caches").resolvePath(_localFolder + '/' + _filename);
			}
			else
			{
				// Store the downloaded files in the applicationStorage Directory.
				_file = File.applicationStorageDirectory.resolvePath(_localFolder + '/' + _filename);
			}

			if (_file.exists)
			{
				var byteArray:ByteArray = new ByteArray();
				_fileStream = new FileStream();
				_fileStream.open(_file, FileMode.READ);
				_fileStream.readBytes(byteArray);
				_fileStream.close();
				_fileStream = null;
				_file = null;

				_loader = new Loader();
				_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onBytesLoaded);
				_loader.loadBytes(byteArray);

			}
			else
			{
				downloadRemoteFile();
			}
		}

		private function onBytesLoaded(e:Event):void
		{
			this.source = new Bitmap(e.target.content.bitmapData);
			_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onBytesLoaded);

			// Cleanup
			_loader = null;
			_filename = null;
		}


		private function downloadRemoteFile():void
		{
			_urlLoader = new URLLoader();
			_urlRequest = new URLRequest(_url);
			_urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
			_urlLoader.addEventListener(Event.COMPLETE, onDownloadComplete);
			_urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onIOerror);
			_urlLoader.load(_urlRequest);
		}

		private function onDownloadComplete(e:Event):void
		{
			var byteArray:ByteArray = _urlLoader.data;
			_fileStream = new FileStream();
			_fileStream.open(_file, FileMode.WRITE);
			_fileStream.writeBytes(byteArray, 0, byteArray.length);
			_fileStream.close();

			_loader = new Loader();
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onBytesLoaded);
			_loader.loadBytes(byteArray);

			// Cleanup
			_urlLoader.close();
			_urlLoader = null;
			_fileStream = null;
			_urlRequest = null;
			_url = null;
		}

		private function onIOerror(e:IOErrorEvent):void
		{
			trace("image download error : " + _url + " : " + _filename);

			// Cleanup
			_urlLoader.close();
			_urlLoader = null;
			_fileStream = null;
			_filename = null;
		}

		/*	************************************************************
		 *	Setters
		 *	************************************************************ */
		public function set assetURL(value:String):void
		{
			if (_assetURL == value)
			{
				return;
			}
			_assetURL = value;

			findImage();
		}


		public function set localFolder(value:String):void
		{
			if (_localFolder == value)
			{
				return;
			}

			_localFolder = value;

			findImage();
		}

		public function set assetURL160(value:String):void
		{
			if (_assetURL160 == value)
			{
				return;
			}

			_assetURL160 = value;

			findImage();
		}


		public function set assetURL240(value:String):void
		{
			if (_assetURL240 == value)
			{
				return;
			}

			_assetURL240 = value;

			findImage();
		}


		public function set assetURL320(value:String):void
		{
			if (_assetURL320 == value)
			{
				return;
			}

			_assetURL320 = value;

			findImage();
		}

		/*	************************************************************
		 *	Getters
		 *	************************************************************ */
		public function get assetURL():String
		{
			return _assetURL;
		}

		public function get localFolder():String
		{
			return _localFolder;
		}

		public function get assetURL160():String
		{
			return _assetURL160;
		}

		public function get assetURL240():String
		{
			return _assetURL240;
		}

		public function get assetURL320():String
		{
			return _assetURL320;
		}
	}
}