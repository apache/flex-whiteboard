/*
Copyright (c) 2011 Teoti Graphix, LLC - http://www.teotigraphix.com

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

package org.apache.spark.components
{

import mx.core.ClassFactory;

import org.apache.spark.components.supportClasses.DialogBase;
import org.apache.spark.components.supportClasses.TextView;

import spark.core.IDisplayText;

//----------------------------------
//  IconFile
//----------------------------------

//[IconFile("TextDialog.png")]

//----------------------------------
//  Class
//----------------------------------

/**
 * The default popup container <code>PopUp</code> uses for it's text notification.
 * 
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 * @mxml
 */
public class TextDialog extends DialogBase implements IDisplayText
{
	//--------------------------------------------------------------------------
	// 
	//  IDisplayText API :: Properties
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
	
	/**
	 * The dialog's text message.
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
	}
	
	//----------------------------------
	//  isTruncated
	//----------------------------------
	
	/**
	 * @private 
	 */
	public function get isTruncated():Boolean
	{
		if (content is IDisplayText)
			return IDisplayText(content).isTruncated;
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
	public function TextDialog()
	{
		super();
		
		contentRenderer = new ClassFactory(TextView);
	}
	
	/**
	 * @private 
	 */
	override protected function commitProperties():void
	{
		super.commitProperties();
		
		if (textChanged)
		{
			if (content is IDisplayText)
				IDisplayText(content).text = text;
			textChanged = false;
		}
	}
}
}