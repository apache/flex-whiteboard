package ws.tink.spark.controls.supportClasses
{
	public interface IProgress
	{
		
		//----------------------------------
		//  percent
		//----------------------------------
		
		/**
		 *  Percent value from 0 to 100 indicating the amount of progress.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		function get percent():Number;
		/**
		 *  @private
		 */
		function set percent( value:Number ):void;
	}
}