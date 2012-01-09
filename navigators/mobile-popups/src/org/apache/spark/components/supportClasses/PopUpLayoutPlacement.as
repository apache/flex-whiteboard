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

package org.apache.spark.components.supportClasses
{

/**
 * An enumerated class of PopUp layout placement values.
 * 
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
public final class PopUpLayoutPlacement
{
	//--------------------------------------------------------------------------
	//
	// Public :: Constants
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Constant that identifies the <strong>top</strong> layout placement.
	 */
	public static const TOP:String = "top";
	
	/**
	 * Constant that identifies the <strong>topRight</strong> layout placement.
	 */
	public static const TOP_RIGHT:String = "topRight";	
	
	/**
	 * Constant that identifies the <strong>right</strong> layout placement.
	 */
	public static const RIGHT:String = "right";
	
	/**
	 * Constant that identifies the <strong>bottomRight</strong> layout placement.
	 */
	public static const BOTTOM_RIGHT:String = "bottomRight";
	
	/**
	 * Constant that identifies the <strong>bottom</strong> layout placement.
	 */
	public static const BOTTOM:String = "bottom";
	
	/**
	 * Constant that identifies the <strong>bottomLeft</strong> layout placement.
	 */
	public static const BOTTOM_LEFT:String = "bottomLeft";
	
	/**
	 * Constant that identifies the <strong>left</strong> layout placement.
	 */
	public static const LEFT:String = "left";
	
	/**
	 * Constant that identifies the <strong>topLeft</strong> layout placement.
	 */
	public static const TOP_LEFT:String = "topLeft";
	
	/**
	 * Constant that identifies the <strong>center</strong> layout placement.
	 */
	public static const CENTER:String = "center";
	
	/**
	 * Constant that identifies the <strong>horizontal</strong> fill layout placement.
	 */
	public static const CENTER_FILL_HORIZONTAL:String = "centerFillHorizontal";
	
	/**
	 * Constant that identifies the <strong>vertical</strong> fill layout placement.
	 */
	public static const CENTER_FILL_VERTICAL:String = "centerFillVertical";
	
	/**
	 * Constant that identifies the <strong>fill</strong> layout placement.
	 */
	public static const CENTER_FILL:String = "centerFill";
	
	//--------------------------------------------------------------------------
	//
	//  Public Class :: Methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Returns whether the placement <code>value</code> passed is a valid placement.
	 * 
	 * @param value A string indicating the placement to check for valid.
	 * @return A Boolean indicating whether the placement value is valid.
	 */
	public static function isValid(value:String):Boolean
	{
		switch(value)
		{
			case TOP:
			case TOP_RIGHT:
			case RIGHT:
			case BOTTOM_RIGHT:
			case BOTTOM:
			case BOTTOM_LEFT:
			case LEFT:
			case TOP_LEFT:
			case CENTER:
			case CENTER_FILL_HORIZONTAL:
			case CENTER_FILL_VERTICAL:
			case CENTER_FILL:
				return true;
			default:
				return false;
		}
	}
	
	/**
	 * Returns an enumerated Array.
	 * 
	 * @return An Array of placement values.
	 */
	public static function toArray():Array
	{
		return [TOP, TOP_RIGHT, RIGHT, BOTTOM_RIGHT, 
			BOTTOM, BOTTOM_LEFT, LEFT, TOP_LEFT, CENTER];
	}
}
}