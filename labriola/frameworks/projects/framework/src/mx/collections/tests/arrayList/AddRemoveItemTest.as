package mx.collections.tests.arrayList {
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	
	import mx.collections.ArrayList;
	
	import org.flexunit.assertThat;
	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertFalse;
	import org.flexunit.asserts.assertStrictlyEquals;
	import org.flexunit.asserts.assertTrue;
	import org.hamcrest.collection.hasItem;
	import org.hamcrest.core.not;
	import org.hamcrest.object.sameInstance;

	public class AddRemoveItemTest {
		
		private static const EMPTY:int = 0;

		[Test]
		public function addItemShouldAddFirstItemToEmptyArray():void {
			var array:Array = [];
			var arrayList:ArrayList = new ArrayList( array );
			const value:int = 5;
			
			assertThat( array, not( hasItem( value ) ) );
			
			arrayList.addItem( value );
			assertEquals( 1, arrayList.length );
			assertThat( array, hasItem( value ) );
		}
		
		[Test]
		public function addItemShouldAddLastItemToPopulatedArray():void {
			var array:Array = [ 7, 8, 9 ];
			var arrayList:ArrayList = new ArrayList( array );
			const value:int = 5;
			
			assertEquals( 3, arrayList.length );
			
			arrayList.addItem( value );
			assertEquals( 4, arrayList.length );
			assertEquals( value, array[ 3 ] );
		}
		
		[Test]
		public function removeItemShouldRemoveSimpleItemFromArray():void {
			var array:Array = [];
			var arrayList:ArrayList = new ArrayList( array );
			const value:int = 5;

			arrayList.addItem( value );
			assertThat( array, hasItem( value ) );

			arrayList.removeItem( value );
			assertThat( array, not( hasItem( value ) ) );
		}

		[Test]
		public function removeItemShouldRemoveSingleSimpleItemFromArray():void {
			var array:Array = [];
			var arrayList:ArrayList = new ArrayList( array );
			const value:int = 5;
			
			arrayList.addItem( value );
			arrayList.addItem( value );
			assertThat( array, hasItem( value ) );
			
			arrayList.removeItem( value );
			assertThat( array, hasItem( value ) );
			assertEquals( 1, array.length );
		}

		[Test]
		public function removeItemShouldRemoveComplexItemFromArray():void {
			var array:Array = [];
			var arrayList:ArrayList = new ArrayList( array );
			const value:EventDispatcher = new EventDispatcher();
			
			arrayList.addItem( value );
			assertThat( array, hasItem( value ) );
			
			arrayList.removeItem( value );
			assertThat( array, not( hasItem( value ) ) );
		}

		[Test]
		public function removeItemShouldRemoveReturnTrueIfItemFound():void {
			var array:Array = [];
			var arrayList:ArrayList = new ArrayList( array );
			const value:EventDispatcher = new EventDispatcher();
			
			arrayList.addItem( value );
			assertTrue( arrayList.removeItem( value ) );
		}

		[Test]
		public function removeItemShouldRemoveReturnFalseIfItemNotFound():void {
			var array:Array = [];
			var arrayList:ArrayList = new ArrayList( array );
			const value:EventDispatcher = new EventDispatcher();
			
			assertFalse( arrayList.removeItem( value ) );
		}

		[Test]
		public function removeAllShouldEmptyArray():void {
			var array:Array = [ 5, 7, 9, 11, 13 ];
			var arrayList:ArrayList = new ArrayList( array );
			
			assertEquals( 5, array.length );
			
			arrayList.removeAll();

			assertEquals( EMPTY, array.length );
		}

		public function AddRemoveItemTest() {
		}
	}
}