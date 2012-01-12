/*
Permission is hereby granted, free of charge, to any person obtaining a copy of 
this software and associated documentation files (the "Software"), to deal in 
the Software without restriction, including without limitation the rights to 
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies 
of the Software, and to permit persons to whom the Software is furnished to do 
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all 
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN 
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

package org.apache.spark.components.supportClasses
{

import flash.events.Event;

import spark.components.Label;
import spark.core.IDisplayText;
import spark.components.supportClasses.SkinnableComponent;

/**
 * The default view for displaying text in a <code>Toast</code> notification.
 * 
 * @productversion 1.0
 */
public class TextView extends SkinnableComponent implements IDisplayText
{
	//--------------------------------------------------------------------------
	//
	//  Public :: SkinParts
	//
	//--------------------------------------------------------------------------
	
	[SkinPart(required="false")]
	
	/**
	 * The <code>Label</code> skin part the displays the <code>text</code> property.
	 * @see #text
	 */
	public var labelDisplay:Label;
	
	//--------------------------------------------------------------------------
	//
	//  Public :: Properties
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  text
	//----------------------------------
	
	/**
	 * @private 
	 */
	private var textChanged:Boolean = false;
	
	/**
	 * @private
	 */
	private var _text:String;
	
	[Bindable("textChanged")]
	[Inspectable(defaultValue="")]
	
	/**
	 * The <code>String</code> text data that gets displayed by the 
	 * <code>labelDisplay</code> skin part.
	 * 
	 * @see #labelDisplay
	 */
	public function get text():String
	{
		return _text;
	}
	
	/**
	 * @private
	 */
	public function set text(value:String):void
	{
		if (_text == value)
			return;
		
		_text = value;
		
		textChanged = true;
		invalidateProperties();
		
		dispatchEvent(new Event("textChanged"));
	}
	
	//----------------------------------
	//  isTruncated
	//----------------------------------
	
	/**
	 * Whether the <code>text</code> is truncated in the <code>labelDisplay</code>.
	 */
	public function get isTruncated():Boolean
	{
		if (labelDisplay)
			return labelDisplay.isTruncated;
		return false;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Constructor.
	 */
	public function TextView()
	{
		super();
		
		// this allows the Label to break if wider then the owner
		percentWidth = 100;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Overridden Protected :: Methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Commits the <code>text</code> value.
	 */
	override protected function commitProperties():void
	{
		super.commitProperties();
		
		if (textChanged)
		{
			if (labelDisplay)
				labelDisplay.text = text;
			textChanged = false;
		}
	}
}
}