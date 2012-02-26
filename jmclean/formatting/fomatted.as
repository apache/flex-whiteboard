package my.company
{
	import com.none.*;
	
	[Bindable]
	public var prop:Boolean = true;
	
	[Embed(asset = "..\\x\\y\\z.jpg")]
	/** This is an AS doc comment that describes this class.  This class isn't very
	 interesting.
	 
	 * @author Me
	 @exception This class throws no exceptions, but that may change if there are some unexpected things that can happen.
	 */
	class TestClass extends AnotherClassInAnotherPackage implements com.none.special.InterfaceClass
	{
		namespace my_namespace;
		
		/* function that returns an int */
		my_namespace private function performSelect(z:com.temp.MyType, r:boolean, arg3:boolean, arg4:boolean, arg5:boolean):int
		{
			
			var j:int = ((342 / (65 - 40)));
			
			var simpleArray:Array = [ 23, 2, 23232, 3, 23.23, 78, 23, 32, 98, 56, 45, 32, 34, 56, 78, 56, 34, 23, 56, 7888, 9899, 6765, 65, 3, 0.5532343, 23, 11, 21, 90, 67, 33 ];
			var objectDef:Object = { name: "Item1", value: 52000000, color: "red", width: 100, height: 800, source: variableRef, alignment: this.Left };
			var blah:ArrayCollection = new ArrayCollection([{ topping: "Pepperoni", calories: 400 }, { topping: "Sausage", calories: 550 }, { topping: "Ham", calories: 240 }, { topping: "Chicken", calories: 110 }, { topping: "Ground Beef", calories: 375 }, { topping: "Bacon", calories: 330 }, { topping: "Canadian Bacon", calories: 100 }]);
			
			var myArray = [[ "1", "2", "3" ], [ "4", "5", "6" ]];
			trace(myArray[0][1]);
			
			performSelect(new MyType(), getBooleanValueFromSomewhereElse(true, true), true, getBooleanValueFromSomewhereElse(true, false), false, true);
			//TODO: Single line comment in column 1
			var b:boolean = getValue(1, 2) && (setValue(3, 4, 5, false) ? setValue(3, 4, 5, true) : doAnotherOperation("some data", 3, 4, 5)) || cancelOperation(20);
			do
			{
				
				j++;
				if (j > 10)
					j--;
			} while (j > 3);
			/* this is a multiline
			* comment that should be formatted
			* in a reasonable way.
			*/
			for (var i:int = 0; i < 10; i++)
				for (var i:int = 0; i < 10; i++)
				{
					
					if (x > 2)
					{
						z -= 2;
					}
					else if (z > 4)
						y++;
					else
					{
						m = 2;
					}
					try
					{
						i++;
					}
					catch (e:Exception)
					{
						trace(e);
					}
					finally
					{
						i = 0;
					}
					
				};
		}
		
		public function get isSimple():Boolean
		{
			return true;
		}
	}
}
