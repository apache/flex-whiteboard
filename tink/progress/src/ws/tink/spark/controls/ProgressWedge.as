package ws.tink.spark.controls
{
	import mx.utils.BitFlagUtil;
	
	import spark.components.supportClasses.SkinnableComponent;
	
	import ws.tink.spark.controls.supportClasses.IProgress;
	import ws.tink.spark.layouts.ProgressLayout;
	import ws.tink.spark.layouts.supportClasses.RadialDirection;
	import ws.tink.spark.primitives.Wedge;
	
	public class ProgressWedge extends SkinnableComponent implements IProgress
	{
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Class constants
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @private
		 */
		private static const PERCENT_PROPERTY_FLAG:uint = 1 << 0;
		
		/**
		 *  @private
		 */
		private static const HORIZONTAL_DIRECTION_PROPERTY_FLAG:uint = 1 << 1;
		
		/**
		 *  @private
		 */
		private static const VERTICAL_DIRECTION_PROPERTY_FLAG:uint = 1 << 2;
		
		
		
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
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function ProgressWedge()
		{
			super();
		}
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Skin Parts
		//
		//--------------------------------------------------------------------------
		
		//----------------------------------
		//  wedge
		//----------------------------------
		
		[SkinPart(required="true")]
		
		/**
		 *  progressLayout.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public var wedge:Wedge;
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		
		//----------------------------------
		//  percent
		//----------------------------------
		
		/**
		 *  @private
		 *  Storage property for percent.
		 */
		private var _percent:Number;
		
		/**
		 *  @inheritDoc
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
		public function set percent( value:Number ):void
		{
			if( _percent == value ) return;
			
			_percent = value;
			invalidateProperties();
		}
		
		
		//----------------------------------
		//  direction
		//----------------------------------
		
		/**
		 *  @private
		 *  Storage property for direction.
		 */
		private var _direction:String = RadialDirection.CLOCKWISE;
		
		[Inspectable(category="General", enumeration="clockwise,antiClockwise,", defaultValue="clockwise")]
		
		/**
		 *  @copy ws.tink.spark.layouts.ProgressLayout#horizontalDirection
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get direction():String
		{
			return _direction;
		}
		/**
		 *  @private
		 */
		public function set direction( value:String ):void
		{
			if( _direction == value ) return;
			
			_direction = value;
			invalidateProperties();
		}
		
		
		//----------------------------------
		//  startAngle
		//----------------------------------
		
		/**
		 *  @private
		 *  Storage property for startAngle.
		 */
		private var _startAngle:Number = 0;
		
		/**
		 *  startAngle
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get startAngle():Number
		{
			return _startAngle;
		}
		/**
		 *  @private
		 */
		public function set startAngle(value:Number):void
		{
			if( _startAngle == value ) return;
			
			_startAngle = value;
			invalidateProperties();
		}
		
		
		//----------------------------------
		//  arc
		//----------------------------------
		
		/**
		 *  @private
		 *  Storage property for arc.
		 */
		private var _arc:Number = 360;
		
		/**
		 *  arc
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get arc():Number
		{
			return _arc;
		}
		/**
		 *  @private
		 */
		public function set arc(value:Number):void
		{
			if( _arc == value ) return;
			
			_arc = value;
			invalidateProperties();
		}		
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Overridden Methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @private
		 */
		override protected function commitProperties():void
		{
			super.commitProperties();
			
			if( wedge )
			{
				wedge.startAngle = startAngle;
				wedge.arc = ( arc / 100 ) * percent;
			}
		}
		
	}
}