package org.apache.flex.validators
{
	import mx.core.mx_internal;
	import mx.validators.ValidationResult;

	import spark.validators.supportClasses.GlobalizationValidatorBase;

	use namespace mx_internal;

	public class StringConfirmationValidator extends GlobalizationValidatorBase
	{
		private var _stringValidator:StringValidator;
		private var _stringDoesNotMatchError:String      = "Does not match.";
		private var _nothingToConfirmAgainstError:String = "The confirmation validator does not have a string to validate against.";

		public function StringConfirmationValidator()
		{
			super();
		}

		public function get nothingToConfirmAgainstError():String
		{
			return _nothingToConfirmAgainstError;
		}

		public function set nothingToConfirmAgainstError(value:String):void
		{
			_nothingToConfirmAgainstError = value;
		}

		public function get stringDoesNotMatchError():String
		{
			return _stringDoesNotMatchError;
		}

		public function set stringDoesNotMatchError(value:String):void
		{
			_stringDoesNotMatchError = value;
		}

		public function get stringValidator():StringValidator
		{
			return _stringValidator;
		}

		public function set stringValidator(value:StringValidator):void
		{
			_stringValidator = value;

			property = (_stringValidator) ? _stringValidator.property : null;
		}

		override protected function doValidation(value:Object):Array
		{
			var results:Array = super.doValidation(value);

			if (stringValidator)
			{
				if (valuesDontMatch())
					generateError(results, stringDoesNotMatchError);
			}
			else
			{
				generateError(results, nothingToConfirmAgainstError);
			}

			return results;
		}

		private function generateError(results:Array, errorMessage:String=""):void
		{
			results.push(new ValidationResult(true, "", "", errorMessage));
		}


		protected function valuesDontMatch():Boolean
		{
			const stringValidatorCurrentValue:String = stringValidator.source[stringValidator.property];
			const confirmationCurrentValue:String    = source[property];
			return confirmationCurrentValue != stringValidatorCurrentValue;
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
