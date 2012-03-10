package tests
{
	import mx.resources.IResourceManager;
	import mx.resources.ResourceManager;
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
		public function noRTEs():void
		{
			var results:Array;
			
			results = PostCodeValidator.validatePostCode(null, null, null);
			assertTrue("No errors", results.length == 0);
			results = PostCodeValidator.validatePostCode(null, "", null);
			assertTrue("No errors", results.length == 0);
			results = PostCodeValidator.validatePostCode(null, "2000", null);
			assertTrue("No errors", results.length == 0);
			
			results = PostCodeValidator.validatePostCode(validator, null, null);
			assertTrue("No errors", results.length == 0);
			results = PostCodeValidator.validatePostCode(validator, "", null);
			assertTrue("No errors", results.length == 0);
			results = PostCodeValidator.validatePostCode(validator, "2000", null);
			assertTrue("No errors", results.length == 0);
			
			validator.format = "NNNN";
			
			results = PostCodeValidator.validatePostCode(null, null, null);
			assertTrue("No errors", results.length == 0);
			results = PostCodeValidator.validatePostCode(null, "", null);
			assertTrue("No errors", results.length == 0);
			results = PostCodeValidator.validatePostCode(null, "2000", null);
			assertTrue("No errors", results.length == 0);
			
			results = PostCodeValidator.validatePostCode(validator, null, null);
			assertTrue("Invalid Postcode", results.length == 1);
			wrongLengthError(results);
			results = PostCodeValidator.validatePostCode(validator, "", null);
			assertTrue("Invalid Postcode", results.length == 1);
			wrongLengthError(results);
			results = PostCodeValidator.validatePostCode(validator, "2000", null);
			assertTrue("Valid Postcode", results.length == 0);
		}
		
		[Test]
		public function emptyFormat():void {
			var results:Array;
			
			validator.formats = ["NNNN",""];
			
			results = PostCodeValidator.validatePostCode(validator, "", null);
			assertTrue("Incorrect format error", results.length == 1);
			incorrectFormatError(results);
			
			validator.format = "";
			
			results = PostCodeValidator.validatePostCode(validator, "", null);
			assertTrue("Incorrect format error", results.length == 1);
			incorrectFormatError(results);
		}
		
		[Test]
		public function invalidFormat():void {
			var results:Array;
			
			validator.format = "ZZZZ";
			results = PostCodeValidator.validatePostCode(validator, "1234", null);
			assertTrue("Invalid format", results.length == 1);
			incorrectFormatError(results);
			
			validator.format = "CCAA%NN";
			results = PostCodeValidator.validatePostCode(validator, "AABBC12", null);
			assertTrue("Invalid format", results.length == 2);
			incorrectFormatError(results);			
			
			validator.format = "99NN";
			results = PostCodeValidator.validatePostCode(validator, "9912", null);
			assertTrue("Invalid format", results.length == 1);
			incorrectFormatError(results);
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
		
		private function invalidFormatError(results:Array):void {
			assertTrue("Has format error", hasError(results, PostCodeValidator.ERROR_WRONG_FORMAT));
		}
		
		private function incorrectFormatError(results:Array):void {
			assertTrue("Has format error", hasError(results, PostCodeValidator.ERROR_INCORRECT_FORMAT));
		}
		
		private function wrongLengthError(results:Array):void {
			assertTrue("Has wrong length error", hasError(results, PostCodeValidator.ERROR_WRONG_LENGTH));
		}
		
		private function invalidCharError(results:Array):void {
			assertTrue("Has invalid character error", hasError(results, PostCodeValidator.ERROR_INVALID_CHAR));
		}
		
		[Test]
		public function fixedNumericPostcode():void {
			var results:Array;
			
			validator.format = "NNNN";
			
			results = PostCodeValidator.validatePostCode(validator, "1234", null);
			assertTrue("No errors", results.length == 0);
			
			results = PostCodeValidator.validatePostCode(validator, "１２３４", null);
			assertTrue("No errors", results.length == 0);
			
			results = PostCodeValidator.validatePostCode(validator, "1-23", null);
			assertTrue("Invalid Postcode", results.length == 1);
			invalidFormatError(results);
			
			results = PostCodeValidator.validatePostCode(validator, "１-３４", null);
			assertTrue("Invalid Postcode", results.length == 1);
			invalidFormatError(results);
			
			results = PostCodeValidator.validatePostCode(validator, "12&3", null);
			assertTrue("Invalid Postcode", results.length == 1);
			invalidCharError(results);
			
			results = PostCodeValidator.validatePostCode(validator, "１２&４", null);
			assertTrue("Invalid Postcode", results.length == 1);
			invalidCharError(results);
			
			results = PostCodeValidator.validatePostCode(validator, "123", null);
			assertTrue("Invalid Postcode", results.length == 1);
			wrongLengthError(results);
			
			results = PostCodeValidator.validatePostCode(validator, "１２３", null);
			assertTrue("Invalid Postcode", results.length == 1);
			wrongLengthError(results);
			
			results = PostCodeValidator.validatePostCode(validator, "123456", null);
			assertTrue("Invalid Postcode", results.length == 1);
			wrongLengthError(results);
			
			results = PostCodeValidator.validatePostCode(validator, "０１２３４５６", null);
			assertTrue("Invalid Postcode", results.length == 1);
			wrongLengthError(results);
			
			results = PostCodeValidator.validatePostCode(validator, "123D", null);
			assertTrue("Invalid Postcode", results.length == 1);
			invalidFormatError(results);
			
			results = PostCodeValidator.validatePostCode(validator, "１２３D", null);
			assertTrue("Invalid Postcode", results.length == 1);
			invalidFormatError(results);
			
			results = PostCodeValidator.validatePostCode(validator, "1234D", null);
			assertTrue("Invalid Postcode", results.length == 1);
			wrongLengthError(results);
			
			results = PostCodeValidator.validatePostCode(validator, "１２３４D", null);
			assertTrue("Invalid Postcode", results.length == 1);
			wrongLengthError(results);
			
			results = PostCodeValidator.validatePostCode(validator, "123D4", null);
			assertTrue("Invalid Postcode", results.length == 2);
			wrongLengthError(results);
			invalidFormatError(results);
			
			results = PostCodeValidator.validatePostCode(validator, "１２３D４", null);
			assertTrue("Invalid Postcode", results.length == 2);
			wrongLengthError(results);
			invalidFormatError(results);
			
			results = PostCodeValidator.validatePostCode(validator, "1*3D4", null);
			assertTrue("Invalid Postcode", results.length == 3);
			wrongLengthError(results);
			invalidFormatError(results);
			invalidCharError(results);
			
			results = PostCodeValidator.validatePostCode(validator, "１*３D４", null);
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
			invalidCharError(results);
			
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
			assertTrue("Invalid Postcode", results.length == 2);
			wrongLengthError(results);
			invalidFormatError(results);
			
			results = PostCodeValidator.validatePostCode(validator, "123 AB", null);
			assertTrue("Invalid Postcode", results.length == 2);
			wrongLengthError(results);
			invalidFormatError(results);
		}
		
		[Test]
		public function australianPostcodes():void {
			var results:Array;
			var valid:Array = ["2000","3000", "2010", "2462"];
			
			validator.suggestFormat("en_AU");
			
			for each (var postcode:String in valid) {
				results = PostCodeValidator.validatePostCode(validator, postcode, null);
				assertTrue("Valid Postcode", results.length == 0);
			}
		}
		
		[Test]
		public function unitedStatesPostcodes():void {
			var results:Array;
			var valid:Array = ["10003", "90036", "95124", "94117", "20500"];
			
			validator.suggestFormat("en_US");
			
			for each (var postcode:String in valid) {
				results = PostCodeValidator.validatePostCode(validator, postcode, null);
				assertTrue("Valid Postcode", results.length == 0);
			}
		}
		
		[Test]
		public function unitedKindomPostcodes():void {
			var results:Array;
			var valid:Array = ["M1 1AA", "B33 8TH", "CR2 6XH", "DN55 1PT", "W1A 1HQ", "EC1A 1BB", "E98 1NW", "SW1A 0PW"];
			
			validator.suggestFormat("en_UK");
			
			for each (var postcode:String in valid) {
				results = PostCodeValidator.validatePostCode(validator, postcode, null);
				assertTrue("Valid Postcode", results.length == 0);
			}
		}
		
		
		[Test]
		public function canadianPostcodes():void {
			var results:Array;
			var valid:Array = ["K0K 2T0", "V6Z 1T0", "B4V 2K4", "H0H 0H0"];
			
			validator.suggestFormat("en_CA");
			
			for each (var postcode:String in valid) {
				results = PostCodeValidator.validatePostCode(validator, postcode, null);
				assertTrue("Valid Postcode", results.length == 0);
			}	
		}
		
		[Test]
		public function japanesePostcodes():void {
			var results:Array;
			var valid:Array = ["〒 100-0006", "100-0006", "600-8216", "282-0004"];
			
			validator.suggestFormat("ja_JP");
			validator.countryCode = "〒";
			
			for each (var postcode:String in valid) {
				results = PostCodeValidator.validatePostCode(validator, postcode, null);
				assertTrue("Valid Postcode", results.length == 0);
			}	
		}
		
		[Test]
		public function multipleFormats():void {
			var validator1:PostCodeValidator = new PostCodeValidator();
			var validator2:PostCodeValidator = new PostCodeValidator();
			var results:Array = [];
			
			validator1.format = "AAAA";
			validator2.format = "NNNNNN";
			
			results = PostCodeValidator.validatePostCode(validator1, "ABCD", null);
			assertTrue("Valid Postcode", results.length == 0);
			results = PostCodeValidator.validatePostCode(validator2, "123456", null);
			assertTrue("Valid Postcode", results.length == 0);
		}
		
		[Test]
		public function checkCanadianLetters():void {
			var results:Array;
			
			validator.format = "ANA NAN";
			validator.extraValidation = canadianLetters;
			
			results = PostCodeValidator.validatePostCode(validator, "K0K 2T0", null);
			assertTrue("Valid Postcode", results.length == 0);
			
			results = PostCodeValidator.validatePostCode(validator, "K0D 2I0", null);
			assertTrue("Invalid Postcode", results.length == 1);
			invalidFormatError(results); //TODO mark as user error?
		}
		
		public function canadianLetters(postCode:String):String {
			var notUsed:String = "DFIOQU";
			var length:int = notUsed.length;
			var char:String;
			
			for (var i:int = 0; i < length; i++) {
				char = notUsed.charAt(i);
				
				if (postCode.indexOf(char) >= 0) {
					return "Postcode containts an invalid character D,F,I,O,Q or U";
				}
			}
			
			return null;
		}

		[Test]
		public function checkAustraliaPOBoxes():void {
			var results:Array;
			
			validator.format = "NNNN";
			validator.extraValidation = australiaPOBox;
			
			results = PostCodeValidator.validatePostCode(validator, "2010", null);
			assertTrue("Valid Postcode", results.length == 0);
			
			results = PostCodeValidator.validatePostCode(validator, "0250", null);
			assertTrue("Invalid Postcode", results.length == 1);
			invalidFormatError(results); //TODO mark as user error?
			
			results = PostCodeValidator.validatePostCode(validator, "5820", null);
			assertTrue("Invalid Postcode", results.length == 1);
			invalidFormatError(results); //TODO mark as user error?
		}
		
		public function australiaPOBox(postCode:String):String {
			var postCodeNum:int = int(postCode);
			var ranges:Array = [
				{low:1000, high:1999},
				{low:200, high:299},
				{low:8000, high:8999},
				{low:9000, high:9999},
				{low:5800, high:5999},
				{low:6800, high:6999},
				{low:7800, high:7999}, 
				{low:900, high:999}];
			var length:int = ranges.length;
			
			for (var i:int = 0; i < length; i++) {	
				if (postCodeNum >= ranges[i].low && postCodeNum <= ranges[i].high) {
					return "Postcode is a PO Box number";
				}
			}

			return null;
		}
		
		[Test]
		public function errorOverrides():void {
			var error:String = "New error";
			var resourceManager:IResourceManager = ResourceManager.getInstance();
			var resourcesUS:Object = resourceManager.getResourceBundle("en_US", "validators");
			
			assertTrue("Error not overridden", validator.invalidCharError == resourcesUS.content.invalidCharPostcodeError);
			validator.invalidCharError = error;
			assertTrue("Error overridden", validator.invalidCharError == error);
			validator.invalidCharError = null;
			assertTrue("Error not overridden", validator.invalidCharError == resourcesUS.content.invalidCharPostcodeError);
			
			assertTrue("Error not overridden", validator.wrongFormatError == resourcesUS.content.wrongFormatPostcodeError);
			validator.wrongFormatError = error;
			assertTrue("Error overridden", validator.wrongFormatError == error);
			validator.wrongFormatError = null;
			assertTrue("Error not overridden", validator.wrongFormatError == resourcesUS.content.wrongFormatPostcodeError);
			
			assertTrue("Error not overridden", validator.wrongLengthError == resourcesUS.content.wrongLengthPostcodeError);
			validator.wrongLengthError = error;
			assertTrue("Error overridden", validator.wrongLengthError == error);
			validator.wrongLengthError = null;
			assertTrue("Error not overridden", validator.wrongLengthError == resourcesUS.content.wrongLengthPostcodeError);

			assertTrue("Error not overridden", validator.incorrectFormatError == resourcesUS.content.incorrectFormatPostcodeError);
			validator.incorrectFormatError = error;
			assertTrue("Error overridden", validator.incorrectFormatError == error);
			validator.incorrectFormatError = null;
			assertTrue("Error not overridden", validator.incorrectFormatError == resourcesUS.content.incorrectFormatPostcodeError);
	}
		
		// NOTE: To pass this test project must be compiled with option locale=en_US,en_AU
		[Test]
		public function changeLocale():void {
			var resourceManager:IResourceManager = ResourceManager.getInstance();
			var resourcesUS:Object = resourceManager.getResourceBundle("en_US", "validators");
			var resourcesAU:Object = resourceManager.getResourceBundle("en_AU", "validators");
				
			assertTrue("en_US locale loaded", resourcesUS);
			assertTrue("en_AU locale loaded", resourcesAU);
			
			assertTrue("US Error", validator.invalidCharError == resourcesUS.content.invalidCharPostcodeError);
			assertTrue("US Error", validator.wrongFormatError == resourcesUS.content.wrongFormatPostcodeError);
			assertTrue("US Error", validator.wrongLengthError == resourcesUS.content.wrongLengthPostcodeError);
			
			resourceManager.localeChain = ["en_AU"];
			
			assertTrue("Error changed", validator.invalidCharError != resourcesUS.content.invalidCharPostcodeError);
			assertTrue("Error changed", validator.wrongFormatError != resourcesUS.content.wrongFormatPostcodeError);
			assertTrue("Error changed", validator.wrongLengthError != resourcesUS.content.wrongLengthPostcodeError);
		
			assertTrue("AU Error", validator.invalidCharError == resourcesAU.content.invalidCharPostcodeError);
			assertTrue("AU Error", validator.wrongFormatError == resourcesAU.content.wrongFormatPostcodeError);
			assertTrue("AU Error", validator.wrongLengthError == resourcesAU.content.wrongLengthPostcodeError);
		}
		
		[Test]
		public function suggestedFormat():void {
			validator.suggestFormat("en_AU");
			assertTrue("Australian format", validator.format == "NNNN");
			
			validator.suggestFormat("en-CA");
			assertTrue("Australian format", validator.format == "ANA NAN");
			
			validator.suggestFormat("en_US");
			assertTrue("US format", validator.formats[0] == "NNNNN");
			assertTrue("US format", validator.formats[1] == "NNNNN-NNNN");
			
			validator.suggestFormat("it_IT");
			assertTrue("IT format", validator.format == "NNNNN");
			
			validator.suggestFormat("fr_CA");
			assertTrue("CA format", validator.format == "ANA NAN");
			validator.suggestFormat("en_CA");
			assertTrue("CA format", validator.format == "ANA NAN");
			
			validator.suggestFormat("en_NZ"); // not known
			assertTrue("NZ format not known", validator.format == null);
			
			// may set format (based on user locale) to anything just check no RTE
			// and returns something
			assertTrue("User locale format", validator.suggestFormat() != null)
		}

	}
}