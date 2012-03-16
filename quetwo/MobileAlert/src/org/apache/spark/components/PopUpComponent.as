package org.apache.spark.components
{
	import flash.events.MouseEvent;
	
	import mx.core.IButton;
	import org.apache.spark.components.supportClasses.SkinnablePopUpComponent;

	public class PopUpComponent extends SkinnablePopUpComponent
	{
		public function PopUpComponent()
		{
			super();
		}
		
		[SkinPart(required="true")]
		public var closeButton:IButton;
		
		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance);
			
			if( instance == closeButton ) closeButton.addEventListener( MouseEvent.CLICK, closeButtonClickHandler, false, 0, true );
		}
		
		override protected function partRemoved(partName:String, instance:Object):void
		{
			super.partRemoved(partName, instance);
			
			if( instance == closeButton ) closeButton.removeEventListener( MouseEvent.CLICK, closeButtonClickHandler, false );
		}
		
		private function closeButtonClickHandler( event:MouseEvent ):void
		{
			trace( "got it@" );
			close();
		}
	}
}