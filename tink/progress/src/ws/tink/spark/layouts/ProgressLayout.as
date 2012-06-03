package ws.tink.spark.layouts
{
	import mx.core.IVisualElement;
	
	import spark.layouts.BasicLayout;
	import ws.tink.spark.layouts.supportClasses.HorizontalDirection;
	import ws.tink.spark.layouts.supportClasses.VerticalDirection;
	
	public class ProgressLayout extends BasicLayout
	{
		public function ProgressLayout()
		{
			super();
		}
		
		//----------------------------------
		//  progressItems
		//----------------------------------
		
		/**
		 *  @private
		 *  Storage property for progressItems.
		 */
		private var _progressItems:Array;
		
		/**
		 *  progressItems
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get progressItems():Array
		{
			return _progressItems;
		}
		/**
		 *  @private
		 */
		public function set progressItems(value:Array):void
		{
			if( _progressItems == value ) return;
			
			_progressItems = value;
			invalidateDisplayList();
		}
		
		
		//----------------------------------
		//  horizontalDirection
		//----------------------------------
		
		/**
		 *  @private
		 *  Storage property for horizontalDirection.
		 */
		private var _horizontalDirection:String = HorizontalDirection.LEFT_TO_RIGHT;
		
		[Inspectable(category="General", enumeration="leftToRight,rightToLeft,center,none", defaultValue="leftToRight")]
		/**
		 *  horizontalDirection
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get horizontalDirection():String
		{
			return _horizontalDirection;
		}
		/**
		 *  @private
		 */
		public function set horizontalDirection(value:String):void
		{
			if( _horizontalDirection == value ) return;
			
			_horizontalDirection = value;
			invalidateDisplayList();
		}
		
		
		//----------------------------------
		//  verticalDirection
		//----------------------------------
		
		/**
		 *  @private
		 *  Storage property for verticalDirection.
		 */
		private var _verticalDirection:String = VerticalDirection.NONE;
		
		[Inspectable(category="General", enumeration="topToBottom,bottomToTop,middle,none", defaultValue="none")]
		/**
		 *  verticalDirection
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get verticalDirection():String
		{
			return _verticalDirection;
		}
		/**
		 *  @private
		 */
		public function set verticalDirection(value:String):void
		{
			if( _verticalDirection == value ) return;
			
			_verticalDirection = value;
			invalidateDisplayList();
		}
		
		
		//----------------------------------
		//  percent
		//----------------------------------
		
		/**
		 *  @private
		 *  Storage property for percent.
		 */
		private var _percent:Number = 0;
		
		/**
		 *  percent
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get percent():Number
		{
			return _percent;
		}
		/**
		 *  @private
		 */
		public function set percent(value:Number):void
		{
			if( _percent == value ) return;
			
			_percent = value;
			invalidateDisplayList();
		}
		
		
		/**
		 *  @private
		 */
		private function invalidateDisplayList():void
		{
			if( !target ) return;
			target.invalidateDisplayList();
		}
		
		/**
		 *  @private
		 */
		override public function updateDisplayList( unscaledWidth:Number, unscaledHeight:Number ):void
		{
			super.updateDisplayList( unscaledWidth, unscaledHeight );
			
			if( progressItems && progressItems.length )
			{
				var element:IVisualElement;
				var originalSize:Number;
				var originalPos:Number;
				var minSize:Number;
				var availableChange:Number;
				var newWidth:Number;
				var newHeight:Number;
				var newX:Number;
				var newY:Number;
				
				for each (var item:Object in progressItems) 
				{
					if( item is IVisualElement )
					{
						element = IVisualElement( item );
						
						originalSize = element.getLayoutBoundsWidth();
						originalPos = element.getLayoutBoundsX();
						
						if( horizontalDirection == HorizontalDirection.NONE )
						{
							newWidth = originalSize;
							newX = originalPos;
						}
						else
						{
							minSize = element.getMinBoundsWidth();
							availableChange = originalSize - minSize;
							newWidth = Math.round( minSize + ( availableChange * ( percent / 100 ) ) );
							
							switch( horizontalDirection )
							{
								case HorizontalDirection.RIGHT_TO_LEFT :
								{
									newX = ( originalPos + originalSize ) - newWidth;
									break;
								}
								case HorizontalDirection.CENTER :
								{
									newX = ( originalPos + ( originalSize / 2 ) ) - ( newWidth / 2 );
									break;
								}
								default :
								{
									newX = originalPos;
									break;
								}
							}
						}
						
						originalSize = element.getLayoutBoundsHeight();
						originalPos = element.getLayoutBoundsY();
						
						if( verticalDirection == VerticalDirection.NONE )
						{
							newHeight = originalSize;
							newY = originalPos;
						}
						else
						{
							minSize = element.getMinBoundsHeight();
							availableChange = originalSize - minSize;
							newHeight = Math.round( minSize + ( availableChange * ( percent / 100 ) ) );
							
							switch( verticalDirection )
							{
								case VerticalDirection.BOTTOM_TO_TOP :
								{
									newY = ( originalPos + originalSize ) - newHeight;
									break;
								}
								case VerticalDirection.MIDDLE :
								{
									newY = ( originalPos + ( originalSize / 2 ) ) - ( newHeight / 2 );
									break;
								}
								default :
								{
									newY = originalPos;
									break;
								}
							}
						}
						
						element.setLayoutBoundsSize( newWidth, newHeight );
						element.setLayoutBoundsPosition( newX, newY );
					}
				}
			}
		}
	}
}