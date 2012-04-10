package mx.collections.tests.arrayList {
	
	import mx.collections.ArrayList;
	
	import org.flexunit.assertThat;
	import org.flexunit.asserts.assertEquals;
	import org.hamcrest.object.equalTo;
	
	public class ConversionTest {
		[Test]
		public function toStringMethodShouldBeArrayToStringWhenProvidedArray():void {
			var array:Array = [ 5, 4, 3, 1, 2, 5 ];
			var arrayList:ArrayList = new ArrayList( array );
			assertEquals( array.toString(), arrayList.toString() );
		}
		
		[Test]
		public function toStringShouldBeEmptyStringWithNullSource():void {
			var arrayList:ArrayList = new ArrayList( null );
			assertEquals( "", arrayList.toString() );
		}
		
		[Test]
		public function toArrayShouldReturnArrayWithSameElementsAsArray():void {
			var array:Array = [ 5, 4, "3", 1, "Bob", 5 ];
			var arrayList:ArrayList = new ArrayList( array );
			assertThat( arrayList.toArray(), equalTo( array ) );
		}
		
		public function ConversionTest() {
		}
	}
	
}