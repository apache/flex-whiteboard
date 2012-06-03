package ws.tink.spark.controls
{
	import mx.utils.BitFlagUtil;
	
	import spark.components.supportClasses.SkinnableComponent;
	
	import ws.tink.spark.controls.supportClasses.IProgress;
	import ws.tink.spark.layouts.ProgressLayout;
	
	public class ProgressResize extends SkinnableComponent implements IProgress
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
		public function ProgressResize()
		{
			super();
		}
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Skin Parts
		//
		//--------------------------------------------------------------------------
		
		//----------------------------------
		//  progressLayout
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
		public var progressLayout:ProgressLayout;
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @private
		 *  Several properties are proxied to progressLayout. However, when progressLayout
		 *  is not around, we need to store values set on ProgressBar. This object 
		 *  stores those values. If progressLayout is around, the values are stored 
		 *  on the dataGroup directly. However, we need to know what values 
		 *  have been set by the developer on the ProgressBar (versus set on 
		 *  the progressLayout or defaults of the progressLayout) as those are values 
		 *  we want to carry around if the progressLayout changes (via a new skin). 
		 *  In order to store this info effeciently, progressLayoutProperties becomes 
		 *  a uint to store a series of BitFlags. These bits represent whether a 
		 *  property has been explicitly set on this ProgressBar. When the 
		 *  progressLayout is not around, progressLayoutProperties is a typeless 
		 *  object to store these proxied properties. When progressLayout is around,
		 *  progressLayoutProperties stores booleans as to whether these properties 
		 *  have been explicitly set or not.
		 */
		private var _progressLayoutProperties:Object = {};
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		
		//----------------------------------
		//  percent
		//----------------------------------
		
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
			return progressLayout ? progressLayout.percent : _progressLayoutProperties.percent;
		}
		/**
		 *  @private
		 */
		public function set percent( value:Number ):void
		{
			if( progressLayout )
			{
				progressLayout.percent = value;
				_progressLayoutProperties = BitFlagUtil.update( _progressLayoutProperties as uint, 
					PERCENT_PROPERTY_FLAG, true );
			}
			else
			{
				_progressLayoutProperties.percent = value;
			}
		}
		
		
		//----------------------------------
		//  horizontalDirection
		//----------------------------------
		
		[Inspectable(category="General", enumeration="leftToRight,rightToLeft,center,none", defaultValue="leftToRight")]
		
		/**
		 *  @copy ws.tink.spark.layouts.ProgressLayout#horizontalDirection
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get horizontalDirection():String
		{
			return progressLayout ? progressLayout.horizontalDirection : _progressLayoutProperties.horizontalDirection;
		}
		/**
		 *  @private
		 */
		public function set horizontalDirection( value:String ):void
		{
			if( progressLayout )
			{
				progressLayout.horizontalDirection = value;
				_progressLayoutProperties = BitFlagUtil.update( _progressLayoutProperties as uint, 
					HORIZONTAL_DIRECTION_PROPERTY_FLAG, true );
			}
			else
			{
				_progressLayoutProperties.horizontalDirection = value;
			}
		}
		
		
		//----------------------------------
		//  verticalDirection
		//----------------------------------
		
		[Inspectable(category="General", enumeration="topToBottom,bottomToTop,middle,none", defaultValue="none")]
		
		/**
		 *  @copy ws.tink.spark.layouts.ProgressLayout#verticalDirection
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get verticalDirection():String
		{
			return progressLayout ? progressLayout.verticalDirection : _progressLayoutProperties.verticalDirection;
		}
		/**
		 *  @private
		 */
		public function set verticalDirection( value:String ):void
		{
			if( progressLayout )
			{
				progressLayout.verticalDirection = value;
				_progressLayoutProperties = BitFlagUtil.update( _progressLayoutProperties as uint, 
					VERTICAL_DIRECTION_PROPERTY_FLAG, true );
			}
			else
			{
				_progressLayoutProperties.verticalDirection = value;
			}
		}
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Overridden Methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @private
		 */
		override protected function partAdded( partName:String, instance:Object ):void
		{
			super.partAdded( partName, instance );
			
			if( instance == progressLayout )
			{
				// Copy proxied values from _progressLayoutProperties (if set) to progressLayout.
				var newProgressLayoutProperties:uint = 0;
				
				if( !isNaN( _progressLayoutProperties.percent ) )
				{
					progressLayout.percent = _progressLayoutProperties.percent;
					newProgressLayoutProperties = BitFlagUtil.update( newProgressLayoutProperties as uint, 
						PERCENT_PROPERTY_FLAG, true);;
				}
				
				if( _progressLayoutProperties.horizontalDirection !== undefined )
				{
					progressLayout.horizontalDirection = _progressLayoutProperties.horizontalDirection;
					newProgressLayoutProperties = BitFlagUtil.update( newProgressLayoutProperties as uint, 
						HORIZONTAL_DIRECTION_PROPERTY_FLAG, true);
				}
				
				if( _progressLayoutProperties.verticalDirection !== undefined )
				{
					progressLayout.verticalDirection = _progressLayoutProperties.verticalDirection;
					newProgressLayoutProperties = BitFlagUtil.update( newProgressLayoutProperties as uint, 
						VERTICAL_DIRECTION_PROPERTY_FLAG, true);
				}
				
				_progressLayoutProperties = newProgressLayoutProperties;
			}
		}
		
		/**
		 *  @private
		 */
		override protected function partRemoved( partName:String, instance:Object ):void
		{
			super.partRemoved( partName, instance );
			
			if( instance == progressLayout )
			{
				// Copy proxied values from progressLayout (if explicitly set) to _progressLayoutProperties.
				var newProgressLayoutProperties:Object = {};
				
				if( BitFlagUtil.isSet( _progressLayoutProperties as uint, PERCENT_PROPERTY_FLAG ) )
					newProgressLayoutProperties.percent = progressLayout.percent;
				
				if( BitFlagUtil.isSet( _progressLayoutProperties as uint, HORIZONTAL_DIRECTION_PROPERTY_FLAG ) )
					newProgressLayoutProperties.horizontalDirection = progressLayout.horizontalDirection;
				
				if( BitFlagUtil.isSet( _progressLayoutProperties as uint, VERTICAL_DIRECTION_PROPERTY_FLAG ) )
					newProgressLayoutProperties.verticalDirection = progressLayout.verticalDirection;
				
				_progressLayoutProperties = newProgressLayoutProperties;
			}
		}
	}
}