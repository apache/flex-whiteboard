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

package org.apache.spark.components
{
	import flash.display.Sprite;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.system.Capabilities;
	import flash.ui.Keyboard;
	
	import mx.core.FlexGlobals;
	import mx.events.CloseEvent;
	import mx.managers.ISystemManager;
	import mx.resources.ResourceManager;
	
	import org.apache.spark.components.skins.AndroidAlertSkin;
	import org.apache.spark.components.skins.AndroidButtonSkin;
	import org.apache.spark.components.skins.AppleOSAlertSkin;
	import org.apache.spark.components.skins.AppleOSButtonSkin;
	import org.apache.spark.components.supportClasses.SkinnablePopUpComponent;
	
	import spark.components.Button;
	import spark.components.Group;
	import spark.components.Image;
	import spark.core.IDisplayText;
	
	
	//-------------------------------------------
	// Metadata Required for the Resource Bundle
	//-------------------------------------------
	[ResourceBundle("MobileAlert")]
	
	
	//-------------------------------------------
	// Metadata required for the skinning
	//-------------------------------------------
	[SkinState("normal")]
	[SkinState("disabled")]
		
	
	/**
	 *  The MobileAlert control is a pop-up dialog box that can contain a message,
	 *  a title, buttons (any combination of OK, Cancel, Yes, and No) and an icon.
	 *  The Alert control is usually modal, which means it will retain focus until
	 *  the user closes it.  This control is specific to Mobile, but it should work
	 *  on Desktop implementations.  If the user does not specify their own skin, it
	 *  will auto-sence between Android (default) and iOS skins.
	 *
	 *  <p>Import the org.apache.spark.components.MobileAlert class into your application,
	 *  and then call the static <code>show()</code> method in ActionScript to display
	 *  an Alert control. You cannot create an Alert control in MXML.</p>
	 *
	 *  <p>The Alert control closes when you select a button in the control,
	 *  or press the Escape key.</p>
	 *	 
	 *	 
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 11.0
	 *  @playerversion AIR 3.0
	 *  @productversion Flex 4.6
	 */
	public class MobileAlert extends SkinnablePopUpComponent
	{

		//----------------------------------------------------
		// SkinParts as required by any of the attached skins
		//----------------------------------------------------
		[SkinPart(required="true")] public var titleDisplay:IDisplayText;
		[SkinPart(required="true")] public var messageDisplay:IDisplayText;
		[SkinPart(required="false")] public var icon:Image;
		[SkinPart(required="true")] public var buttonBarGroup:Group;
		
		//-----------------------------------------------
		// Static Properties
		//-----------------------------------------------
		
		/**
		 *  Value that enables a Yes button on the Alert control when passed
		 *  as the <code>flags</code> parameter of the <code>show()</code> method.
		 *  You can use the | operator to combine this bitflag
		 *  with the <code>OK</code>, <code>CANCEL</code>,
		 *  <code>NO</code>.
		 * 
		 *  @langversion 3.0
	 	 *  @playerversion Flash 11.0
	 	 *  @playerversion AIR 3.0
	 	 *  @productversion Flex 4.6
		 */
		public static const YES:uint = 0x0001;
		/**
		 *  Value that enables a No button on the Alert control when passed
		 *  as the <code>flags</code> parameter of the <code>show()</code> method.
		 *  You can use the | operator to combine this bitflag
		 *  with the <code>OK</code>, <code>CANCEL</code>,
		 *  <code>YES</code>.
		 * 
		 *  @langversion 3.0
	 	 *  @playerversion Flash 11.0
	 	 *  @playerversion AIR 3.0
	 	 *  @productversion Flex 4.6
		 */
		public static const NO:uint = 0x0002;
		/**
		 *  Value that enables an OK button on the Alert control when passed
		 *  as the <code>flags</code> parameter of the <code>show()</code> method.
		 *  You can use the | operator to combine this bitflag
		 *  with the <code>CANCEL</code>, <code>YES</code>,
		 *  <code>NO</code>.
		 * 
		 *  @langversion 3.0
	 	 *  @playerversion Flash 11.0
	 	 *  @playerversion AIR 3.0
	 	 *  @productversion Flex 4.6
		 */
		public static const OK:uint = 0x0004;
		/**
		 *  Value that enables a Cancel button on the Alert control when passed
		 *  as the <code>flags</code> parameter of the <code>show()</code> method.
		 *  You can use the | operator to combine this bitflag
		 *  with the <code>OK</code>, <code>YES</code>,
		 *  <code>NO</code>.
		 * 
		 *  @langversion 3.0
	 	 *  @playerversion Flash 11.0
	 	 *  @playerversion AIR 3.0
	 	 *  @productversion Flex 4.6
		 */
		public static const CANCEL:uint = 0x0008;
		
		/**
		 *  Built-in Waring Icon.  Use the iconClass property of the show() method
		 *  to set a different icon.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 11.0
		 *  @playerversion AIR 3.0
		 *  @productversion Flex 4.6
		 */
		[Embed(source="org/apache/spark/components/assets/WarningIcon.png")]
		protected var defaultAlertIconClass:Class
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  Constructor.
		 *
		 *  @langversion 3.0
		 *  @playerversion Flash 11.0
		 *  @playerversion AIR 3.0
		 *  @productversion Flex 4.6
		 */
		public function MobileAlert()
		{
			super();
		}

		
		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  Static method that pops up the MobileAlert control. The MobileAlert control
		 *  closes when you select a button in the control, or press the Escape key.
		 *
		 *  @param message Text string that appears in the MobileAlert control.
		 *  This text is the main text within the alert dialog box.
		 *
		 *  @param title Text string that appears in the title bar.
		 *  This text is in the title area of the alert dialog box
		 *
		 *  @param flags Which buttons to place in the MobileAlert control.
		 *  Valid values are <code>MobileAlert.OK</code>, <code>MobileAlert.CANCEL</code>,
		 *  <code>MobileAlert.YES</code>, and <code>MobileAlert.NO</code>.
		 *  The default value is <code>MobileAlert.OK</code>.
		 *  Use the bitwise OR operator to display more than one button.
		 *  For example, passing <code>(MobileAlert.YES | MobileAlert.NO)</code>
		 *  displays Yes and No buttons (localized).
		 *
		 *  @param parent Object upon which the MobileAlert control centers itself.
		 *
		 *  @param closeHandler Event handler that is called when any button
		 *  on the MobileAlert control is pressed.
		 *  The event object passed to this handler is an instance of CloseEvent;
		 *  the <code>detail</code> property of this object contains the value
		 *  <code>MobileAlert.OK</code>, <code>MobileAlert.CANCEL</code>,
		 *  <code>MobileAlert.YES</code>, or <code>MobileAlert.NO</code>.
		 *
		 *  @param iconClass Class of the icon that is placed to the left
		 *  of the text in the MobileAlert control.
		 *
		 *  @param defaultButtonFlag A bitflag that specifies the default button.
		 *  You can specify one and only one of
		 *  <code>MobileAlert.OK</code>, <code>MobileAlert.CANCEL</code>,
		 *  <code>MobileAlert.YES</code>, or <code>MobileAlert.NO</code>.
		 *  The default value is <code>MobileAlert.OK</code>.
		 *  Pressing the Enter key triggers the default button
		 *  just as if you clicked it. Pressing Escape triggers the Cancel
		 *  or No button just as if you selected it.
		 *
		 *  @param forcedSkin The Spark skin class that you wish to use to override
		 *  the built-in skins to this control.  The skins must include a titleDisplay,
		 *  a messageDisplay, an icon and a button area (buttonBarGroup)
		 *
		 *  @return A reference to the MobileAlert control.
		 *
		 *  @see mx.events.CloseEvent
		 *
		 *  @langversion 3.0
		 *  @playerversion Flash 11.0
		 *  @playerversion AIR 3.0
		 *  @productversion Flex 4.6
		 */
		public static function show(message:String,
									title:String,
									flags:uint = OK,
									parent:Sprite = null,
									closeHandler:Function = null,
									iconClass:Class = null,
									defaultButtonIndex:uint = 0,
									modal:Boolean = true,
									forcedSkin:Class = null,
									buttonSkin:Class = null):MobileAlert
		{
			var mobileAlert:MobileAlert = new MobileAlert();
			mobileAlert.title = title;
			mobileAlert.message = message;
			mobileAlert.flags = flags;
			mobileAlert.defaultButtonIndex = defaultButtonIndex;
						
			if (!parent)
			{
				var systemManager:ISystemManager = ISystemManager(FlexGlobals.topLevelApplication.systemManager);
				parent = Sprite(FlexGlobals.topLevelApplication);
			}
			
			if (iconClass != null)
			{
				mobileAlert.iconClass = iconClass;	
			}
			else
			{
				mobileAlert.iconClass = mobileAlert.defaultAlertIconClass;
			}
			
			if (closeHandler != null)
			{
				mobileAlert.addEventListener(CloseEvent.CLOSE, closeHandler);
			}
			
			if (forcedSkin == null)
			{
				var os:String = Capabilities.os.toLowerCase();
				if(os.indexOf('iphone') !=-1 || os.indexOf('ipad') !=-1 || os.indexOf('ipod') !=-1)
				{
					// we are on an iOS device
					forcedSkin = AppleOSAlertSkin;
					mobileAlert.buttonStyle = AppleOSButtonSkin;
					
				}
				else
				{
					// we are assumed to be on an android device.
					forcedSkin = AndroidAlertSkin;
					mobileAlert.buttonStyle = AndroidButtonSkin;
				}
			}
			else
			{
				if (buttonSkin != null)
				{
					mobileAlert.buttonStyle = buttonSkin;
				}
			}
			
			//open and center the alert
			mobileAlert.setStyle("skinClass", forcedSkin);
			mobileAlert.open(parent, modal);
			
			mobileAlert.x = (parent.width / 2) - (mobileAlert.width / 2);
			mobileAlert.y = (parent.height / 2) - (mobileAlert.height / 2); 

			return mobileAlert;
		}

		//--------------------------------------------------------------------------
		//
		//  Overridden properties
		//
		//--------------------------------------------------------------------------
		/**
		 * Class that returns the current skin state.  Changes to 'closed' when the MobileAlert is closed.
		 *  
		 * @return current skin state
		 * 
		 */		
		override protected function getCurrentSkinState():String
		{
			if (!isOpen)
			{
				return "closed";
			}
			else
			{
				return "normal";
			}
		} 
		
		/**
		 * Required class to hook into the Spark skinning archetiture.
		 *  
		 * @param partName Part Name being processed.
		 * @param instance Current Skin Part being processed.
		 * 
		 */
		override protected function partAdded(partName:String, instance:Object) : void
		{
			super.partAdded(partName, instance);
			
			if (instance == titleDisplay)
			{
				titleDisplay.text = title;
			}
			
			if (instance == messageDisplay)
			{
				messageDisplay.text = message;
			}
			
			if (instance == icon)
			{
				icon.source = _iconClass;
			}
			
			if (instance == buttonBarGroup)
			{
				createButtons();
			}
			
		}
		
		/**
		 * Required class to hook into the Spark skinning archetiture.
		 *  
		 * @param partName Part Name being processed.
		 * @param instance Current Skin Part being processed.
		 * 
		 */
		override protected function partRemoved(partName:String, instance:Object) : void
		{
			super.partRemoved(partName, instance);
			
			if (instance == buttonBarGroup)
			{
				destroyButtons();
			}
			
		}
		
		//-------------------------------------------------
		// Properties and getters and setters
		//-------------------------------------------------
		
		private var _iconClass:Class;
		private var _flags:uint;
		private var _defaultButtonIndex:uint;
		private var _buttons:Vector.<Button>;
		private var _title:String = "";
		private var _message:String = "";
		private var _buttonStyle:Class;
		
		/**
		 *  The title to display in this alert dialog box.
		 *
		 *  @default ""
		 *
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		public function get title():String 
		{
			return _title;
		}
		public function set title(value:String):void 
		{
			_title = value;
			
			if (titleDisplay)
				titleDisplay.text = value;
		}

		/**
		 *  The text to display in this alert dialog box.
		 *
		 *  @default ""
		 *
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		public function get message():String
		{
			return _message;
		}
		public function set message(value:String):void
		{
			_message = value;
			if (messageDisplay)
				messageDisplay.text = value;
		}
		
		/**
		 *  A bitmask that contains <code>MobileAlert.OK</code>, <code>MobileAlert.CANCEL</code>,
		 *  <code>MobileAlert.YES</code>, and/or <code>MobileAlert.NO</code> indicating
		 *  the buttons available in the MobileAlert control.
		 *
		 *  @default Alert.OK
		 *
		 *  @langversion 3.0
		 *  @playerversion Flash 10.1
		 *  @playerversion AIR 2.5
		 *  @productversion Flex 4.5
		 */
		public function get flags():uint
		{
			return _flags;
		}
		public function set flags(value:uint):void
		{
			_flags = value;
		}
		
		/**
		 *  A bitflag that contains either <code>MobileAlert.OK</code>,
		 *  <code>MobileAlert.CANCEL</code>, <code>MobileAlert.YES</code>,
		 *  or <code>MobileAlert.NO</code> to specify the default button.
		 *
		 *  @default Alert.OK
		 *
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		public function get defaultButtonIndex():uint
		{
			return _defaultButtonIndex;
		}
		public function set defaultButtonIndex(value:uint):void
		{
			_defaultButtonIndex = value;
		}
		
		/**
		 *  The class of the icon to display.
		 *  You typically embed an asset, such as a JPEG or GIF file,
		 *  and then use the variable associated with the embedded asset
		 *  to specify the value of this property.  If this is set to null,
		 *  it will use the default of an exclaimination box.
		 *
		 *  @default null
		 *
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		public function get iconClass():Class
		{
			return _iconClass;
		}
		public function set iconClass(value:Class):void
		{
			_iconClass = value;
			invalidateSkinState();
		}
		
		/**
		 *  The style class to set the buttons to.
		 *
		 *  @default null
		 *
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		public function get buttonStyle():Class
		{
			return _buttonStyle;
		}
		
		public function set buttonStyle(value:Class):void
		{
			_buttonStyle = value;
		}
		
		//-----------------------------------------------------
		// Private functions used by other functions within this component
		//-----------------------------------------------------
		
		/**
		 *  @private
		 */
		private function createButtons():void
		{
			if(!buttonBarGroup || !flags)   return;
			_buttons = new Vector.<Button>();
			var curButton:Button;
			if (Boolean(flags & YES))
			{
				curButton = new Button();
				curButton.label = ResourceManager.getInstance().getString('MobileAlert','YesLabel');
				_buttons.push(curButton);
			}
			if (Boolean(flags & NO))
			{
				curButton = new Button();
				curButton.label = ResourceManager.getInstance().getString('MobileAlert','NoLabel');
				_buttons.push(curButton);
			}
			if (Boolean(flags & OK))
			{
				curButton = new Button();
				curButton.label = ResourceManager.getInstance().getString('MobileAlert','OkLabel');
				_buttons.push(curButton);
			}
			if (Boolean(flags & CANCEL))
			{
				curButton = new Button();
				curButton.label = ResourceManager.getInstance().getString('MobileAlert','CancelLabel');
				_buttons.push(curButton);
			}
			
			addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			
			if (_buttons.length == 0) return;
			
			for (var i:int = 0; i < _buttons.length ; i++)
			{
				if (_buttonStyle != null)
				  _buttons[i].setStyle("skinClass",_buttonStyle);
				_buttons[i].buttonMode = true;
				_buttons[i].height = buttonBarGroup.height - 7;
				_buttons[i].percentWidth = 50;
				_buttons[i].addEventListener(MouseEvent.CLICK, onButtonTouch, false, 0, true);
				buttonBarGroup.addElement(_buttons[i]);
			}
		
			_buttons[_defaultButtonIndex].setFocus();
			
		}
		
		/**
		 *  @private
		 */
		private function destroyButtons():void
		{
			for (var i:int = 0; i < _buttons.length ; i++)
			{
				_buttons[i].removeEventListener(MouseEvent.CLICK, onButtonTouch);
				buttonBarGroup.removeElement(_buttons[i]);
			}
			
			_buttons = null;

			removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		}
		
		/**
		 *  @private
		 */
		private function onButtonTouch(event:MouseEvent):void
		{
			var e:CloseEvent = new CloseEvent( CloseEvent.CLOSE, false, false, Number.MAX_VALUE);
			switch(event.target.label)
			{
				case ResourceManager.getInstance().getString('MobileAlert','YesLabel'):
					e.detail = OK;
					break;
				case ResourceManager.getInstance().getString('MobileAlert','NoLabel'):
					e.detail = NO;
					break;
				case ResourceManager.getInstance().getString('MobileAlert','OkLabel'):
					e.detail = OK;
					break;
				case ResourceManager.getInstance().getString('MobileAlert','CancelLabel'):
					e.detail = CANCEL;
					break;
			}
			
			dispatchEvent(e);
						
			this.close();
		}
		
		/**
		 *  @private
		 */
		private function onKeyDown(event:KeyboardEvent):void
		{
			if (event.charCode == Keyboard.ESCAPE)
			{
				var e:CloseEvent = new CloseEvent( CloseEvent.CLOSE, false, false, Number.MAX_VALUE);
				dispatchEvent(e);
				this.close();
			}
		}

	}
}