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

package org.apache.spark.components
{

import flash.display.DisplayObjectContainer;

import mx.core.IFactory;
import mx.core.IVisualElement;

/**
 * The <code>IDialog</code> interface defines a popup component 
 * that displays a <code>title</code>, <code>icon</code> and 
 * <code>content</code> view.
 * 
 * <p>By calling the dialog's <code>open()</code> and <code>close()</code> 
 * methods, the underlying display mechanism is hidden from the 
 * developer. A developer can override default behavior at anytime.</p>
 * 
 * <p><strong>Note:</strong> The <code>IDialog</code> API allows 
 * for deffered content creation in the <code>contentRenderer</code> 
 * factory or direct assignment of an instantiated <code>IVisualElement</code> 
 * using the <code>content</code> property directly.</p>
 * 
 * <p>The <code>PopUp</code> class is designed to create a layer of 
 * abstraction to allow dialogs to be created and displayed in 
 * many different ways.</p>
 * 
 * @productversion 1.0
 */
public interface IDialog extends IVisualElement
{
	//--------------------------------------------------------------------------
	// 
	//  Properties
	// 
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  title
	//----------------------------------
	
	/**
	 * The <strong>text</strong> that will appear in the dialog's titlebar 
	 * above the content view.
	 * 
	 * @productversion 1.0
	 */
	function get title():String;
	
	/**
	 * @private
	 */
	function set title(value:String):void;
	
	//----------------------------------
	//  icon
	//----------------------------------
	
	/**
	 * The visual <strong>icon</strong> that will appear in the dialog's titlebar 
	 * above the content view.
	 * 
	 * @productversion 1.0
	 */
	function get icon():Object;
	
	/**
	 * @private
	 */
	function set icon(value:Object):void;
	
	//----------------------------------
	//  contentRenderer
	//----------------------------------
	
	/**
	 * An <code>IFactory</code> instance that is used to create the 
	 * dialog's <code>content</code>.
	 * 
	 * <p>Using the <code>contentRenderer</code>, the dialog's content 
	 * can easily change while keeping the original dialog's frame. </p>
	 * 
	 * <p>Another benefit is using a <code>contentRenderer</code> can 
	 * cut down on the amount of <em>MXML classes</em> used to create 
	 * special dialogs. A developer will create the standard dialog 
	 * and then only need to create specific views for each dialog's 
	 * <code>content</code>.</p>
	 * 
	 * @productversion 1.0
	 */
	function get contentRenderer():IFactory;
	
	/**
	 * @private
	 */
	function set contentRenderer(value:IFactory):void;
	
	//----------------------------------
	//  content
	//----------------------------------
	
	/**
	 * The <code>IVisualElement</code> <code>content</code> view that 
	 * is positioned by default below the <code>titleBar</code>.
	 * 
	 * <p>The <code>content</code> can be populated in two ways;</p>
	 * 
	 * <ul>
	 * <li>By setting the <code>contentRenderer</code> to an <code>IFactory</code> 
	 * instance that will be created when the <code>IDialog#open()</code> 
	 * method is called.</li>
	 * <li>By setting the <code>content</code> with an already instantiated 
	 * <code>IVisualElement</code>.</li>
	 * </ul>
	 * 
	 * @productversion 1.0
	 */
	function get content():IVisualElement;
	
	/**
	 * @private
	 */
	function set content(value:IVisualElement):void;
	
	//----------------------------------
	//  isOpen
	//----------------------------------
	
	/**
	 * Returns whether the <code>IDialog#open()</code> method has been 
	 * called and the <code>IDialog</code> has been added to the <code>Stage</code> 
	 * by the <code>PopUpManager</code> or <code>ISystemManager</code>.
	 * 
	 * <p>This property will return <code>false</code> when the 
	 * <code>IDialog#close()</code> method has been called and the 
	 * <code>IDialog</code> has been removed from the <code>Stage</code> 
	 * by the <code>PopUpManager</code> or <code>ISystemManager</code>.</p>
	 * 
	 * @productversion 1.0
	 */
	function get isOpen():Boolean;
	
	//--------------------------------------------------------------------------
	// 
	//  Methods
	// 
	//--------------------------------------------------------------------------
	
	/**
	 * Opens the dialog by default with the <code>PopUpManager</code>.
	 * 
	 * @param owner The owner that this <code>IDialog</code> is being displayed over.
	 * @param modal Whether the <code>IDialog</code> will be opened as a modal
	 * (disallowing userinteraction below it).
	 * @productversion 1.0
	 */
	function open(owner:DisplayObjectContainer, modal:Boolean = false):void;
	
	/**
	 * Closes the dialog by default with the <code>PopUpManager</code>.
	 * 
	 * @param commit Whether to commit the data passed to it from the application 
	 * during <code>open()</code>.
	 * @param data
	 * @productversion 1.0
	 */
	function close(commit:Boolean = false, data:* = undefined):void;
}
}