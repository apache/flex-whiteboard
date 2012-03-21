package org.apache.spark.components
{
	import flash.display.DisplayObjectContainer;
	
	import mx.collections.ArrayList;
	
	import org.apache.spark.components.supportClasses.SkinnablePopUpComponent;
	
	import spark.components.ButtonBar;
	import spark.core.IDisplayText;
	import spark.events.IndexChangeEvent;
	import spark.primitives.BitmapImage;

	public class Alert extends SkinnablePopUpComponent
	{
		
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  Constructor.
		 *
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 2.5
		 *  @productversion Flex 4.5
		 */
		public function Alert()
		{
			super();
		}
		
		
		//--------------------------------------------------------------------------
		//
		//  Skin Parts
		//
		//--------------------------------------------------------------------------
		
		[SkinPart(required="false")]
		public var titleDisplay:IDisplayText;
		
		[SkinPart(required="false")]
		public var messageDisplay:IDisplayText;
		
		[SkinPart(required="false")]
		public var iconDisplay:BitmapImage;
		
		[SkinPart(required="true")]
		public var buttonBar:ButtonBar;
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		
		//----------------------------------
		//  title
		//----------------------------------
		
		/**
		 *  @private
		 */
		private var _title:String;
		
		/**
		 *  Text string that appears in the title bar.
		 *  This text is in the title area of the alert dialog box.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 2.5
		 *  @productversion Flex 4.5
		 */
		public function get title():String
		{
			return _title;
		}
		/**
		 *  @private
		 */
		public function set title(value:String):void
		{
			if( _title == value ) return;
			
			_title = value;
			if( titleDisplay ) titleDisplay.text = title;
		}
		
		
		//----------------------------------
		//  message
		//----------------------------------
		
		/**
		 *  @private
		 */
		private var _message:String;
		
		/**
		 *  Text string that appears in the MobileAlert control.
		 *  This text is the main text within the alert dialog box.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 2.5
		 *  @productversion Flex 4.5
		 */
		public function get message():String
		{
			return _message;
		}
		/**
		 *  @private
		 */
		public function set message( value:String ):void
		{
			if( _message == value ) return;
			
			_message = value;
			if( messageDisplay ) messageDisplay.text = message;
		}
		
		
		//----------------------------------
		//  icon
		//----------------------------------
		
		/**
		 *  @private
		 */
		private var _icon:Object;
		
		/**
		 *  @copy spark.primitives.BitmapImage#source
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 2.5
		 *  @productversion Flex 4.5
		 */
		public function get icon():Object
		{
			return _icon;
		}
		/**
		 *  @private
		 */
		public function set icon( value:Object ):void
		{
			if( _icon == value ) return;
			
			_icon = value;
			if( iconDisplay ) iconDisplay.source = icon;
		}
		
		
		//----------------------------------
		//  buttonLabels
		//----------------------------------
		
		/**
		 *  @private
		 */
		private var _buttonLabels:Array;
		
		/**
		 *  Text string that appears in the MobileAlert control.
		 *  This text is the main text within the alert dialog box.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 2.5
		 *  @productversion Flex 4.5
		 */
		public function get buttonLabels():Array
		{
			return _buttonLabels;
		}
		/**
		 *  @private
		 */
		public function set buttonLabels( value:Array ):void
		{
			if( _buttonLabels == value ) return;
			
			_buttonLabels = value;
			if( buttonBar ) buttonBar.dataProvider = new ArrayList( buttonLabels );
		}
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @inheritDoc
		 */
		override public function open( owner:DisplayObjectContainer, modal:Boolean = true ):void
		{
			super.open( owner, modal );
		}
		
		/**
		 *  @private
		 */
		override protected function partAdded( partName:String, instance:Object ):void
		{
			super.partAdded( partName, instance );
			
			switch( instance )
			{
				case titleDisplay :
				{
					titleDisplay.text = title;
					break;
				}
				case messageDisplay :
				{
					messageDisplay.text = message;
					break;
				}
				case iconDisplay :
				{
					iconDisplay.source = icon;
					break;
				}
				case buttonBar :
				{
					buttonBar.addEventListener( IndexChangeEvent.CHANGE, buttonBar_changeHandler, false, 0, true );
					buttonBar.dataProvider = new ArrayList( _buttonLabels );
					break;
				}
			}
		}
		
		/**
		 *  @private
		 */
		override protected function partRemoved( partName:String, instance:Object ):void
		{
			super.partRemoved( partName, instance );
			
			switch( instance )
			{
				case buttonBar :
				{
					buttonBar.removeEventListener( IndexChangeEvent.CHANGE, buttonBar_changeHandler, false );
					break;
				}
			}
		}
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Event Handlers
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @private
		 */
		private function buttonBar_changeHandler( event:IndexChangeEvent ):void
		{
			close( true, buttonBar.selectedItem );
		}
		
	}
}