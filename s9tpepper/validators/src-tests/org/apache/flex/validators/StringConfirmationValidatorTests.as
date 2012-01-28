package org.apache.flex.validators
{
	import mockolate.runner.MockolateRule;
	import mockolate.stub;

	import mx.events.ValidationResultEvent;
	import mx.validators.ValidationResult;

	import org.flexunit.assertThat;
	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertNotNull;
	import org.flexunit.asserts.assertNull;
	import org.flexunit.asserts.assertTrue;
	import org.flexunit.asserts.fail;
	import org.hamcrest.number.greaterThan;

	import spark.validators.supportClasses.GlobalizationValidatorBase;

	public class StringConfirmationValidatorTests
	{
		[Rule]
		public var mockolateRule:MockolateRule = new MockolateRule();

		[Mock]
		public var stringValidator:StringValidator;

		private var stringConfirmationValidator:StringConfirmationValidator;

		[Before]
		public function setUp():void
		{
			stringConfirmationValidator = new StringConfirmationValidator();
		}


		[Test]
		public function StringConfirmationValidator_onInstantiation_isSubclassOfGlobalizationBaseValidator():void
		{
			assertTrue(stringConfirmationValidator is GlobalizationValidatorBase);
		}

		[Test]
		public function StringConfirmationValidator_onInstantiation_propertyIsNull():void
		{
			assertNull(stringConfirmationValidator.property);
		}

		[Test]
		public function stringValidator_onSettingStringValidator_propertyUpdatedToStringValidatorProperty():void
		{
			stub(stringValidator).getter("property").returns("aPropertyName");

			stringConfirmationValidator.stringValidator = stringValidator;

			assertEquals("aPropertyName", stringConfirmationValidator.property);
		}

		[Test]
		public function stringValidator_onSettingStringValidatorNull_propertyIsNowNull():void
		{
			stringConfirmationValidator.property = "aPropertyName";

			stringConfirmationValidator.stringValidator = null;

			assertNull(stringConfirmationValidator.property);
		}

		[Test]
		public function validate_sourceDoesNotMatchStringValidatorSource_resultsNotNull():void
		{
			stubSourcesDontMatchError();

			const validationResultEvent:ValidationResultEvent = stringConfirmationValidator.validate(null, false);

			assertNotNull(validationResultEvent.results);
		}

		[Test]
		public function validate_sourceDoesNotMatchStringValidatorSource_validationResultMessageIsStringsDontMatchError():void
		{
			stubSourcesDontMatchError();

			const validationResultEvent:ValidationResultEvent = stringConfirmationValidator.validate(null, false);
			const validationResult:ValidationResult           = validationResultEvent.results.pop() as ValidationResult;

			assertEquals(stringConfirmationValidator.stringDoesNotMatchError, validationResult.errorMessage);
		}

		private function stubSourcesDontMatchError():void
		{
			stub(stringValidator).getter("property").returns("text");
			stub(stringValidator).getter("source").returns({text: "some different text",
															description: "some other object"});
			stringConfirmationValidator.source = {text: "some text"};
			stringConfirmationValidator.stringValidator = stringValidator;
		}


		[Test]
		public function validate_stringValidatorIsNull_resultsNotNull():void
		{
			stringConfirmationValidator.stringValidator = null;

			const validationResultEvent:ValidationResultEvent = stringConfirmationValidator.validate(null, false);

			assertNotNull(validationResultEvent.results);
		}

		[Test]
		public function validate_stringValidatorIsNull_validationResultMessageIsNothingToConfirmAgainstError():void
		{
			stringConfirmationValidator.stringValidator = null;

			const validationResultEvent:ValidationResultEvent = stringConfirmationValidator.validate(null, false);
			const validationResult:ValidationResult           = validationResultEvent.results.pop() as ValidationResult;

			assertEquals(stringConfirmationValidator.nothingToConfirmAgainstError, validationResult.errorMessage);
		}

		[Test]
		public function validate_stringValidatorSourceMatches_resultsIsNull():void
		{
			stub(stringValidator).getter("property").returns("text");
			stub(stringValidator).getter("source").returns({text: "some text", description: "some other object"});
			stringConfirmationValidator.source = {text: "some text"};
			stringConfirmationValidator.stringValidator = stringValidator;

			var validationResultEvent:ValidationResultEvent = stringConfirmationValidator.validate(null, false);

			assertNull(validationResultEvent.results);
		}


		[After]
		public function tearDown():void
		{
			stringConfirmationValidator = null;
		}
	}
}
