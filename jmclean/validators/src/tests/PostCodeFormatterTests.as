package tests
{
	import mx.formatters.PostCodeFormatter;
	import mx.validators.PostCodeValidator;
	
	import org.flexunit.asserts.assertTrue;

	public class PostCodeFormatterTests
	{		
		public var formatter:PostCodeFormatter;
		
		[Before]
		public function setUp():void
		{
			formatter = new PostCodeFormatter();
		}
		
		[After]
		public function tearDown():void
		{
			formatter = null;
		}
		
		
		[Test]
		public function initial():void
		{
			assertTrue("FormatString is null", formatter.formatString == null);
			assertTrue("Formats is empty array", formatter.formats.length == 0);
		}
		
		[Test]
		public function noRTEs():void
		{
			assertTrue("No RTE if format not set", formatter.format("2000") == "2000");	
			assertTrue("No RTE if format passed emptry string", formatter.format("") == "");
			assertTrue("No RTE if format passed null", formatter.format(null) == "");
			
			formatter.formatString = "NNNN";
			assertTrue("No RTE if format not set", formatter.format("2000") == "2000");	
			assertTrue("No RTE if format passed emptry string", formatter.format("") == "");
			assertTrue("No RTE if format passed null", formatter.format(null) == "");
		}
		
		private function invalidFormatError(error:String):void {
			assertTrue("Has format error", error == PostCodeValidator.ERROR_WRONG_FORMAT);
		}
		
		private function incorrectFormatError(error:String):void {
			assertTrue("Has incorrect format", error == PostCodeValidator.ERROR_INCORRECT_FORMAT);
		}
		
		private function wrongLengthError(error:String):void {
			assertTrue("Has wrong length error", error == PostCodeValidator.ERROR_WRONG_LENGTH);
		}
		
		private function invalidCharError(error:String):void {
			assertTrue("Has invalid character error", error == PostCodeValidator.ERROR_INVALID_CHAR);
		}
		
		[Test]
		public function blankFormat():void {
			formatter.formatString = "";
			
			assertTrue("Format is incorrect", formatter.format("1234") == "");
			incorrectFormatError(formatter.error);	
		}
		
		[Test]
		public function incorrectFormats():void
		{
			formatter.formatString = "NZZN";
			
			assertTrue("Format is incorrect", formatter.format("1234") == "");
			incorrectFormatError(formatter.error);
			
			assertTrue("Format is incorrect", formatter.format("ABCD") == "");
			incorrectFormatError(formatter.error);
		}

		
		[Test]
		public function numberFormats():void
		{
			formatter.formatString ="NNNN";
			
			assertTrue("Format is correct", formatter.format("1234") == "1234");
			assertTrue("No error", formatter.error == "");
			assertTrue("Format is correct", formatter.format("12 34") == "1234");
			assertTrue("No error", formatter.error == "");
			
			assertTrue("Format is incorrect", formatter.format("123456") == "");
			wrongLengthError(formatter.error);
			assertTrue("Format is incorrect", formatter.format("AA12") == "");
			invalidFormatError(formatter.error);
			assertTrue("Format is incorrect", formatter.format("12%4") == "");
			invalidCharError(formatter.error);
		}
		
		[Test]
		public function multipleFormats():void
		{
			formatter.formats = ["NNNN", "NNNNNN" ];
			
			assertTrue("Format is correct", formatter.format("1234") == "1234");
			assertTrue("No error", formatter.error == "");
			assertTrue("Format is correct", formatter.format("123456") == "123456");
			assertTrue("No error", formatter.error == "");
			assertTrue("Format is correct", formatter.format("12 34-") == "1234");
			assertTrue("No error", formatter.error == "");
			
			assertTrue("Format is incorrect", formatter.format("12345") == "");
			wrongLengthError(formatter.error);
			assertTrue("Format is incorrect", formatter.format("1234 5") == "");
			invalidFormatError(formatter.error); //TODO perhaps wrong length?
			assertTrue("Format is incorrect", formatter.format("AA12") == "");
			invalidFormatError(formatter.error);
			assertTrue("Format is incorrect", formatter.format("12%4") == "");
			invalidCharError(formatter.error);
		}
		
		[Test]
		public function alphaNumericFormats():void
		{
			formatter.formatString ="AAAA";
			
			assertTrue("Format is correct", formatter.format("ABCD") == "ABCD");
			assertTrue("No error", formatter.error == "");
			assertTrue("Format is correct", formatter.format("AB CD") == "ABCD");
			assertTrue("No error", formatter.error == "");
			assertTrue("Format is correct", formatter.format("A-B-CD") == "ABCD");
			assertTrue("No error", formatter.error == "");
			
			assertTrue("Format is incorrect", formatter.format("AB C") == "");
			invalidFormatError(formatter.error);
			assertTrue("Format is incorrect", formatter.format("ABCDEF") == "");
			wrongLengthError(formatter.error);
			assertTrue("Format is incorrect", formatter.format("AB12") == "");
			invalidFormatError(formatter.error);
			assertTrue("Format is incorrect", formatter.format("AB%D") == "");
			invalidCharError(formatter.error);
		}
		
		[Test]
		public function paddingFormats():void
		{
			formatter.formatString ="AA-NN NN";
			
			assertTrue("Format is correct", formatter.format("AA1234") == "AA-12 34");
			assertTrue("No error", formatter.error == "");
			assertTrue("Format is correct", formatter.format("AA-1234") == "AA-12 34");
			assertTrue("No error", formatter.error == "");
			assertTrue("Format is correct", formatter.format("AA12 34") == "AA-12 34");
			assertTrue("No error", formatter.error == "");
			assertTrue("Format is correct", formatter.format("AA-12 34") == "AA-12 34");
			assertTrue("No error", formatter.error == "");
			assertTrue("Format is correct", formatter.format("AA 12-34") == "AA-12 34");
			assertTrue("No error", formatter.error == "");
			assertTrue("Format is incorrect", formatter.format("AA-12-34") == "AA-12 34");
			assertTrue("No error", formatter.error == "");
			assertTrue("Format is incorrect", formatter.format("A A--1 2-3-4") == "AA-12 34");
			assertTrue("No error", formatter.error == "");
			
			assertTrue("Format is incorrect", formatter.format("AA-12345") == "");
			invalidFormatError(formatter.error);
			assertTrue("Format is incorrect", formatter.format("AA12-3") == "");
			wrongLengthError(formatter.error);
			assertTrue("Format is incorrect", formatter.format("12-AA 34") == "");
			invalidFormatError(formatter.error);
			assertTrue("Format is incorrect", formatter.format("AA$12 34") == "");
			invalidCharError(formatter.error);
		}
		
		[Test]
		public function unitedKindomPostcodes():void {
			//TODO Double check formats correct
			formatter.formats = ["AN NAA", "ANN NAA", "AAN NAA", "ANA NAA", "AANN NAA", "AANA NAA"];
			
			assertTrue("Format is correct", formatter.format("M11AA") == "M1 1AA");
			assertTrue("No error", formatter.error == "");
			assertTrue("Format is correct", formatter.format("CR26XH") == "CR2 6XH");
			assertTrue("No error", formatter.error == "");
			assertTrue("Format is correct", formatter.format("W1A 1HQ") == "W1A 1HQ");
			assertTrue("No error", formatter.error == "");
			assertTrue("Format is correct", formatter.format("EC1A1BB") == "EC1A 1BB");
			assertTrue("No error", formatter.error == "");
		}
		
		[Test]
		public function canadianPostcodes():void {
			var results:Array;
			var valid:Array = ["K0K 2T0", "V6Z 1T0", "B4V 2K4", "H0H 0H0"];
			
			formatter.formatString = "ANA NAN";
			
			assertTrue("Format is correct", formatter.format("K0K2T0") == "K0K 2T0");
			assertTrue("No error", formatter.error == "");
			assertTrue("Format is correct", formatter.format("V6Z-1T0") == "V6Z 1T0");
			assertTrue("No error", formatter.error == "");
		}
		
		
	}
}