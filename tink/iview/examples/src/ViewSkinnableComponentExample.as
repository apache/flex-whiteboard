package
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import spark.components.Button;
	import org.apache.spark.components.ViewSkinnableComponent;

	public class ViewSkinnableComponentExample extends ViewSkinnableComponent
	{
		public function ViewSkinnableComponentExample()
		{
			super();
			percentWidth = percentHeight = 100;
			
			var b:Button = new Button();
			b.addEventListener(MouseEvent.CLICK, back_clickHandler, false, 0, true);
			b.label = "Back";
			navigationContent = [ b ];
			
			title = "ViewSkinnableComponentExample"
		}
		
		[SkinPart(required="true")]
		public var button:Button;
		
		
		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance );
			
			if( instance == button )
			{
				button.addEventListener(MouseEvent.CLICK, onButtonClick, false, 0, true );
			}
		}
		
		private function back_clickHandler( event:Event ):void
		{
			navigator.popView();
		}
		
		private function onButtonClick( event:Event ):void
		{
			navigator.pushView( ViewGroupExample );
		}
	}
}