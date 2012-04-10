package mx.collections.tests.vectorList {
	import mx.collections.tests.vectorList.helper.IsEqualToVectorMatcher;
	
	import mx.collections.VectorList;
	
	import org.flexunit.assertThat;
	import org.flexunit.asserts.assertEquals;

	public class ConversionTest {

		[Test]
		public function toStringMethodShouldBeVectorToStringWhenProvidedVector():void {
			var vector:Vector.<int> = new <int>[ 5, 4, 3, 1, 2, 5 ];
			var vectorList:VectorList = new VectorList( vector );
			assertEquals( vector.toString(), vectorList.toString() );
		}
		
		[Test]
		public function toStringShouldBeEmptyStringWithNullSource():void {
			var vectorList:VectorList = new VectorList( null );
			assertEquals( "", vectorList.toString() );
		}
		
		[Test]
		public function toArrayShouldReturnArrayWithSameElementsAsVector():void {
			var vector:Vector.<*> = new <*>[ 5, 4, "3", 1, "Bob", 5 ];
			var vectorList:VectorList = new VectorList( vector );
			assertThat( vectorList.toArray(), new IsEqualToVectorMatcher( vector ) );
		}

		public function ConversionTest() {
		}
	}
}