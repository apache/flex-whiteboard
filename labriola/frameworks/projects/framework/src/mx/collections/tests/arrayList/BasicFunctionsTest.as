package mx.collections.tests.arrayList {
	import mx.collections.ArrayList;
	import mx.collections.IList;
	import mx.core.IPropertyChangeNotifier;
	
	import org.flexunit.assertThat;
	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertFalse;
	import org.flexunit.asserts.assertNotNull;
	import org.flexunit.asserts.assertStrictlyEquals;
	import org.flexunit.asserts.assertTrue;
	import org.hamcrest.collection.hasItem;
	import org.hamcrest.core.not;
	import org.hamcrest.object.instanceOf;

	public class BasicFunctionsTest {

		private static const EMPTY:int = 0;
	
		[Test]
		public function shouldImplementIList():void {
			var arrayList:ArrayList = new ArrayList( null );
			assertThat( arrayList, instanceOf( IList ) );
		}

		[Test]
		public function shouldImplementIPropertyChangeNotifier():void {
			var arrayList:ArrayList = new ArrayList( null );
			assertThat( arrayList, instanceOf( IPropertyChangeNotifier ) );
		}

		[Test]
		public function lengthShouldBeEmptyWithNullSource():void {
			var arrayList:ArrayList = new ArrayList( null );
			assertEquals( EMPTY, arrayList.length );
		}

		[Test]
		public function lengthShouldBeEmptyWhenEmptyVectorProvided():void {
			var arrayList:ArrayList = new ArrayList( [] );
			assertEquals( EMPTY, arrayList.length );
		}

		[Test]
		public function lengthShouldBe1WhenVectorLength1Provided():void {
			var arrayList:ArrayList = new ArrayList( [1] );
			assertEquals( 1, arrayList.length );
		}

		[Test]
		public function sourcePropertyShouldBeStrictlyEqualToProvidedVector():void {
			var array:Array = [];
			var arrayList:ArrayList = new ArrayList( array );
			assertStrictlyEquals( array, arrayList.source );
		}

		[Test]
		public function shouldSetUIDAtConstruction():void {
			var arrayList:ArrayList = new ArrayList( [] );

			assertNotNull( arrayList.uid );
			assertTrue( arrayList.uid.length > 0 );
		}

		[Test]
		public function multipleArrayListsShouldNotShareAUID():void {
			var arrayList1:ArrayList = new ArrayList();
			var arrayList2:ArrayList = new ArrayList();
			var arrayList3:ArrayList = new ArrayList();
			
			assertTrue( arrayList1.uid != arrayList2.uid );
			assertTrue( arrayList2.uid != arrayList3.uid );
			assertTrue( arrayList1.uid != arrayList3.uid );
		}

		[Test]
		public function shouldBeAbleToSetUID():void {
			const newUID:String = "3.14159265358";
			var arrayList:ArrayList = new ArrayList();
			
			assertFalse( arrayList.uid == newUID );
			
			arrayList.uid = newUID;
			assertTrue( arrayList.uid == newUID );
		}

		[Test]
		public function setItemAtShouldUpdateValueAtPosition():void {
			const value:int = 5;
			const position:int = 2;
			var array:Array = [ 3, 7, 9, 11, 13 ];
			var arrayList:ArrayList = new ArrayList( array );
			
			assertThat( array, not( hasItem( value ) ) );
			arrayList.setItemAt( value, position );
			assertThat( array, hasItem( value ) );
			assertEquals( value, array[ position ] );
		}

		[Test]
		public function setItemAtShouldReturnOldValueWhenSettingNewValue():void {
			const newValue:int = 5;
			const oldValue:int = 9;
			const position:int = 2;
			var array:Array = [ 3, 7, oldValue, 11, 13 ];
			var arrayList:ArrayList = new ArrayList( array );
			
			assertEquals( oldValue, arrayList.setItemAt( newValue, position ) );
		}

		[Test(expects="RangeError")]
		public function setItemAtShouldThrowRangeErrorForOutOfBoundsIndex():void {
			const value:int = 100;
			const position:int = 2;
			var array:Array = [ 3 ];
			var arrayList:ArrayList = new ArrayList( array );
			
			arrayList.setItemAt( value, position );
		}
	}
}