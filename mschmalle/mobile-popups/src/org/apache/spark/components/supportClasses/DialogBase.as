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

import mx.core.IFactory;
import mx.core.IVisualElement;

import org.apache.spark.components.IDialog;

import spark.components.SkinnablePopUpContainer;
import spark.core.IDisplayText;
import spark.primitives.BitmapImage;

//----------------------------------
//  Styles
//----------------------------------

/**
 * Whether the drop shadow is visible on the dialog.
 */
[Style(name="dropShadowVisible", inherit="no", type="Boolean")]

/**
 * The thickness of the dialog's border.
 */
[Style(name="borderThickness", inherit="no", type="Number")]

/**
 * The dialog's border color.
 */
[Style(name="borderColor", inherit="no", type="uint")]

/**
 * The dialog's border alpha.
 */
[Style(name="borderAlpha", inherit="no", type="Number")]

/**
 * The dialog's background color.
 */
[Style(name="backgroundColor", inherit="no", type="uint")]

/**
 * The dialog's background alpha.
 */
[Style(name="backgroundAlpha", inherit="no", type="Number")]

/**
 * The dialog's border corner radius.
 */
[Style(name="cornerRadius", inherit="no", type="Number")]

/**
 * The dialog's top left corner radius.
 * 
 * <p>This overrides the cornerRadius for the top left.</p>
 */
[Style(name="cornerRadiusTL", inherit="no", type="Number")]

/**
 * The dialog's top right corner radius.
 * 
 * <p>This overrides the cornerRadius for the top right.</p>
 */
[Style(name="cornerRadiusTR", inherit="no", type="Number")]

/**
 * The dialog's bottom left corner radius.
 * 
 * <p>This overrides the cornerRadius for the bottom left.</p>
 */
[Style(name="cornerRadiusBL", inherit="no", type="Number")]

/**
 * The dialog's bottom right corner radius.
 * 
 * <p>This overrides the cornerRadius for the bottom right.</p>
 */
[Style(name="cornerRadiusBR", inherit="no", type="Number")]

//----------------------------------
//  Class
//----------------------------------

/**
 * The base <code>IDialog</code> implementation that holds <code>title</code>, 
 * <code>icon</code> and <code>content</code>.
 * 
 * @productversion 1.0
 * @mxml
 */
public class DialogBase extends SkinnablePopUpContainer implements IDialog
{
	//--------------------------------------------------------------------------
	// 
	//  Public :: SkinParts
	// 
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  titleDisplay
	//----------------------------------
	
	[SkinPart(required="false")]
	
	/**
	 * The skinpart that will display the <code>title</code> text.
	 */
	public var titleDisplay:IDisplayText;
	
	//----------------------------------
	//  iconDisplay
	//----------------------------------
	
	[SkinPart(required="false")]
	
	/**
	 * The skinpart that will display the <code>icon</code> image.
	 */
	public var iconDisplay:BitmapImage;
	
	//--------------------------------------------------------------------------
	// 
	//  Public :: Properties
	// 
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  title
	//----------------------------------
	
	/**
	 * @private
	 */
	private var titleChanged:Boolean = false;
	
	/**
	 * @private
	 */
	private var _title:String;
	
	[Bindable("titleChanged")]
	[Inspectable(category="General", defaultValue="")]
	
	/**
	 * @copy com.teotigraphix.ui.components.IDialog#title
	 */
	public function get title():String
	{
		return _title;
	}
	
	/**
	 * @private
	 */
	public function set title(value:String):void
	{
		if (_title == value)
			return;
		
		_title = value;
		
		titleChanged = true;
		invalidateProperties();
		
		dispatchEvent(new Event("titleChanged"));
	}
	
	//----------------------------------
	//  icon
	//----------------------------------
	
	/**
	 * @private
	 */
	private var iconChanged:Boolean = false;
	
	/**
	 * @private
	 */
	private var _icon:Object;
	
	[Bindable("iconChanged")]
	[Inspectable(category="General", defaultValue="")]
	
	/**
	 * @copy com.teotigraphix.ui.components.IDialog#icon
	 */
	public function get icon():Object
	{
		return _icon;
	}
	
	/**
	 * @private
	 */
	public function set icon(value:Object):void
	{
		if (_icon == value)
			return;
		
		_icon = value;
		
		iconChanged = true;
		invalidateProperties();
		
		dispatchEvent(new Event("iconChanged"));
	}
	
	//----------------------------------
	//  contentRenderer
	//----------------------------------
	
	/**
	 * @private
	 */
	private var contentRendererChanged:Boolean = false;
	
	/**
	 * @private
	 */
	private var _contentRenderer:IFactory;
	
	[Bindable("contentRendererChanged")]
	[Inspectable(category="General", defaultValue="")]
	
	/**
	 * @copy com.teotigraphix.ui.components.IDialog#contentRenderer
	 */
	public function get contentRenderer():IFactory
	{
		return _contentRenderer;
	}
	
	/**
	 * @private
	 */
	public function set contentRenderer(value:IFactory):void
	{
		if (_contentRenderer == value)
			return;
		
		_contentRenderer = value;
		
		contentRendererChanged = true;
		invalidateProperties();
		
		dispatchEvent(new Event("contentRendererChanged"));
	}
	
	//----------------------------------
	//  content
	//----------------------------------
	
	/**
	 * @private
	 */
	private var contentChanged:Boolean = false;
	
	/**
	 * @private
	 */
	private var _content:IVisualElement;
	
	[Bindable("contentChanged")]
	[Inspectable(category="General", defaultValue="")]
	
	/**
	 * @copy com.teotigraphix.ui.components.IDialog#content
	 */
	public function get content():IVisualElement
	{
		if (!contentGroup)
			return null;
		
		return _content;
	}
	
	/**
	 * @private
	 */
	public function set content(value:IVisualElement):void
	{
		if (value == _content)
			return;
		
		_content = value;
		
		contentChanged = true;
		invalidateProperties();
		
		dispatchEvent(new Event("contentChanged"));
	}
		
	//--------------------------------------------------------------------------
	// 
	//  Constructor
	// 
	//--------------------------------------------------------------------------
	
	/**
	 * Constructor.
	 */
	override public function DialogBase()
	{
		super();
	}
	
	//--------------------------------------------------------------------------
	// 
	//  Overridden Protected :: Methods
	// 
	//--------------------------------------------------------------------------
	
	/**
	 * @private 
	 */
	override protected function partAdded(partName:String, instance:Object):void
	{
		super.partAdded(partName, instance);
		
		if (instance == titleDisplay)
		{
			commitTitle();
		}
		
		if (instance == iconDisplay)
		{
			commitIcon();
		}
	}
	
	/**
	 * @private 
	 */
	override protected function partRemoved(partName:String, instance:Object):void
	{
		super.partRemoved(partName, instance);
	}
	
	/**
	 * @private 
	 */
	override protected function commitProperties():void
	{
		super.commitProperties();
		
		if (titleChanged)
		{
			commitTitle();
			titleChanged = false;
		}
		
		if (iconChanged)
		{
			commitIcon();
			iconChanged = false;
		}
		
		if (contentRendererChanged) 
		{
			commitContentRenderer();
			contentRendererChanged = false;
		}
		
		if (contentChanged)
		{
			commitContent();
			contentChanged = false;
		}
	}
	
	//--------------------------------------------------------------------------
	// 
	//  Protected :: Methods
	// 
	//--------------------------------------------------------------------------
	
	/**
	 * Commits the <code>title</code> property.
	 */
	protected function commitTitle():void
	{
		if (titleDisplay)
			titleDisplay.text = title;
	}
	
	/**
	 * Commits the <code>icon</code> property.
	 */
	protected function commitIcon():void
	{
		if (iconDisplay)
			iconDisplay.source = icon;
	}
	
	/**
	 * Commits the <code>contentRenderer</code> property.
	 */
	protected function commitContentRenderer():void
	{
		if (!contentRenderer || content != null)
			return;
		
		content = contentRenderer.newInstance();
	}	
	
	/**
	 * Commits the <code>content</code> property.
	 */
	protected function commitContent():void
	{
		if (!contentGroup)
			return;
		
		contentGroup.removeAllElements();
		contentGroup.addElement(content);
	}
}
}