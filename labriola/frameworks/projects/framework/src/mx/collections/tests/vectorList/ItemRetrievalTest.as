package mx.collections.tests.vectorList {
	import flash.events.EventDispatcher;
	
	import mx.collections.VectorList;
	
	import org.flexunit.asserts.assertEquals;

	public class ItemRetrievalTest {

		[Test]
		public function getItemAtShouldReturnValueFirstIndex():void {
			const position:int = 0;
			const value:int  = 11;
			var vector:Vector.<int> = new <int>[ value, 5, 7, 9, 13 ];
			var vectorList:VectorList = new VectorList( vector );
			
			assertEquals( value, vectorList.getItemAt( position ) );
		}

		[Test]
		public function getItemAtShouldReturnValueFromArbitraryIndex():void {
			const position:int = 3;
			const value:int  = 11;
			var vector:Vector.<int> = new <int>[ 5, 7, 9, value, 13 ];
			var vectorList:VectorList = new VectorList( vector );
			
			assertEquals( value, vectorList.getItemAt( position ) );
		}

		[Test]
		public function getItemAtShouldReturnValueLastIndex():void {
			const position:int = 3;
			const value:int  = 11;
			var vector:Vector.<int> = new <int>[ 5, 7, 9, value ];
			var vectorList:VectorList = new VectorList( vector );
			
			assertEquals( value, vectorList.getItemAt( position ) );
		}

		[Test(expects="RangeError")]
		public function shouldThrowRangeErrorForInvalidIndex():void {
			const position:int = 3;
			const value:int  = 11;
			var vector:Vector.<int> = new <int>[ value ];
			var vectorList:VectorList = new VectorList( vector );
			
			vectorList.getItemAt( position );
		}

		[Test]
		public function getItemIndexSimpleValueAtFirstPosition():void {
			const position:int = 0;
			const value:int  = 11;
			var vector:Vector.<int> = new <int>[ value, 5, 7, 9, 13 ];
			var vectorList:VectorList = new VectorList( vector );
			
			assertEquals( position, vectorList.getItemIndex( value ) );
		}

		[Test]
		public function getItemIndexSimpleValueAtArbitraryPosition():void {
			const position:int = 3;
			const value:int  = 11;
			var vector:Vector.<int> = new <int>[ 5, 7, 9, value, 13 ];
			var vectorList:VectorList = new VectorList( vector );
			
			assertEquals( position, vectorList.getItemIndex( value ) );
		}

		[Test]
		public function getItemIndexSimpleValueAtLastPosition():void {
			const position:int = 3;
			const value:int  = 11;
			var vector:Vector.<int> = new <int>[ 5, 7, 9, value ];
			var vectorList:VectorList = new VectorList( vector );
			
			assertEquals( position, vectorList.getItemIndex( value ) );
		}

		[Test]
		public function getItemIndexNotFound():void {
			const position:int = -1;
			const value:int  = 11;
			var vector:Vector.<int> = new <int>[ 5, 7, 9 ];
			var vectorList:VectorList = new VectorList( vector );
			
			assertEquals( position, vectorList.getItemIndex( value ) );
		}

		[Test]
		public function getItemIndexComplexValue():void {
			const position:int = 1;
			const value:EventDispatcher = new EventDispatcher();
			var vector:Vector.<EventDispatcher> = new <EventDispatcher>[ new EventDispatcher(), value, new EventDispatcher() ];
			var vectorList:VectorList = new VectorList( vector );
			
			assertEquals( position, vectorList.getItemIndex( value ) );
		}
		
		public function ItemRetrievalTest() {
		}
	}
}