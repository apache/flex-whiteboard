package org.apache.flex.validators
{
	import mx.events.ValidationResultEvent;
	import mx.validators.ValidationResult;

	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertNotNull;
	import org.flexunit.asserts.assertNull;
	import org.flexunit.asserts.assertTrue;
	import org.flexunit.asserts.fail;

	import spark.validators.NumberValidator;
	import spark.validators.supportClasses.GlobalizationValidatorBase;

	public class StringValidatorTests
	{

		[Before]
		public function setUp():void
		{
		}

		private function setUpMinCharsErrorValidation():StringValidator
		{
			const testSource:Object               = {testProperty: "123"};

			const stringValidator:StringValidator = new StringValidator();
			stringValidator.source = testSource;
			stringValidator.property = "testProperty";
			stringValidator.minChars = 4;
			return stringValidator;
		}

		private function setUpMaxCharsErrorValidation():StringValidator
		{
			const stringValidator:StringValidator = new StringValidator();
			const testObject:Object               = {testProperty: "12345"};
			stringValidator.source = testObject;
			stringValidator.property = "testProperty";
			stringValidator.maxChars = 4;
			return stringValidator;
		}

		[Test]
		public function StringValidator_onInstantiation_extendsGlobalizationValidatorBase():void
		{
			const stringValidator:StringValidator = new StringValidator();

			assertTrue(stringValidator is GlobalizationValidatorBase);
		}

		[Test]
		public function StringValidator_onInstantiation_minCharsErrorIsSetToDefaultConstant():void
		{
			const stringValidator:StringValidator = new StringValidator();

			assertEquals(StringValidator.DEFAULT_MIN_CHARS_ERROR, stringValidator.minCharsError);
		}

		[Test]
		public function StringValidator_onInstantiation_maxCharsErrorIsSetToDefaultConstant():void
		{
			const stringValidator:StringValidator = new StringValidator();

			assertEquals(StringValidator.DEFAULT_MAX_CHARS_ERROR, stringValidator.maxCharsError);
		}

		[Test]
		public function StringValidator_onInstantiation_maxCharsIsNegativeOne():void
		{
			const stringValidator:StringValidator = new StringValidator();

			assertEquals(-1, stringValidator.maxChars);
		}

		[Test]
		public function StringValidator_onInstantiation_minCharsIsNegativeOne():void
		{
			const stringValidator:StringValidator = new StringValidator();

			assertEquals(-1, stringValidator.minChars);
		}

		[Test]
		public function validate_sourcePropertyIsLessThanMinChars_ValidationResultEventResultsAreNotNull():void
		{
			const stringValidator:StringValidator             = setUpMinCharsErrorValidation();

			const validationResultEvent:ValidationResultEvent = stringValidator.validate(null, false);

			assertNotNull(validationResultEvent.results);
		}

		[Test]
		public function validate_sourcePropertyIsLessThanMinChars_ValidationResultEventResultMessageIsSetToMinCharsError():void
		{
			const stringValidator:StringValidator             = setUpMinCharsErrorValidation();
			const validationResultEvent:ValidationResultEvent = stringValidator.validate(null, false);

			const validationResult:ValidationResult           = validationResultEvent.results[0] as ValidationResult;

			assertEquals(stringValidator.minCharsError, validationResult.errorMessage);
		}

		[Test]
		public function validate_sourcePropertyIsGreaterThanMaxChars_ValidationResultEventResultsAreNotNull():void
		{
			const stringValidator:StringValidator             = setUpMaxCharsErrorValidation();

			const validationResultEvent:ValidationResultEvent = stringValidator.validate(null, false);

			assertNotNull(validationResultEvent.results);
		}

		[Test]
		public function validate_sourcePropertyIsGreaterThanMaxChars_ValidationResultEventResultMessageIsSetToMaxCharsError():void
		{
			const stringValidator:StringValidator             = setUpMaxCharsErrorValidation();
			const validationResultEvent:ValidationResultEvent = stringValidator.validate(null, false);

			const validationResult:ValidationResult           = validationResultEvent.results[0] as ValidationResult;

			assertEquals(stringValidator.maxCharsError, validationResult.errorMessage);
		}

		[Test]
		public function validate_maxCharsIsNegativeOne_validationResultEventResultsIsNull():void
		{
			const testObject:Object                           = {testProperty: "12"};
			const stringValidator:StringValidator             = new StringValidator();
			stringValidator.source = testObject;
			stringValidator.property = "testProperty";
			stringValidator.maxChars = -1;

			const validationResultEvent:ValidationResultEvent = stringValidator.validate(null, false);

			assertNull(validationResultEvent.results);
		}

		[After]
		public function tearDown():void
		{
		}
	}
}
