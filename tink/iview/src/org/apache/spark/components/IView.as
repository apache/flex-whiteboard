package org.apache.spark.components
{
	import mx.core.IDataRenderer;
	import mx.core.IInvalidating;
	import mx.core.ILayoutElement;
	import mx.core.IUIComponent;
	import mx.core.IVisualElement;
	import mx.managers.ILayoutManagerClient;
	
	import spark.components.ViewNavigator;
	import spark.layouts.supportClasses.LayoutBase;
	
	public interface IView extends IUIComponent, IVisualElement, IDataRenderer, IInvalidating, ILayoutElement, ILayoutManagerClient
	{
		function get destructionPolicy():String
		function set destructionPolicy(value:String):void
			
			
		/**
		 *  Specifies whether a view should show the tab bar or not.
		 *  This property does not necessarily correlate to the 
		 *  <code>visible</code> property of the navigator's TabBar control. 
		 *
		 *  @default true
		 * 
		 *  @langversion 3.0
		 *  @playerversion AIR 2.5
		 *  @productversion Flex 4.5
		 */
		function get tabBarVisible():Boolean
		/**
		 *  @private
		 */
		function set tabBarVisible(value:Boolean):void
			
			
		/**
		 *  Specifies whether a view should show the action bar or not.
		 *  This property does not necessarily correlate to the 
		 *  <code>visible</code> property of the view navigator's ActionBar control. 
		 *
		 *  @default true
		 * 
		 *  @langversion 3.0
		 *  @playerversion AIR 2.5
		 *  @productversion Flex 4.5
		 */
		function get actionBarVisible():Boolean
		/**
		 *  @private
		 */ 
		function set actionBarVisible(value:Boolean):void
			
			
		/**
		 *  By default, the TabBar and ActionBar controls of a 
		 *  mobile application define an area that cannot be used 
		 *  by the views of an application. 
		 *  That means your content cannot use the full screen size 
		 *  of the mobile device.
		 *  If you set this property to <code>true</code>, the content area 
		 *  of the application spans the entire width and height of the screen. 
		 *  The ActionBar and TabBar controls hover over the content area with 
		 *  an <code>alpha</code> value of 0.5 so that they are partially transparent. 
		 *  
		 *  @default false
		 * 
		 *  @langversion 3.0
		 *  @playerversion AIR 2.5
		 *  @productversion Flex 4.5
		 */
		function get overlayControls():Boolean
		/**
		 *  @private
		 */
		function set overlayControls(value:Boolean):void
			
			
		/**
		 *  This property overrides the <code>actionContent</code>
		 *  property in the ActionBar, ViewNavigator, and 
		 *  ViewNavigatorApplication components.
		 * 
		 *  @copy ActionBar#actionContent
		 *
		 *  @default null
		 *
		 *  @see ActionBar#actionContent
		 *  @see spark.skins.mobile.ActionBarSkin
		 *  
		 *  @langversion 3.0
		 *  @playerversion AIR 2.5
		 *  @productversion Flex 4.5
		 */
		function get actionContent():Array
		/**
		 *  @private
		 */
		function set actionContent(value:Array):void
		
			
		/**
		 *  @copy ActionBar#actionLayout
		 *
		 *  @default null
		 *  
		 *  @langversion 3.0
		 *  @playerversion AIR 2.5
		 *  @productversion Flex 4.5
		 */
		function get actionLayout():LayoutBase
		/**
		 *  @private
		 */
		function set actionLayout(value:LayoutBase):void
			
		
		/**
		 *  This property overrides the <code>navigationContent</code>
		 *  property in the ActionBar, ViewNavigator, and 
		 *  ViewNavigatorApplication components.
		 * 
		 *  @copy ActionBar#navigationContent
		 *
		 *  @default null
		 * 
		 *  @see ActionBar#navigationContent
		 *  @see spark.skins.mobile.ActionBarSkin
		 *  
		 *  @langversion 3.0
		 *  @playerversion AIR 2.5
		 *  @productversion Flex 4.5
		 */
		function get navigationContent():Array
		/**
		 *  @private
		 */
		function set navigationContent(value:Array):void
			
			
		/**
		 *  @copy ActionBar#navigationLayout
		 *
		 *  @default null
		 *  
		 *  @langversion 3.0
		 *  @playerversion AIR 2.5
		 *  @productversion Flex 4.5
		 */
		function get navigationLayout():LayoutBase
		/**
		 *  @private
		 */
		function set navigationLayout(value:LayoutBase):void
			
			
		/**
		 *  This property overrides the <code>title</code>
		 *  property in the ActionBar, ViewNavigator, and 
		 *  ViewNavigatorApplication components.
		 * 
		 *  @copy ActionBar#title
		 *
		 *  @default ""
		 *  
		 *  @langversion 3.0
		 *  @playerversion AIR 2.5
		 *  @productversion Flex 4.5
		 */ 
		function get title():String
		/**
		 *  @private
		 */ 
		function set title(value:String):void
		
		
		/**
		 *  This property overrides the <code>titleContent</code>
		 *  property in the ActionBar, ViewNavigator, and 
		 *  ViewNavigatorApplication components.
		 * 
		 *  @copy ActionBar#titleContent
		 *
		 *  @default null
		 * 
		 *  @see ActionBar#titleContent
		 *  @see spark.skins.mobile.ActionBarSkin
		 *  
		 *  @langversion 3.0
		 *  @playerversion AIR 2.5
		 *  @productversion Flex 4.5
		 */
		function get titleContent():Array
		/**
		 *  @private
		 */
		function set titleContent(value:Array):void
		
		
		/**
		 *  @copy ActionBar#titleLayout
		 *
		 *  @default null
		 *  
		 *  @langversion 3.0
		 *  @playerversion AIR 2.5
		 *  @productversion Flex 4.5
		 */
		function get titleLayout():LayoutBase
		/**
		 *  @private
		 */
		function set titleLayout(value:LayoutBase):void
			
			
		/**
		 *  @private
		 */ 
		function backKeyHandledByView():Boolean
			
		
		/**
		 *  @private
		 *  Determines if the current view can be removed by a navigator.  The default 
		 *  implementation dispatches a <code>FlexEvent.REMOVING</code> event.  If
		 *  preventDefault() is called on the event, this property will return false.
		 * 
		 *  @return Returns true if the view can be removed
		 *  
		 *  @langversion 3.0
		 *  @playerversion AIR 2.5
		 *  @productversion Flex 4.5
		 */    
		function canRemove():Boolean
			
			
		/**
		 *  @private
		 *  Method called by parent navigator to update the actionBarVisible
		 *  flag as a result of the showActionBar() or hideActionBar() methods.
		 */ 
		function setActionBarVisible(value:Boolean):void
			
			
		/**
		 *  Indicates whether the current view is active.  
		 *  The view's navigator  automatically sets this flag to <code>true</code> 
		 *  or <code>false</code> as its state changes.  
		 *  Setting this property can dispatch the <code>viewActivate</code> or 
		 *  <code>viewDeactivate</code> events. 
		 *  
		 *  @default false
		 * 
		 *  @langversion 3.0
		 *  @playerversion AIR 2.5
		 *  @productversion Flex 4.5
		 */
		function get isActive():Boolean
		/**
		 * @private
		 */
		function setActive(value:Boolean):void
			
			
		/**
		 *  Set the current state.
		 *
		 *  @param stateName The name of the new view state.
		 *
		 *  @param playTransition If <code>true</code>, play
		 *  the appropriate transition when the view state changes.
		 *
		 *  @see #currentState
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		function setCurrentState(stateName:String, playTransition:Boolean = true):void
			
			
		/**
		 *  Deserializes a data object that was saved to disk by the view,
		 *  typically by a call to the <code>serializeData()</code> method.  
		 *
		 *  @param value The data object to deserialize.
		 *  
		 *  @return The value assigned to the 
		 *  view's <code>data</code> property.
		 *
		 * 
		 *  @langversion 3.0
		 *  @playerversion AIR 2.5
		 *  @productversion Flex 4.5
		 */
		function deserializeData(value:Object):Object
			
		
		/**
		 *  @private
		 */ 
		function setNavigator(value:org.apache.spark.components.ViewNavigator):void
			
			
		/**
		 *  Creates an object returned to the view navigator
		 *  when this view is popped off the navigator's stack.
		 *
		 *  <p>Override this method in a View to return data back the new 
		 *  view when this view is popped off the stack. 
		 *  The <code>createReturnObject()</code> method returns a single Object.
		 *  The Object returned by this method is written to the 
		 *  <code>ViewNavigator.poppedViewReturnedObject</code> property. </p>
		 *
		 *  <p>The <code>ViewNavigator.poppedViewReturnedObject</code> property
		 *  is of type ViewReturnObject.
		 *  The <code>ViewReturnObject.object</code> property contains the 
		 *  value returned by this method. </p>
		 *
		 *  <p>If the <code>poppedViewReturnedObject</code> property is null, 
		 *  no data was returned. 
		 *  The <code>poppedViewReturnedObject</code> property is guaranteed to be set 
		 *  in the new view before the new view receives the <code>add</code> event.</p>
		 * 
		 *  @return The value written to the <code>object</code> field of the 
		 *  <code>ViewNavigator.poppedViewReturnedObject</code> property.  
		 *
		 *  @see ViewNavigator#poppedViewReturnedObject
		 *  @see spark.components.supportClasses.ViewReturnObject
		 * 
		 *  @langversion 3.0
		 *  @playerversion AIR 2.5
		 *  @productversion Flex 4.5
		 */
		function createReturnObject():Object
			
			
		/**
		 *  Responsible for serializes the view's <code>data</code> property 
		 *  when the view is being persisted to disk.  
		 *  The returned object should be something that can
		 *  be successfully written to a shared object.  
		 *  By default, this method returns the <code>data</code> property
		 *  of the view.
		 * 
		 *  @return The serialized data object.
		 * 
		 *  @langversion 3.0
		 *  @playerversion AIR 2.5
		 *  @productversion Flex 4.5
		 */
		function serializeData():Object
			
			
		/**
		 *  Checks the aspect ratio of the stage and returns the proper state
		 *  that the View should change to.  
		 * 
		 *  @return A String specifying the name of the state to apply to the view. 
		 *  The possible return values are <code>"portrait"</code>
		 *  or <code>"landscape"</code>.  
		 *  The state is only changed if the desired state exists
		 *  on the View. 
		 *  If it does not, this method returns the component's current state.
		 *  
		 *  @langversion 3.0
		 *  @playerversion AIR 2.5
		 *  @productversion Flex 4.5
		 */
		function getCurrentViewState():String
	}
}