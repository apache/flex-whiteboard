package mx.collections.tests.arrayCollection {
	import mx.collections.ICollectionView;
	import mx.collections.IList;
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;
	
	import org.flexunit.assertThat;
	import org.flexunit.asserts.assertNull;
	import org.hamcrest.object.instanceOf;
	import org.hamcrest.object.sameInstance;

	public class BasicFunctionsTest {

		[Test]
		public function shouldImplementICollectionView():void {
			var collection:ArrayCollection = new ArrayCollection();
			assertThat( collection, instanceOf( ICollectionView ) );
		}

		[Test]
		public function instantiatingWithoutSourceShouldBuildOwnArrayList():void {
			var collection:ArrayCollection = new ArrayCollection();
			
			assertThat( collection.list, instanceOf( ArrayList ) );
		}

		[Test]
		public function instantiatingWithArrayShouldYieldListWithArray():void {
			var array:Array = [];
			var collection:ArrayCollection = new ArrayCollection( array );
			
			assertThat( array, sameInstance( ArrayList( collection.list ).source ) );
		}

		[Test]
		public function sourceShouldReturnArrayListSourceWhenListViable():void {
			var array:Array = [];
			var collection:ArrayCollection = new ArrayCollection( array );
			
			assertThat( array, sameInstance( collection.source ) );
		}

		[Test]
		public function sourceShouldReturnNullWhenListIsNull():void {
			var collection:ArrayCollection = new ArrayCollection();
			collection.list = null;
			
			assertNull( collection.source );
		}

		public function BasicFunctionsTest() {
		}
	}
}