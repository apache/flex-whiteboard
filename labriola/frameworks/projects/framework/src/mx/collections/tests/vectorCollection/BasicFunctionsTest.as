package mx.collections.tests.vectorCollection {
	import mx.collections.ICollectionView;
	import mx.collections.IList;
	import mx.collections.VectorCollection;
	import mx.collections.VectorList;
	
	import org.flexunit.assertThat;
	import org.flexunit.asserts.assertNull;
	import org.hamcrest.object.instanceOf;
	import org.hamcrest.object.sameInstance;

	public class BasicFunctionsTest {

		[Test]
		public function shouldImplementICollectionView():void {
			var collection:VectorCollection = new VectorCollection();
			assertThat( collection, instanceOf( ICollectionView ) );
		}

		[Test]
		public function instantiatingWithoutSourceShouldBuildOwnVectorList():void {
			var collection:VectorCollection = new VectorCollection();
			
			assertThat( collection.list, instanceOf( VectorList ) );
		}

		[Test]
		public function instantiatingWithVectorShouldYieldListWithVector():void {
			var vector:Vector.<*> = new Vector.<*>;
			var collection:VectorCollection = new VectorCollection( vector );
			
			assertThat( vector, sameInstance( VectorList( collection.list ).source ) );
		}

		[Test(expects="TypeError")]
		public function instantiatingWithTypeOtherThanVectorShouldThrowTypeError():void {
			var collection:VectorCollection = new VectorCollection( [] );
		}

		[Test]
		public function sourceShouldReturnVectorListSourceWhenListViable():void {
			var vector:Vector.<*> = new Vector.<*>;
			var collection:VectorCollection = new VectorCollection( vector );
			
			assertThat( vector, sameInstance( collection.source ) );
		}

		[Test]
		public function sourceShouldReturnNullWhenListIsNull():void {
			var collection:VectorCollection = new VectorCollection();
			collection.list = null;
			
			assertNull( collection.source );
		}

		public function BasicFunctionsTest() {
		}
	}
}