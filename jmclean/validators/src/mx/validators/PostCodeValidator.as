////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2003-2007 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
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
 *  @mxml
 *
 *  <p>The <code>&lt;mx:PostCodeValidator&gt;</code> tag
 *  inherits all of the tag attributes of its superclass,
 *  and adds the following tag attributes:</p>
 *  
 *  <pre>
 *  &lt;mx:PostCodeValidator
 *    format="NNNN"
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
                                           value:Object,
                                           baseField:String):Array
    {
        var results:Array = [];
    
        // Resource-backed properties of the validator.
        var resourceManager:IResourceManager = ResourceManager.getInstance();

        var postCode:String = String(value);
        var length:int = postCode.length;
		var noformats:int = _formats.length;
		var validLetters:String = "CAN";
		var spacers:String = " -";
		
		var wrongLength:Boolean;
		var invalidChar:Boolean;
		var invalidFormat:Boolean;
		
		var allInvalidFormat:Boolean;
		
		var wrongLengthAdded:Boolean;
		var invalidCharAdded:Boolean;
		var invalidFormatAdded:Boolean;
		
		var digit:int;
		
		for (var f:int = 0; f < noformats; f++)
		{	
			invalidFormat = false;
			digit = 0;
			
			for (var i:int = 0; i < length; i++)
			{
				var char:String = postCode.charAt(i);
				var formatChar:String = _formats[f].charAt(i);
				
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
					if (digit >= 2 || !_countryCode || char != _countryCode.charAt(digit))
					{
						invalidFormat = true;
					}
					digit++;
				}
				else if (spacers.indexOf(formatChar) >= 0 && formatChar != char) {
					invalidFormat = true;
				}
			}
			
			// found a match so return without error
			if (!invalidFormat && !invalidChar && (length == _formats[f].length)) {
				return [];
			}
			
			wrongLength = wrongLength || (length != _formats[f].length);
			allInvalidFormat = allInvalidFormat || invalidFormat;
		}
		
		if (invalidChar && !invalidCharAdded)
		{
			invalidCharAdded = true;
			results.push(new ValidationResult(
				true, baseField, "invalidChar",
				validator.invalidCharError));
		}
        
        if (wrongLength && !wrongLengthAdded)
        {
			wrongLengthAdded = true;
            results.push(new ValidationResult(
                true, baseField, "wrongLength",
                validator.wrongLengthError));
        }
        
		if (allInvalidFormat && !invalidFormatAdded)
		{
			invalidFormatAdded = true;
      	 	results.push(new ValidationResult(
                true, baseField, "wrongFormat",
                validator.wrongFormatError));
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
	protected static var _countryCode:String;
	
	/**
	 *  @private
	 *  An array of the postcode formats to check against.
	 */
	protected static var _formats:Array = [];
	
	/** 
	 *  Format of postcode
	 *  Format constist of CC,N,A and space
	 *  CC is country code (rquired for some postcodes)
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
		if (value && value.length == 2)
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
            return PostCodeValidator.validatePostCode(this, value, null);
    }
}

}

