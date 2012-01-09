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

import flash.display.DisplayObjectContainer;
import flash.events.Event;
import flash.events.TimerEvent;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.utils.Timer;

import mx.core.EdgeMetrics;
import mx.core.FlexGlobals;
import mx.core.IFactory;
import mx.core.IMXMLObject;
import mx.core.IVisualElement;
import mx.core.UIComponent;
import mx.managers.ISystemManager;

import org.apache.spark.components.supportClasses.PopUpLayoutPlacement;
import org.apache.spark.events.DialogEvent;
import org.apache.spark.utils.PopUpLayoutUtils;

import spark.core.IDisplayText;

//----------------------------------
//  Events
//----------------------------------

/**
 * Dispatched when the IDialog is opened.
 */
[Event(name="dialogOpen", type="org.apache.spark.events.DialogEvent")]

/**
 * Dispatched when the IDialog is closed.
 */
[Event(name="dialogClose", type="org.apache.spark.events.DialogEvent")]

//----------------------------------
//  Class
//----------------------------------

/**
 * A PopUp is a user interface wrapper for creating IDialog and other popups
 * seamlessly.
 * 
 * <p>The <code>PopUp</code> class helps you <em>create</em> and <em>show</em> 
 * message views and dialogs.</p>
 * 
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 * @see PopUp#show()
 * @see PopUp#makeText()
 * @see PopUp#makeContent()
 * @see PopUp#makeDialog()
 * @see PopUp#makeAlert()
 * @see PopUp#makeMessageAlert()
 */
public class PopUp implements IMXMLObject
{
	//--------------------------------------------------------------------------
	//
	//  Public :: Constants
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Show the <strong>view</strong> or <strong>text</strong> notification for 
	 * a long period of time (<em>4 seconds</em>).
	 * 
	 * @default 2000
	 */
	public static const LENGTH_SHORT:int = 2000;
	
	/**
	 * Show the <strong>view</strong> or <strong>text</strong> notification for 
	 * a short period of time (<em>2 seconds</em>).
	 * 
	 * @default 4000
	 */
	public static const LENGTH_LONG:int = 4000;
	
	/**
	 * Show the popup for an indefinite amount of time.
	 */
	public static const LENGTH_NONE:int = 0;
	
	//--------------------------------------------------------------------------
	//
	//  Private :: Variables
	//
	//--------------------------------------------------------------------------
	
	/**
	 * @private 
	 */
	private var mTimer:Timer;
	
	/**
	 * @private 
	 */
	private var mOwner:DisplayObjectContainer;
	
	//--------------------------------------------------------------------------
	//
	//  Public :: Properties
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  modal
	//----------------------------------
	
	/**
	 * @private
	 */
	private var _modal:Boolean = false;
	
	/**
	 * Whether the dialog being popped up will stop underlying screen interaction.
	 */
	public function get modal():Boolean
	{
		return _modal;
	}
	
	/**
	 * @private
	 */
	public function set modal(value:Boolean):void
	{
		_modal = value;
	}
	
	//----------------------------------
	//  duration
	//----------------------------------
	
	/**
	 * @private
	 */
	private var _duration:int = LENGTH_SHORT;
	
	/**
	 * The length of time in milliseconds the notification is shown, the
	 * default is <code>LENGTH_SHORT</code>.
	 * 
	 * @default LENGTH_SHORT
	 */
	public function get duration():int
	{
		return _duration;
	}
	
	/**
	 * @private
	 */
	public function set duration(value:int):void
	{
		_duration = Math.max(LENGTH_NONE, value);
	}
	
	//----------------------------------
	//  contentRenderer
	//----------------------------------
	
	/**
	 * @private
	 */
	private var _contentRenderer:IFactory;
	
	/**
	 * The content renderer <code>IFactory</code> that can deffer creation until 
	 * a later time.
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
		_contentRenderer = value;
	}
	
	//----------------------------------
	//  content
	//----------------------------------
	
	/**
	 * @private
	 */
	private var _content:IVisualElement;
	
	/**
	 * The <code>IVisualElement</code> instance used as the view for the notification.
	 * asdasdasdasd
	 */
	public function get content():IVisualElement
	{
		return _content;
	}
	
	/**
	 * @private
	 */
	public function set content(value:IVisualElement):void
	{
		_content = value;
	}
	
	//----------------------------------
	//  dialog
	//----------------------------------
	
	/**
	 * @private 
	 */
	private var _dialog:IDialog;
	
	/**
	 * Returns the <code>IDialog</code> currently being managed by this 
	 * <code>PopUp</code>.
	 */
	public function get dialog():IDialog 
	{
		return _dialog;
	}
	
	/**
	 * @private 
	 */
	public function set dialog(value:IDialog):void
	{
		setDialog(value);
	}
	
	/**
	 * @private 
	 */
	protected function setDialog(value:IDialog):void
	{
		_dialog = value;
	}
	
	//----------------------------------
	//  text
	//----------------------------------
	
	/**
	 * @private
	 */
	private var _text:String;
	
	/**
	 * The <code>String</code> text used for the notification.
	 * @see #makeText()
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
		_text = value;
	}
	
	//----------------------------------
	//  layoutPlacement
	//----------------------------------
	
	/**
	 * @private
	 */
	private var _layoutPlacement:String = PopUpLayoutPlacement.CENTER;
	
	/**
	 * The layout placement of the notification.
	 * 
	 * @see org.apache.spark.components.supportClasses.PopUpLayoutPlacement
	 */
	public function get layoutPlacement():String
	{
		return _layoutPlacement;
	}
	
	/**
	 * @private
	 */
	public function set layoutPlacement(value:String):void
	{
		if (!PopUpLayoutPlacement.isValid(value))
			return;
		
		_layoutPlacement = value;
	}
	
	//----------------------------------
	//  layoutOffset
	//----------------------------------
	
	/**
	 * @private
	 */
	private var _layoutOffset:Point = new Point();
	
	/**
	 * The layout offset (<code>x</code> and <code>y</code>) of 
	 * the notification.
	 */
	public function get layoutOffset():Point
	{
		return _layoutOffset;
	}
	
	/**
	 * @private
	 */
	public function set layoutOffset(value:Point):void
	{
		_layoutOffset = value;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Constructor.
	 */
	public function PopUp()
	{
	}
	
	//--------------------------------------------------------------------------
	//
	//  Public :: Methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Shows the <code>PopUp</code> notification on the <code>owner</code>.
	 * 
	 * <p>If the <code>content</code> property has not been set, the method 
	 * will use the <code>contentRenderer</code> factory to create the 
	 * content.</p>
	 * 
	 * <pre>
	 * var popup:PopUp = new PopUp();
	 * popup.duration = PopUp.LENGTH_LONG;
	 * popup.text = "Hello PopUp!";
	 * popup.show(this);
	 * </pre>
	 * 
	 * @param owner The <code>DisplayObjectContianer</code> that will host the notification. 
	 * Note that the PopUpManager uses this reference and the bounds of the owner will be used 
	 * for positioning.
	 * @param modal A Boolean indicating whether the PopUp blocks background activity.
	 * @throws Error content or contentRenderer must be defined in PopUp
	 */
	public function show(owner:DisplayObjectContainer = null, modal:Boolean = false):void
	{
		mOwner = owner;
		
		if (mOwner == null)
			mOwner = DisplayObjectContainer(FlexGlobals.topLevelApplication);
		
		var instance:IDialog = dialog;
		// create the dialog that will hold the content
		if (!instance)
		{
			instance = new TextDialog();
			setDialog(instance);
		}
		
		content = createContent();
		configureContent(content);
		configureDialog(instance);
		
		addDialogHandlers(instance);
		
		startTimer();
		
		openDialog(instance, mOwner, modal);		
		layoutDialog(instance, mOwner);
	}
	
	/**
	 * @private 
	 */
	protected function startTimer():void
	{
		if (duration != LENGTH_NONE)
		{
			// create the timer
			mTimer = new Timer(duration, 1);
			mTimer.addEventListener(TimerEvent.TIMER_COMPLETE, timer_timeCompleteHandler);
			mTimer.start();
		}
	}
	
	/**
	 * Creates the <code>content</code> if the <code>content</code>
	 * is undefined.
	 */
	protected function createContent():IVisualElement
	{
		var instance:IVisualElement = content;
		
		// - contentRenderer is null until a user sets it on this instance
		// - if the user sets it that means it overrides the dialog.contentRenderer
		// AND it overriddes the content of the dialog
		// if the content is set on the PopUp, that instance overrides everything
		if (contentRenderer != null)
			instance = contentRenderer.newInstance() as IVisualElement;
		
		return instance;
	}
	
	/**
	 * Configures the dialog's content component.
	 */
	protected function configureContent(content:IVisualElement):void
	{

	}
	
	/**
	 * Configures the popup's dialog.
	 * 
	 * @param dialog The dialog to configure.
	 */
	protected function configureDialog(dialog:IDialog):void
	{
		// if content was set on this instance, it will override content
		// already set on the dialog
		if (content != null)
			dialog.content = content;
		
		if (dialog is IDisplayText)
			IDisplayText(dialog).text = text;
	}
	
	/**
	 * Opens the popup's dialog.
	 * 
	 * @param dialog The dialog to open.
	 * @param owner The display object owner of the dialog.
	 * @param isModal Whether to dialog will be opened as a modal or non modal popup.
	 */
	protected function openDialog(dialog:IDialog, owner:DisplayObjectContainer, isModal:Boolean):void
	{
		// dimensions are not available until open() is called
		dialog.open(owner, (modal) ? true : isModal);
	}
	
	/**
	 * Lays out the dialog, uses LayoutUtils and alyoutPlacement to determine 
	 * the position of the popup.
	 * 
	 * @param dialog The dialog being layed out.
	 * @param owner The display object owner of the dialog.
	 */
	protected function layoutDialog(dialog:IDialog, owner:DisplayObjectContainer):void
	{
		// the top and left need to be converted to owner coords, usually this is Stage
		var parent:DisplayObjectContainer = owner.parent;
		var edges:EdgeMetrics = new EdgeMetrics(layoutOffset.x, layoutOffset.y, layoutOffset.x, layoutOffset.y);
		
		// to be able to center on the owner, the owners coords have to be
		// converted to gloabl stage coords AND the edges
		var point:Point = owner.parent.localToGlobal(new Point(owner.x, owner.y));
		var rect:Rectangle = new Rectangle(point.x, point.y, owner.width, owner.height);
		
		PopUpLayoutUtils.layoutElement2(dialog, layoutPlacement, rect, edges);
	}
	
	/**
	 * @private 
	 */
	protected function addDialogHandlers(dialog:IDialog):void
	{
		dialog.addEventListener(Event.REMOVED_FROM_STAGE, removedFromStageHandler);
		dialog.addEventListener(DialogEvent.DIALOG_CLOSE, dialogCloseHandler, false, 0, false);
		// StageOrientationEvent.ORIENTATION_CHANGE
		systemManager.getSandboxRoot().stage.addEventListener(
			"orientationChange", stage_orientationChangeHandler, true);
	}
	
	/**
	 * @private 
	 */
	protected function removedFromStageHandler(event:Event):void
	{
		removeDialogHandlers(IDialog(event.currentTarget));
	}
	
	/**
	 * @private 
	 */
	protected function removeDialogHandlers(dialog:IDialog):void
	{
		dialog.removeEventListener(Event.REMOVED_FROM_STAGE, removedFromStageHandler);
		dialog.removeEventListener(DialogEvent.DIALOG_CLOSE, dialogCloseHandler);
		// StageOrientationEvent.ORIENTATION_CHANGE
		systemManager.getSandboxRoot().stage.removeEventListener(
			"orientationChange", stage_orientationChangeHandler, true);
	}
	
	/**
	 * @private 
	 */
	protected function dialogCloseHandler(event:DialogEvent):void
	{
		removeDialogHandlers(IDialog(event.currentTarget));
		
		close();
	}
	
	/**
	 * @private 
	 */
	public function initialized(document:Object, id:String):void
	{
	}
	
	/**
	 * Cancels or <em>closes</em> the <code>PopUp</code> notification.
	 * 
	 * <pre>popup.cancel();</pre>
	 */
	public function close():void
	{
		if (!dialog) // this dosn't feel right
			return;
		
		dialog.close();
		setDialog(null);
	}
	
	//--------------------------------------------------------------------------
	//
	//  Public Class :: Properties
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Creates a <code>PopUp</code> notification using the default 
	 * <code>PopUpTextView</code> or the <code>contentRenderer</code> if defined.
	 * 
	 * <pre>PopUp.makeText("Hello World", PopUp.LENGTH_LONG).show();</pre>
	 * 
	 * @param text The <code>String</code> text that will appear in the notification.
	 * @param duration The time in milliseconds to show the notification.
	 * @return A new <code>PopUp</code> notification, Note; the <code>show()</code> 
	 * method still needs be called.
	 * @see com.teotigraphix.ui.components.TextDialog
	 * @productversion 1.0
	 */
	public static function makeText(text:String, duration:int):PopUp
	{
		var instance:PopUp = new PopUp();
		instance.setDialog(new TextDialog());
		instance.duration = duration;
		instance.text = text;
		return instance;
	}
	
	/**
	 * Creates a <code>PopUp</code> notification using the default 
	 * <code>content</code> or the <code>contentRenderer</code> if defined for
	 * the actual view.
	 * 
	 * <pre>
	 * [Embed(source="assets/icons/android.png")]
	 * private var iconClass:Class;
	 * 
	 * protected function makeContentButton_clickHandler(event:MouseEvent):void
	 * {
	 * 	var content:IconLabelRenderer = new IconLabelRenderer();
	 * 	content.icon = iconClass;
	 * 	content.text = "Hello makeContent()!";
	 * 	PopUp.makeContent(content, PopUp.LENGTH_SHORT).show(this);
	 * }</pre>
	 * 
	 * @param content The <code>IVisualElement</code> to display as the 
	 * notifications view.
	 * @param duration The time in milliseconds to show the notification.
	 * @return A new <code>PopUp</code> notification, Note; the <code>show()</code> 
	 * method still needs be called.
	 * @see com.teotigraphix.ui.components.Dialog
	 * @productversion 1.0
	 */
	public static function makeContent(content:IVisualElement, duration:int):PopUp
	{
		/*
		var instance:PopUp = new PopUp();
		instance.duration = duration;
		
		var dialog:Dialog = new Dialog();
		dialog.content = content;
		instance.setDialog(dialog);

		return instance;
		*/
		return null;
	}
	
	/**
	 * Creates a <code>PopUp</code> notification using the default 
	 * <code>Dialog</code>.
	 * 
	 * The <code>contentRenderer</code>, <code>title</code> and <code>icon</code> 
	 * are set on the new <code>IDialog</code> instance.
	 * 
	 * <pre>
	 * protected function makeDialog_clickHandler(event:MouseEvent):void
	 * {
	 * 	PopUp.makeDialog(new ClassFactory(DeclartiveDialog), "Hello Dialog!", titleIconClass).show();
	 * }</pre>
	 * 
	 * @param contentRenderer The <code>IFactory</code> used to create the 
	 * <code>IDialog#content</code>.
	 * @param title The <code>String</code> title set on the <code>IDialog</code>.
	 * @param icon The visual icon set in the <code>IDialog</code> <code>titleBar</code>.
	 * @return A new <code>PopUp</code> notification, note; the <code>show()</code> 
	 * method still needs be called.
	 * @productversion 1.0
	 */
	public static function makeDialog(contentRenderer:IFactory, 
									  title:String = null, 
									  icon:Object = null):PopUp
	{
		/*
		var instance:PopUp = new PopUp();
		instance.duration = LENGTH_NONE;
		
		var dialog:Dialog = new Dialog();
		dialog.contentRenderer = contentRenderer;
		dialog.title = title;
		dialog.icon = icon;
		instance.setDialog(dialog);
		
		return instance;
		*/
		return null;
	}
	
	/**
	 * Creates a <code>PopUp</code> <strong>modal</strong> <code>IDialog</code> 
	 * using the default <code>AlertDialog</code>.
	 * 
	 * <p>The <code>AlertDialog</code> will be populated with the 
	 * <code>title</code>, <code>icon</code>, <code>message</code> and 
	 * <code>messageIcon</code>. The Alert dialog by default will use 
	 * the <strong>OK</strong> and <strong>Cancel</strong> buttons 
	 * for dismissal.</p>
	 * 
	 * <p>This method also uses the <code>TextIconView</code> for it's 
	 * content renderer. To style the content target the <code>tg|TextIconView</code> 
	 * type selector.</p>
	 * 
	 * <p>The <code>PopUp.modal</code> property is set to true to 
	 * disallow any user interaction below the <code>AlertDialog</code>.</p>
	 * 
	 * [Embed(source="assets/common/android_normal.png")]
	 * private var iconClass:Class;
	 * 
	 * <pre>
	 * [Embed(source="assets/common/emblem-important-160.png")]
	 * private var titleIconClass:Class;
	 * 
	 * protected function makeAlert_clickHandler(event:MouseEvent):void
	 * {
	 * 	PopUp.makeAlert("Hello AlertDialog!", titleIconClass, 
	 * 		"The alert message", iconClass).show();
	 * }
	 * </pre>
	 * 
	 * @param title The <code>String</code> title set on the <code>IDialog</code>.
	 * @param icon The visual icon set in the <code>IDialog</code> <code>titleBar</code>.
	 * @param message The <code>String</code> message set on the <code>IDialog</code>.
	 * @param messageIcon The visual icon set in the <code>IDialog</code> <code>content</code>.
	 * @see com.teotigraphix.ui.components.supportClasses.TextIconView
	 * @productversion 1.0
	 */
	public static function makeAlert(title:String, 
									 icon:Object = null, 
									 message:String = null, 
									 messageIcon:Object = null):PopUp
	{
		/*
		var instance:PopUp = new PopUp();
		instance.duration = LENGTH_NONE;
		instance.modal = true;
		
		var dialog:AlertDialog = new AlertDialog();
		dialog.title = title;
		dialog.icon = icon;
		dialog.message = message;
		dialog.messageIcon = messageIcon;
		dialog.contentRenderer = new ClassFactory(TextIconView);
		instance.setDialog(dialog);
		
		return instance;
		*/
		return null;
	}
	
	/**
	 * Creates a <code>PopUp</code> message alert using the default 
	 * <code>AlertDialog</code>.
	 * 
	 * <p>The message alert dialog has no <code>titleBar</code>, just an 
	 * <code>icon</code> and <code>message</code>.</p>
	 * 
	 * <pre>
	 * [Embed(source="assets/common/android_normal.png")]
	 * private var iconClass:Class;
	 * 
	 * protected function makeMessageAlert_clickHandler(event:MouseEvent):void
	 * {
	 * 	PopUp.makeMessageAlert("The alert message without\n" +
	 * 		"the titlebar", iconClass).show();
	 * }</pre>
	 * 
	 * @param message The <code>String</code> message for the dialog.
	 * @param messageIcon The <code>Object</code> used for the <code>content</code>'s icon.
	 * @see com.teotigraphix.ui.components.supportClasses.TextIconView
	 * @productversion 1.0
	 */
	public static function makeMessageAlert(message:String, messageIcon:Object = null):PopUp
	{
		/*
		var instance:PopUp = new PopUp();
		instance.duration = LENGTH_NONE;
		
		var dialog:AlertDialog = new AlertDialog();
		dialog.message = message;
		dialog.messageIcon = messageIcon;
		dialog.contentRenderer = new ClassFactory(TextIconView);
		
		instance.setDialog(dialog);
		return instance;
		*/
		return null;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Protected :: Handlers
	//
	//--------------------------------------------------------------------------
	
	/**
	 * @private 
	 */
	protected function timer_timeCompleteHandler(event:TimerEvent):void
	{
		mTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, timer_timeCompleteHandler);
		mTimer = null;
		
		close();
	}
	
	//--------------------------------------------------------------------------
	//
	//  Stage :: Handlers
	//
	//--------------------------------------------------------------------------
	
	/**
	 * @private  [StageOrientationEvent]
	 */
	protected function stage_orientationChangeHandler(event:Event):void
	{
		UIComponent(topLevelApplication).callLater(layoutDialog, [dialog, mOwner]);
	}
	
	//--------------------------------------------------------------------------
	//
	//  Private :: Properties
	//
	//--------------------------------------------------------------------------
	
	/**
	 * @private 
	 */
	private static function get topLevelApplication():DisplayObjectContainer
	{
		return DisplayObjectContainer(FlexGlobals.topLevelApplication);
	}
	
	/**
	 * @private 
	 */
	private static function get systemManager():ISystemManager
	{
		return FlexGlobals.topLevelApplication.systemManager;
	}
}
}