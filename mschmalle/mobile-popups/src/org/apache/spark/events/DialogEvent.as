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

package org.apache.spark.events
{

import flash.events.Event;

/**
 * Events for the <code>org.apache.spark.components.Dialog</code> 
 * component.
 * 
 * @productversion 1.0
 */
public class DialogEvent extends Event
{
	//--------------------------------------------------------------------------
	// 
	//  Public :: Constants
	// 
	//--------------------------------------------------------------------------
	
	/**
	 * Dispatched when IDialog closes.
	 * 
	 * @eventType dialogClose
	 */
	public static const DIALOG_CLOSE:String = "dialogClose";
	
	/**
	 * Dispatched when IDialog opens.
	 * 
	 * @eventType dialogOpen
	 */
	public static const DIALOG_OPEN:String = "dialogOpen";
	
	//--------------------------------------------------------------------------
	// 
	//  Constructor
	// 
	//--------------------------------------------------------------------------
	
	/**
	 * Constructor, creates a new DialogEvent instance.
	 */
	public function DialogEvent(type:String, 
								bubbles:Boolean = false, 
								cancelable:Boolean = false)
	{
		super(type, bubbles, cancelable);
	}
	
	//--------------------------------------------------------------------------
	// 
	//  Overridden Public :: Methods
	// 
	//--------------------------------------------------------------------------
	
	/**
	 * Clones the <code>DialogEvent</code>.
	 */
	override public function clone():Event
	{
		return new DialogEvent(type, bubbles, cancelable);
	}
	
	/**
	 * Returns a formatted <code>String</code> of the <code>DialogEvent</code>.
	 */
	override public function toString():String
	{
		return formatToString("DialogEvent", "type", "bubbles", "cancelable", "eventPhase");
	}
}
}