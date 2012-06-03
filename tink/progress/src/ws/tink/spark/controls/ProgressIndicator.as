package ws.tink.spark.controls
{
	import spark.components.Label;
	import spark.components.supportClasses.SkinnableComponent;
	
	import ws.tink.spark.controls.supportClasses.IProgress;
	
	public class ProgressIndicator extends SkinnableComponent
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
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function ProgressIndicator()
		{
			super();
			
			labelFunction = defaultLabelFunction;
		}
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Skin Parts
		//
		//--------------------------------------------------------------------------
		
		//----------------------------------
		//  progressDisplay
		//----------------------------------
		
		[SkinPart(required="false")]
		
		/**
		 *  progressLayout.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public var progressDisplay:IProgress;
		
		
		//----------------------------------
		//  labelDisplay
		//----------------------------------
		
		[SkinPart(required="false")]
		
		/**
		 *  labelDisplay.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public var labelDisplay:Label;
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		
		//----------------------------------
		//  total
		//----------------------------------
		
		/**
		 *  @private
		 *  Storage property for total.
		 */
		private var _total:Number ;
		
		/**
		 *  total
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get total():Number 
		{
			return _total;
		}
		/**
		 *  @private
		 */
		public function set total( value:Number ):void
		{
			if( _total ==  value ) return;
			
			_total = value;
			invalidateProperties();
		}
		
		
		//----------------------------------
		//  value
		//----------------------------------
		
		/**
		 *  @private
		 *  Storage property for value.
		 */
		private var _value:Number;
		
		/**
		 *  value
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get value():Number
		{
			return _value;
		}
		/**
		 *  @private
		 */
		public function set value( v:Number):void
		{
			if( _value == v ) return;
			
			_value = v;
			invalidateProperties();
		}
		
		
		//----------------------------------
		//  labelFunction
		//----------------------------------
		
		/**
		 *  @private
		 *  Storage property for labelFunction.
		 */
		private var _labelFunction:Function;
		
		/**
		 *  labelFunction
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get labelFunction():Function
		{
			return _labelFunction;
		}
		/**
		 *  @private
		 */
		public function set labelFunction( value:Function ):void
		{
			if( _labelFunction == value ) return;
			
			_labelFunction = value !== null ? value : defaultLabelFunction;
			invalidateProperties();
		}
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @private
		 */
		protected function defaultLabelFunction( value:Number, total:Number ):String
		{
			return Math.round( ( value / total ) * 100 ).toString() + "%";
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
			
			if( labelDisplay ) labelDisplay.text = labelFunction( value, total );
			if( progressDisplay ) progressDisplay.percent = Math.round( ( value / total ) * 100 );
		}
		
//		/**
//		 *  @private
//		 */
//		override protected function partAdded( partName:String, instance:Object ):void
//		{
//			super.partAdded( partName, instance );
//		}
//		
//		/**
//		 *  @private
//		 */
//		override protected function partRemoved( partName:String, instance:Object ):void
//		{
//			super.partRemoved( partName, instance );
//		}
	}
}