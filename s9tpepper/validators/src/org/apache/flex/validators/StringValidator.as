package org.apache.flex.validators
{
	import mx.core.mx_internal;
	import mx.validators.ValidationResult;

	import spark.validators.supportClasses.GlobalizationValidatorBase;

	use namespace mx_internal;

	public class StringValidator extends GlobalizationValidatorBase
	{
		public static var DEFAULT_MIN_CHARS_ERROR:String = "The string does not meet the minimum character requirement.";
		public static var DEFAULT_MAX_CHARS_ERROR:String = "The string exceeds the maximum character requirement.";

		private var _maxChars:int                        = -1;
		private var _minChars:int                        = -1;
		private var _minCharsError:String                = DEFAULT_MIN_CHARS_ERROR;
		private var _maxCharsError:String                = DEFAULT_MAX_CHARS_ERROR;

		public function StringValidator()
		{
			super();
		}

		public function get maxCharsError():String
		{
			return _maxCharsError;
		}

		public function set maxCharsError(value:String):void
		{
			_maxCharsError = value;
		}

		public function get maxChars():int
		{
			return _maxChars;
		}

		public function set maxChars(value:int):void
		{
			_maxChars = value;
		}

		public function get minCharsError():String
		{
			return _minCharsError;
		}

		public function set minCharsError(value:String):void
		{
			_minCharsError = value;
		}

		public function get minChars():int
		{
			return _minChars;
		}

		public function set minChars(value:int):void
		{
			_minChars = value;
		}

		override protected function doValidation(value:Object):Array
		{
			const results:Array = super.doValidation(value);

			validateMinChars(value, results);
			validateMaxChars(value, results);

			return results;
		}

		protected function validateMaxChars(value:Object, results:Array):void
		{
			if (valueDoesNotMeetMaxChars(value) && maxCharsIsNotDisabled())
				results[results.length] = new ValidationResult(true, "", "", maxCharsError);
		}

		protected function maxCharsIsNotDisabled():Boolean
		{
			return maxChars != -1;
		}

		protected function valueDoesNotMeetMaxChars(value:Object):Boolean
		{
			const valueToValidate:String = value as String;
			return !(valueToValidate && valueToValidate.length <= maxChars);
		}

		protected function validateMinChars(value:Object, results:Array):void
		{
			if (valueDoesNotMeetMinChars(value))
				results[results.length] = createMinCharValidationResult();
		}

		protected function valueDoesNotMeetMinChars(value:Object):Boolean
		{
			const valueToValidate:String = value as String;
			return !(valueToValidate && valueToValidate.length > minChars);
		}

		protected function createMinCharValidationResult():ValidationResult
		{
			return new ValidationResult(true, "", "", minCharsError);
		}

		override mx_internal function createWorkingInstance():void
		{
		}

		mx_internal function get g11nWorkingInstance():Object
		{
			return null;
		}

		mx_internal function set g11nWorkingInstance(sparkFormatter:Object):void
		{
		}
	}
}
