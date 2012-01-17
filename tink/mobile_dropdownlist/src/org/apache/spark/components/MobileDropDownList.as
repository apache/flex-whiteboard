package org.apache.spark.components
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.core.InteractionMode;
	import mx.core.mx_internal;
	import mx.managers.DragManager;
	
	import spark.components.DropDownList;
	import spark.events.DropDownEvent;
	import spark.events.IndexChangeEvent;
	
	use namespace mx_internal;
	
	public class MobileDropDownList extends DropDownList
	{
		public function MobileDropDownList()
		{
			super();
		}
		
		/**
		 *  This override will go in DropDownListBase.
		 */
		override mx_internal function setSelectedIndex(value:int, dispatchChangeEvent:Boolean = false, changeCaret:Boolean = true):void
		{
			super.setSelectedIndex(value, dispatchChangeEvent, changeCaret );
			
			// If were in touch mode we need to propse the index and close the drop down.
			if( getStyle("interactionMode") == InteractionMode.TOUCH )
			{
				userProposedSelectedIndex = value;
				closeDropDown(true);
			}
		}
		
		/**
		 *  This is used as a hack and won't be required if the SDK is edited.
		 */
		private var _ignoreClose:Boolean;
		
		
		/**
		 *  The super of this method is is DropDownListBase and looks like so.
		 
		 override protected function item_mouseDownHandler(event:MouseEvent):void
		 {
		 	super.item_mouseDownHandler(event);
		 	userProposedSelectedIndex = selectedIndex;
		 	closeDropDown(true);
		 }
		 
		 *
		 *   I'm proposing the following. The 2 overrides below show how this would work.
		 * 
		 
		 override protected function item_mouseDownHandler(event:MouseEvent):void
		 {
		 	super.item_mouseDownHandler(event);
			if( getStyle("interactionMode") != InteractionMode.TOUCH )
			{
		 		userProposedSelectedIndex = selectedIndex;
		 		closeDropDown(true);
			}
		 }
		 
		 *
		 */
		override protected function item_mouseDownHandler(event:MouseEvent):void
		{
			_ignoreClose = getStyle("interactionMode") == InteractionMode.TOUCH;
			super.item_mouseDownHandler(event);
			_ignoreClose = false;
		}
			
		override public function closeDropDown(commit:Boolean):void
		{
			if( _ignoreClose ) return;
			super.closeDropDown(commit);
		}
	}
}