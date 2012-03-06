////////////////////////////////////////////////////////////////////////////////
//
//  Licensed to the Apache Software Foundation (ASF) under one or more
//  contributor license agreements.  See the NOTICE file distributed with
//  this work for additional information regarding copyright ownership.
//  The ASF licenses this file to You under the Apache License, Version 2.0
//  (the "License"); you may not use this file except in compliance with
//  the License.  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
////////////////////////////////////////////////////////////////////////////////

package mx.validators
{

import mx.resources.IResourceManager;
import mx.resources.ResourceManager;

[ResourceBundle("validators")]

/**
 *  The PostCodeValidator class validates that a String
 *  has the correct length and format for a post code.
 * 
 *  Postcode format consists of CC,N,A and spaces or hyphens
 *  CC is country code (required for some postcodes)
 *	N is a number 0-9
 *  A is a letter A-Z or a-z
 * 
 *  For example "NNNN" is a four digit numeric postcode, "CCNNNN" is country code
 *  followed by four digits and "AA NNNN" is two letters, followed by a space
 *  followed by four digits.
 * 
 *  More than one format can be specified by setting the <code>formats</code>
 *  property to an array of formats.
 *  
 *  @mxml
 *
 *  <p>The <code>&lt;mx:PostCodeValidator&gt;</code> tag
 *  inherits all of the tag attributes of its superclass,
 *  and adds the following tag attributes:</p>
 *  
 *  <pre>
 *  &lt;mx:PostCodeValidator
 *    format="NNNNN"
 *    formats="['NNNNN', 'NNNNN-NNNN']"
 *    invalidCharError="The post code contains invalid characters." 
 *    wrongLengthError="The post code is the wrong length" 
 *  /&gt;
 *  </pre>
 *  
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10.2
 *  @productversion ApacheFlex 4.8
 */
public class PostCodeValidator extends Validator
{
    include "../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Class methods
    //
    //--------------------------------------------------------------------------

    /**
     *  Convenience method for calling a validator.
     *  Each of the standard Flex validators has a similar convenience method.
     *
     *  @param validator The PostCodeValidator instance.
     *
     *  @param value A field to validate.
     *
     *  @param baseField Text representation of the subfield
     *  specified in the <code>value</code> parameter.
     *  For example, if the <code>value</code> parameter specifies value.postCode,
     *  the <code>baseField</code> value is <code>"postCode"</code>.
     *
     *  @return An Array of ValidationResult objects, with one ValidationResult 
     *  object for each field examined by the validator. 
     *
     *  @see mx.validators.ValidationResult
     *
	 *  @langversion 3.0
	 *  @playerversion Flash 10.2
	 *  @productversion ApacheFlex 4.8
     */
    public static function validatePostCode(validator:PostCodeValidator,
                                           postCode:String,
                                           baseField:String):Array
    {
        var results:Array = [];

        var length:int;
		var formatLength:int;
		var noformats:int;
		var spacers:String = " -";
		
		var errors:Array = [];
		var wrongLength:Boolean;
		var invalidChar:Boolean;
		var invalidFormat:Boolean;
		
		var countryDigit:int;
		
		if (validator)
		{
			noformats = validator.formats.length
		}
		
		for (var f:int = 0; f < noformats; f++)
		{	
			countryDigit = 0;
			invalidChar = false;
			invalidFormat = false;
			formatLength = validator.formats[f].length;
			
			if (postCode) {
				length = postCode.length;
			}
			
			for (var i:int = 0; i < length; i++)
			{
				var char:String = postCode.charAt(i);
				var formatChar:String = validator.formats[f].charAt(i);
				
				// ignore character past end of format string
				if (i >= formatLength) {
					break;
				}
				
				if (DECIMAL_DIGITS.indexOf(char) == -1
					&& ROMAN_LETTERS.indexOf(char) == -1 && spacers.indexOf(char) == -1)
				{
					invalidChar = true;
				}
				else if (formatChar == "N" && DECIMAL_DIGITS.indexOf(char) == -1)
				{
					invalidFormat = true;
				}
				else if (formatChar == "A" && ROMAN_LETTERS.indexOf(char) == -1)
				{
					invalidFormat = true;
				}
				else if (formatChar == "C")
				{
					if (countryDigit >= 2 || !validator.countryCode || char != validator.countryCode.charAt(countryDigit))
					{
						invalidFormat = true;
					}
					countryDigit++;
				}
				else if (spacers.indexOf(formatChar) >= 0 && formatChar != char) {
					invalidFormat = true;
				}
			}
			
			wrongLength = (length != formatLength);
			
			// found a match so no need to check further
			if (!invalidFormat && !invalidChar && !wrongLength) {
				errors = null;
				break;
			}
			
			// We want invalid char and invalid format errors show in preference
			// so give wrong length errors a higher value
			errors.push({invalidFormat:invalidFormat, invalidChar:invalidChar, wrongLength:wrongLength,
				count:Number(invalidFormat) + Number(invalidChar) + Number(wrongLength)*1.5})
		}
		
		if (validator && validator.extraValidation)
		{
			var extraError:String = validator.extraValidation(postCode);
			
			if (extraError) {
				results.push(new ValidationResult(
					true, baseField, "wrongFormat", extraError));
			}
		}
		
		if (errors && errors.length > 0) {
			// return result with least number of errors
			// TODO return/remember closest format or place in error string?
			errors.sortOn("count", Array.NUMERIC);
			
			if (errors[0].invalidChar)
			{
				results.push(new ValidationResult(
					true, baseField, "invalidChar",
					validator.invalidCharError));
			}
	        
	        if (errors[0].wrongLength)
	        {
	            results.push(new ValidationResult(
	                true, baseField, "wrongLength",
	                validator.wrongLengthError));
	        }
	        
			if (errors[0].invalidFormat)
			{
	      	 	results.push(new ValidationResult(
	                true, baseField, "wrongFormat",
	                validator.wrongFormatError));
			}
		}
		
        return results;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor.
     *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10.2
	 *  @productversion ApacheFlex 4.8
     */
    public function PostCodeValidator()
    {
        super();
    }

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
	
	/** 
	 *  @private
	 *  The two letter country code used in some postcode formats
	 */
	private var _countryCode:String;
	
	/**
	 *  @private
	 *  An array of the postcode formats to check against.
	 */
	private var _formats:Array = [];
	
	/** 
	 *  Format of postcode
	 *  Format consists of CC,N,A and spaces or hyphens
	 *  CC is country code (required for some postcodes)
	 *	N is a number 0-9
	 *  A is a letter A-Z or a-z
	 *
	 *  @default null
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10.2
	 *  @productversion ApacheFlex 4.8
	 */
	public function get format():String
	{
		if (_formats && _formats.length == 1)
		{
			return _formats[0];
		}
		
		return null;
	}
	
	/**
	 *  @private
	 */
	public function set format(value:String):void
	{
		if (value)
		{
			_formats = [value];
		}
		else
		{
			_formats = []
		}
	}

	/** 
	 *  Optional 2 letter country code in postcode format
	 *
	 *  @default null
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10.2
	 *  @productversion ApacheFlex 4.8
	 */
	public function get countryCode():String
	{
		return _countryCode;
	}
	
	/**
	 *  @private
	 */
	public function set countryCode(value:String):void
	{
		if (value == null || value && value.length == 2)
		{
			_countryCode = value;
		}
	}

	/** 
	 *  Formats of postcode
	 *  Sets an array of valid formats, use for locales
	 *  where more than one format is required. eg en_UK
	 *  See format for format.
	 * 
	 *
	 *  @default []
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10.2
	 *  @productversion ApacheFlex 4.8
	 */
	public function get formats():Array
	{
		return _formats;
	}
	
	/**
	 *  @private
	 */
	public function set formats(value:Array):void
	{
		_formats = value;
	}
	
	/** 
	 *  extraValidation
	 * 
	 * A user supplied method that perform further validation on a postcode.
	 * 
	 * The user supplied method should take as a parameter a postcode (String)
	 * and if the postcode is not valid return an error (String).
	 *
	 *  @default null
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10.2
	 *  @productversion ApacheFlex 4.8
	 */
	public var extraValidation:Function;

    //--------------------------------------------------------------------------
    //
    //  Properties: Errors
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  invalidCharError
    //----------------------------------

    /**
     *  @private
     *  Storage for the invalidCharError property.
     */
    private var _invalidCharError:String;
    
    /**
     *  @private
     */
    private var invalidCharErrorOverride:String;

    [Inspectable(category="Errors", defaultValue="null")]

    /** 
     *  Error message when the post code contains invalid characters.
     *
     *  @default "The postcode code contains invalid characters."
     *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10.2
	 *  @productversion ApacheFlex 4.8
     */
    public function get invalidCharError():String
    {
		if (invalidCharErrorOverride)
		{
			return invalidCharErrorOverride;
		}
		
        return _invalidCharError;
    }

    /**
     *  @private
     */
    public function set invalidCharError(value:String):void
    {
        invalidCharErrorOverride = value;

        if (!value) {
			_invalidCharError =  resourceManager.getString("validators",
				"invalidCharPostcodeError");
		}
    }


    //----------------------------------
    //  wrongLengthError
    //----------------------------------
    
    /**
     *  @private
     *  Storage for the wrongLengthError property.
     */
    private var _wrongLengthError:String;
    
    /**
     *  @private
     */
    private var wrongLengthErrorOverride:String;

    [Inspectable(category="Errors", defaultValue="null")]

    /** 
     *  Error message for an invalid postcode.
     *
     *  @default "The postcode is invalid."
     *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10.2
	 *  @productversion ApacheFlex 4.8
     */
    public function get wrongLengthError():String
    {
		if (wrongLengthErrorOverride)
		{
			return wrongLengthErrorOverride;
		}
		
        return _wrongLengthError;
    }

    /**
     *  @private
     */
    public function set wrongLengthError(value:String):void
    {
        wrongLengthErrorOverride = value;

		if (!value)
		{
        	_wrongLengthError = resourceManager.getString("validators",
				"wrongLengthPostcodeError");
		}
    }
    
    //----------------------------------
    //  wrongFormatError
    //----------------------------------

    /**
     *  @private
     *  Storage for the wrongFormatError property.
     */
    private var _wrongFormatError:String;
    
    /**
     *  @private
     */
    private var wrongFormatErrorOverride:String;

    [Inspectable(category="Errors", defaultValue="null")]

    /** 
     *  Error message for an incorrectly formatted postcode.
     *
     *  @default "The postcode code must be correctly formatted."
     *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10.2
	 *  @productversion ApacheFlex 4.8
     */
    public function get wrongFormatError():String
    {
		if (wrongFormatErrorOverride)
		{
			return wrongFormatErrorOverride;
		}
		
        return _wrongFormatError;
    }

    /**
     *  @private
     */
    public function set wrongFormatError(value:String):void
    {
        wrongFormatErrorOverride = value;

		if (!value) {
        	_wrongFormatError = resourceManager.getString("validators",
				"wrongFormatPostcodeError");
		}
    }

    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------
   
    /**
     *  @private    
     */
    override protected function resourcesChanged():void
    {
        super.resourcesChanged();

        invalidCharError = invalidCharErrorOverride;
        wrongLengthError = wrongLengthErrorOverride;
        wrongFormatError = wrongFormatErrorOverride;    
    }

    /**
     *  Override of the base class <code>doValidation()</code> method
     *  to validate a postcode.
     *
     *  <p>You do not call this method directly;
     *  Flex calls it as part of performing a validation.
     *  If you create a custom Validator class, you must implement this method. </p>
     *
     *  @param value Object to validate.
     *
     *  @return An Array of ValidationResult objects, with one ValidationResult 
     *  object for each field examined by the validator. 
     *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10.2
	 *  @productversion ApacheFlex 4.8
     */
    override protected function doValidation(value:Object):Array
    {
        var results:Array = super.doValidation(value);
        
        // Return if there are errors
        // or if the required property is set to false and length is 0.
        var val:String = value ? String(value) : "";
        if (results.length > 0 || ((val.length == 0) && !required))
            return results;
        else
            return PostCodeValidator.validatePostCode(this, String(value), null);
    }
}

}

