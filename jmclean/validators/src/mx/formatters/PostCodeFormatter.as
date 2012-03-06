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

package mx.formatters
{

import mx.events.ValidationResultEvent;
import mx.managers.ISystemManager;
import mx.managers.SystemManager;
import mx.validators.PostCodeValidator;
import mx.validators.ValidationResult;

[ResourceBundle("formatters")]

/**
 *  The PostCodeFormatter class formats a valid number
 *  based on a user-supplied <code>formatString</code> or
 *  <code>formats</code> property.
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
 *  <p>Spaces and hypens will be added if missing to format the postcode.</p>
 *
 *  <p>If an error occurs, an empty String is returned and a String that  
 *  describes the error is saved to the <code>error</code> property.  
 *  The <code>error</code> property can have one of the following values:</p>
 *
 *  <ul>
 *    <li><code>"wrongFormat"</code> means the postcode has an invalid format.</li>
 *    <li><code>"wrongLength"</code> means the postcode is not a valid length.</li>
 *    <li><code>"invalidChar"</code> means the postcode contains an invalid
 *    character.</li>
 *  </ul>
 *  
 *  @mxml
 *  
 *  <p>The <code>&lt;mx:PostCodeFormatter&gt;</code> tag
 *  inherits all of the tag attributes of its superclass,
 *  and adds the following tag attributes:</p>
 *  
 *  <pre>
 *  &lt;mx:PostCodeFormatter
 *    formatString="NNNNN"
 *    formats="['NNNNN', 'NNNNN-NNNN']"
 *  />
 *  </pre>
 *  
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10.2
 *  @productversion ApacheFlex 4.8
 */
public class PostCodeFormatter extends Formatter
{
    include "../core/Version.as";
	
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
	public function PostCodeFormatter()
	{
		super();
	}

	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  formats
	//----------------------------------

	/**
	 *  @private
	 *  An array of the postcode formats to check against.
	 */
	private var _formats:Array = [];
	
	
	[Inspectable(category="General", defaultValue="null")]

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
	public function get formatString():String
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
	public function set formatString(value:String):void
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
	//  Overidden methods
	//
	//--------------------------------------------------------------------------

    /**
	 *  @private    
     */
	override protected function resourcesChanged():void
	{
		super.resourcesChanged();
		
		//TODO may not be required
	}

 	/**
	 *  Formats the value by using the specified format(s).
	 *  If the value cannot be formatted this method returns an empty String 
	 *  and write a description of the error to the <code>error</code> property.
	 *
	 *  @param value Value to format.
	 *
	 *  @return Formatted String. Empty if an error occurs. A description 
	 *  of the error condition is written to the <code>error</code> property.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10.2
	 *  @productversion ApacheFlex 4.8
	 */
	override public function format(value:Object):String
	{
		var postCode:String = value as String;
		var formatted:String = "";
		var spacers:String = " -";
		var validator:PostCodeValidator = new PostCodeValidator();
		var errors:Array;
		
		error = "";
		
		validator.formats = formats;
		errors = PostCodeValidator.validatePostCode(validator, postCode, null);
		
		// Valid postcode no need for formatting
		if (errors.length == 0)
		{
			return postCode?postCode:"";
		}
		
		// Check and add missing (or convert) padding characters
		for each (var format:String in formats)
		{
			var condensedFormat:String = format;
			var condensedPostcode:String = postCode;
			var char:String;
			var length:int = spacers.length;
			var condensedErrors:Array;
			
			for (var i:int = 0; i < length; i++)
			{
				char = spacers.charAt(i);
				if (condensedFormat)
				{
					condensedFormat = condensedFormat.split(char).join("");
				}
				if (condensedPostcode)
				{
					condensedPostcode = condensedPostcode.split(char).join("");
				}
			}
			
			validator.format = condensedFormat;
			
			condensedErrors = PostCodeValidator.validatePostCode(validator, condensedPostcode, null);
			
			if (condensedErrors.length == 0)
			{
				var pos:int = 0;
				
				length = format.length;
				
				for (i = 0; i < length; i++)
				{
					char = format.charAt(i);
					
					if (spacers.indexOf(char) >= 0)
					{
						formatted += char;
					}
					else {
						formatted += condensedPostcode.charAt(pos++);
					}
				}
				break;
			}
		}
		
		if (!formatted && errors.length > 0)
		{
			error = (errors[0] as ValidationResult).errorCode;
		}

		return formatted;
	}
}

}
