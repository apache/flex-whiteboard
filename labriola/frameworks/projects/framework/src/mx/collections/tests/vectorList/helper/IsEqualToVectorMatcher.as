package mx.collections.tests.vectorList.helper {
	import org.hamcrest.BaseMatcher;
	
	public class IsEqualToVectorMatcher extends BaseMatcher {
		private var _value:Object;

		/**
		 * Constructor
		 *
		 * @param value Object the item being matched must be equal to
		 */
		public function IsEqualToVectorMatcher( value:Object ) {
			super();

			_value = value;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function matches(item:Object):Boolean {
			return areLengthsEqual(_value, item) && areElementsEqual(_value, item);
		}
		
		/**
		 * Checks if the given objects are of equal length
		 *
		 * @private
		 */
		private function areLengthsEqual(o1:Object, o2:Object):Boolean
		{
			return ( o1.length == o2.length );
		}
		
		/**
		 * Checks the elements of both objects are the equal
		 *
		 * @private
		 */
		private function areElementsEqual(o1:*, o2:Object):Boolean
		{
			for (var i:int = 0, n:int = o1.length; i < n; i++)
			{
				if (!o1[i] == o2[i] )
				{
					return false;
				}
			}
			return true;
		}
	}
}