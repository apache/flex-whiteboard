package tests
{
	import mx.validators.PostCodeValidator;
	import mx.validators.ValidationResult;
	
	import org.flexunit.asserts.assertTrue;

	public class PostCodeValidatorTests
	{		
		public var validator:PostCodeValidator;
		
		[Before]
		public function setUp():void
		{
			validator = new PostCodeValidator();

			// Currently stored in a static variables as the the doValidation method is static
			validator.format = null;
			validator.countryCode = null;
		}
		
		[After]
		public function tearDown():void
		{
			validator = null;
		}

		[Test]
		public function initial():void
		{
			assertTrue("Format is null", validator.format == null);
			assertTrue("Formats is empty array", validator.formats.length == 0);
			assertTrue("Country code is null", validator.countryCode == null);
		}
		
		[Test]
		public function setFormats():void {
			validator.format = "NNNN";
			assertTrue("Format is correct", validator.format = "NNNN");
			assertTrue("Formats length is correct", validator.formats.length = 1);
			assertTrue("Formats is correct", validator.formats[0] = "NNNN");
			
			validator.formats = ["NNNN", "NNNNNN"];
			assertTrue("Format is null", validator.format == null);
			assertTrue("Formats length is correct", validator.formats.length = 2);
			assertTrue("First format is correct", validator.formats[0] = "NNNN");
			assertTrue("Second format is correct", validator.formats[1] = "NNNNNN");
		}
		
		[Test]
		public function countryCode():void {
			validator.countryCode = "AU";
			assertTrue("Country code is correct", validator.countryCode = "AU");
		}
		
		private function hasError(results:Array, errorCode:String):Boolean {
			for each (var result:ValidationResult in results) {
				if (result.errorCode == errorCode) {
					return true;
				}
			}
			
			return false;
		}
		
		private function invalidFormatError(results:Array) {
			assertTrue("Has format error", hasError(results, "wrongFormat"));
		}
		
		private function wrongLengthError(results:Array) {
			assertTrue("Has wrong length error", hasError(results, "wrongLength"));
		}
		
		private function invalidCharError(results:Array) {
			assertTrue("Has invalid character error", hasError(results, "invalidChar"));
		}
		
		[Test]
		public function fixedNumericPostcode():void {
			var results:Array;
			
			validator.format = "NNNN";
			
			results = PostCodeValidator.validatePostCode(validator, "1234", null);
			assertTrue("No errors", results.length == 0);
			
			results = PostCodeValidator.validatePostCode(validator, "1-23", null);
			assertTrue("Invalid Postcode", results.length == 1);
			invalidFormatError(results);
			
			results = PostCodeValidator.validatePostCode(validator, "12&3", null);
			assertTrue("Invalid Postcode", results.length == 1);
			invalidCharError(results);
			
			results = PostCodeValidator.validatePostCode(validator, "123", null);
			assertTrue("Invalid Postcode", results.length == 1);
			wrongLengthError(results);
			
			results = PostCodeValidator.validatePostCode(validator, "123456", null);
			assertTrue("Invalid Postcode", results.length == 1);
			wrongLengthError(results);
			
			results = PostCodeValidator.validatePostCode(validator, "123D", null);
			assertTrue("Invalid Postcode", results.length == 1);
			invalidFormatError(results);
			
			results = PostCodeValidator.validatePostCode(validator, "1234D", null);
			assertTrue("Invalid Postcode", results.length == 1);
			wrongLengthError(results);
			
			results = PostCodeValidator.validatePostCode(validator, "123D4", null);
			assertTrue("Invalid Postcode", results.length == 2);
			wrongLengthError(results);
			invalidFormatError(results);
			
			results = PostCodeValidator.validatePostCode(validator, "1*3D4", null);
			assertTrue("Invalid Postcode", results.length == 3);
			wrongLengthError(results);
			invalidFormatError(results);
			invalidCharError(results);
		}
		
		[Test]
		public function multpleNumericPostcodes():void {
			var results:Array;
			
			validator.formats = ["NNNN", "NNNNNN"];
			
			results = PostCodeValidator.validatePostCode(validator, "1234", null);
			assertTrue("No errors", results.length == 0);
			
			results = PostCodeValidator.validatePostCode(validator, "123456", null);
			assertTrue("No errors", results.length == 0);
			
			results = PostCodeValidator.validatePostCode(validator, "12%4", null);
			assertTrue("Invalid Postcode", results.length == 1);
			invalidCharError(results);
			
			results = PostCodeValidator.validatePostCode(validator, "1234^6", null);
			assertTrue("Invalid Postcode", results.length == 1);
			// This could be a wrong length or invalid char error
			//TODO change so that invalid char or format error is more important than a wrong length error.
			wrongLengthError(results);
			
			results = PostCodeValidator.validatePostCode(validator, "1-23", null);
			assertTrue("Invalid Postcode", results.length == 1);
			invalidFormatError(results);
			
			results = PostCodeValidator.validatePostCode(validator, "1*23", null);
			assertTrue("Invalid Postcode", results.length == 1);
			invalidCharError(results);
			
			results = PostCodeValidator.validatePostCode(validator, "123", null);
			assertTrue("Invalid Postcode", results.length == 1);
			wrongLengthError(results);
			
			results = PostCodeValidator.validatePostCode(validator, "12345", null);
			assertTrue("Invalid Postcode", results.length == 1);
			wrongLengthError(results);
			
			results = PostCodeValidator.validatePostCode(validator, "1234567", null);
			assertTrue("Invalid Postcode", results.length == 1);
			wrongLengthError(results);
			
			results = PostCodeValidator.validatePostCode(validator, "123D", null);
			assertTrue("Invalid Postcode", results.length == 1);
			invalidFormatError(results);
			
			results = PostCodeValidator.validatePostCode(validator, "1F234", null);
			assertTrue("Invalid Postcode", results.length == 2);
			invalidFormatError(results);
			wrongLengthError(results);
			
			results = PostCodeValidator.validatePostCode(validator, "1F2*4", null);
			assertTrue("Invalid Postcode", results.length == 3);
			invalidFormatError(results);
			wrongLengthError(results);
			invalidCharError(results);
		}
		
		[Test]
		public function countryCodePostcode():void {
			var results:Array;
			
			validator.format = "CCNNNN";
			validator.countryCode = "AA";
			
			results = PostCodeValidator.validatePostCode(validator, "AA1234", null);
			assertTrue("No errors", results.length == 0);
			
			results = PostCodeValidator.validatePostCode(validator, "BB1234", null);
			assertTrue("Invalid Postcode", results.length == 1);
			invalidFormatError(results);
			
			results = PostCodeValidator.validatePostCode(validator, "AA123", null);
			assertTrue("Invalid Postcode", results.length == 1);
			wrongLengthError(results);
			
			results = PostCodeValidator.validatePostCode(validator, "AA12345", null);
			assertTrue("Invalid Postcode", results.length == 1);
			wrongLengthError(results);
			
			results = PostCodeValidator.validatePostCode(validator, "1234AA", null);
			assertTrue("Invalid Postcode", results.length == 1);
			invalidFormatError(results);
			
			results = PostCodeValidator.validatePostCode(validator, "A1A234", null);
			assertTrue("Invalid Postcode", results.length == 1);
			invalidFormatError(results);
		}
		
		[Test]
		public function spacingInPostcodes():void {
			var results:Array;
			
			validator.format = "AA-NN NN";
			
			results = PostCodeValidator.validatePostCode(validator, "AB-12 34", null);
			assertTrue("No errors", results.length == 0);
			
			results = PostCodeValidator.validatePostCode(validator, "AB#12 34", null);
			assertTrue("Invalid Postcode", results.length == 1);
			invalidCharError(results);
						
			results = PostCodeValidator.validatePostCode(validator, "AB 12 34", null);
			assertTrue("Invalid Postcode", results.length == 1);
			invalidFormatError(results);
			
			results = PostCodeValidator.validatePostCode(validator, "AB-12-34", null);
			assertTrue("Invalid Postcode", results.length == 1);
			invalidFormatError(results);
			
			results = PostCodeValidator.validatePostCode(validator, "AB-12  34", null);
			assertTrue("Invalid Postcode", results.length == 2);
			invalidFormatError(results);
			wrongLengthError(results);
			
			results = PostCodeValidator.validatePostCode(validator, "AB-12$ 34", null);
			assertTrue("Invalid Postcode", results.length == 3);
			invalidFormatError(results);
			wrongLengthError(results);
			invalidCharError(results);
		}
		
		[Test]
		public function alphaNumericPostcode():void {
			var results:Array;
			
			validator.format = "NNNN AA";
			
			results = PostCodeValidator.validatePostCode(validator, "1234 AB", null);
			assertTrue("No errors", results.length == 0);
			
			results = PostCodeValidator.validatePostCode(validator, "1234-AB", null);
			assertTrue("Invalid Postcode", results.length == 1);
			invalidFormatError(results);
			
			results = PostCodeValidator.validatePostCode(validator, "AB 1234", null);
			assertTrue("Invalid Postcode", results.length == 1);
			invalidFormatError(results);
			
			results = PostCodeValidator.validatePostCode(validator, "12345AB", null);
			assertTrue("Invalid Postcode", results.length == 1);
			invalidFormatError(results);
			
			results = PostCodeValidator.validatePostCode(validator, "1234ABC", null);
			assertTrue("Invalid Postcode", results.length == 1);
			invalidFormatError(results);
			
			results = PostCodeValidator.validatePostCode(validator, "12345 AB", null);
			assertTrue("Invalid Postcode", results.length == 1);
			wrongLengthError(results);
			
			results = PostCodeValidator.validatePostCode(validator, "123 AB", null);
			assertTrue("Invalid Postcode", results.length == 1);
			wrongLengthError(results);
		}
		
		[Test]
		public function australianPostcodes():void {
			var results:Array;
			var valid:Array = ["2000","3000", "2010", "2462"];
			
			validator.format = "NNNN";
			
			for each (var postcode:String in valid) {
				results = PostCodeValidator.validatePostCode(validator, postcode, null);
				assertTrue("Valid Postcode", results.length == 0);
			}
		}
		
		[Test]
		public function unitedStatesPostcodes():void {
			var results:Array;
			var valid:Array = ["10003", "90036", "95124", "94117", "20500"];
			
			validator.formats = ["NNNNN", "NNNNN-NNNN"];
			
			for each (var postcode:String in valid) {
				results = PostCodeValidator.validatePostCode(validator, postcode, null);
				assertTrue("Valid Postcode", results.length == 0);
			}
		}
		
		[Test]
		public function unitedKindomPostcodes():void {
			var results:Array;
			var valid:Array = ["M1 1AA", "B33 8TH", "CR2 6XH", "DN55 1PT", "W1A 1HQ", "EC1A 1BB", "E98 1NW", "SW1A 0PW"];

			//TODO Double check formats correct
			validator.formats = ["AN NAA", "ANN NAA", "AAN NAA", "ANA NAA", "AANN NAA", "AANA NAA"];
			
			for each (var postcode:String in valid) {
				results = PostCodeValidator.validatePostCode(validator, postcode, null);
				assertTrue("Valid Postcode", results.length == 0);
			}
		}
		
		[Test]
		public function canadianPostcodes():void {
			var results:Array;
			var valid:Array = ["K0K 2T0", "V6Z 1T0", "B4V 2K4", "H0H 0H0"];
			
			validator.format = "ANA NAN";
			
			for each (var postcode:String in valid) {
				results = PostCodeValidator.validatePostCode(validator, postcode, null);
				assertTrue("Valid Postcode", results.length == 0);
			}	
		}
		
	}
}