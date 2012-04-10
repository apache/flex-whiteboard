package mx.collections.tests
{
	import mx.collections.tests.vectorCollection.BasicFunctionsTest;
	import mx.collections.tests.vectorList.VectorListSuite;
	import mx.collections.tests.arrayCollection.BasicFunctionsTest;
	import mx.collections.tests.arrayList.ArrayListSuite;
	
	[Suite]
	[RunWith("org.flexunit.runners.Suite")]
	public class CollectionTests
	{
		public var test1:mx.collections.tests.vectorCollection.BasicFunctionsTest;
		public var test2:mx.collections.tests.vectorList.VectorListSuite;
		public var test3:mx.collections.tests.arrayCollection.BasicFunctionsTest;
		public var test4:mx.collections.tests.arrayList.ArrayListSuite;
		
	}
}