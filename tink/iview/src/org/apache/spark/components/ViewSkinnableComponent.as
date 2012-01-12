package org.apache.spark.components
{
	import flash.events.Event;
	
	import mx.core.FlexGlobals;
	import mx.core.IDataRenderer;
	import mx.core.mx_internal;
	import mx.events.FlexEvent;
	import mx.events.PropertyChangeEvent;
	
	import spark.components.Group;
	import spark.components.supportClasses.SkinnableComponent;
	import spark.core.ContainerDestructionPolicy;
	import spark.events.ViewNavigatorEvent;
	import spark.layouts.supportClasses.LayoutBase;
	
	use namespace mx_internal;
	
	public class ViewSkinnableComponent extends SkinnableComponent implements IView, IDataRenderer
	{
		public function ViewSkinnableComponent()
		{
			super();
		}
		
		//----------------------------------
		//  navigator
		//----------------------------------
		
		private var _navigator:ViewNavigator = null;
		
		/**
		 * The view navigator that this view resides in.
		 * 
		 *  @langversion 3.0
		 *  @playerversion AIR 2.5
		 *  @productversion Flex 4.5
		 */
		
		[Bindable("navigatorChanged")]
		public function get navigator():ViewNavigator
		{
			return _navigator;
		}
		
		//----------------------------------
		//  destructionPolicy
		//----------------------------------
		
		private var _destructionPolicy:String = ContainerDestructionPolicy.AUTO;
		
		[Inspectable(category="General", enumeration="auto,never", defaultValue="auto")]
		/**
		 *  Defines the destruction policy the view's navigator should use
		 *  when this view is removed. If set to "auto", the navigator will
		 *  destroy the view when it isn't active.  If set to "never", the
		 *  view will be cached in memory.
		 * 
		 *  @default auto
		 * 
		 *  @langversion 3.0
		 *  @playerversion AIR 2.5
		 *  @productversion Flex 4.5
		 */
		public function get destructionPolicy():String
		{
			return _destructionPolicy;
		}
		
		/**
		 *  @private
		 */
		public function set destructionPolicy(value:String):void
		{
			_destructionPolicy = value;    
		}
		
		//----------------------------------
		//  tabBarVisible
		//----------------------------------
		private var _tabBarVisible:Boolean = true;
		
		[Inspectable(category="General", defaultValue="true")]
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
		public function get tabBarVisible():Boolean
		{
			return _tabBarVisible;
		}
		
		/**
		 *  @private
		 */
		public function set tabBarVisible(value:Boolean):void
		{
			var oldValue:Boolean = _tabBarVisible;
			_tabBarVisible = value;
			
			// Immediately request actionBar's visibility be toggled
			if (isActive && navigator)
			{
				if (hasEventListener(PropertyChangeEvent.PROPERTY_CHANGE))
				{
					var changeEvent:PropertyChangeEvent = 
						PropertyChangeEvent.createUpdateEvent(this, "tabBarVisible", oldValue, value);
					
					dispatchEvent(changeEvent);
				}
			}
		}
		
		//----------------------------------
		//  actionBarVisible
		//----------------------------------
		private var _actionBarVisible:Boolean = true;
		
		[Inspectable(category="General", defaultValue="true")]
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
		public function get actionBarVisible():Boolean
		{
			return _actionBarVisible;
		}
		
		/**
		 *  @private
		 */ 
		public function set actionBarVisible(value:Boolean):void
		{
			_actionBarVisible = value;
			
			// Immediately request actionBar's visibility be toggled
			if (isActive && navigator)
			{
				if (_actionBarVisible)
					navigator.showActionBar();
				else
					navigator.hideActionBar();
			}
		}
		
		//----------------------------------
		//  overlayControls
		//----------------------------------
		
		private var _overlayControls:Boolean = false;
		
		[Inspectable(category="General", defaultValue="false")]
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
		public function get overlayControls():Boolean
		{
			return _overlayControls;
		}
		
		/**
		 *  @private
		 */
		public function set overlayControls(value:Boolean):void
		{
			if (_overlayControls != value)
			{
				var oldValue:Boolean = _overlayControls;
				_overlayControls = value;
				
				if (hasEventListener(PropertyChangeEvent.PROPERTY_CHANGE))
				{
					var changeEvent:PropertyChangeEvent = 
						PropertyChangeEvent.createUpdateEvent(this, "overlayControls", oldValue, _overlayControls);
					
					dispatchEvent(changeEvent);
				}
			}
		}
		
		//----------------------------------
		//  actionContent
		//----------------------------------
		
		private var _actionContent:Array;
		
		[ArrayElementType("mx.core.IVisualElement")]
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
		public function get actionContent():Array
		{
			return _actionContent;
		}
		/**
		 *  @private
		 */
		public function set actionContent(value:Array):void
		{
			var oldValue:Array = _actionContent;
			_actionContent = value;
			
			if (hasEventListener(PropertyChangeEvent.PROPERTY_CHANGE))
			{
				var changeEvent:PropertyChangeEvent = 
					PropertyChangeEvent.createUpdateEvent(this, "actionContent", oldValue, _actionContent);
				
				dispatchEvent(changeEvent);
			}
		}
		
		//----------------------------------
		//  actionLayout
		//----------------------------------
		
		private var _actionLayout:LayoutBase;
		
		/**
		 *  @copy ActionBar#actionLayout
		 *
		 *  @default null
		 *  
		 *  @langversion 3.0
		 *  @playerversion AIR 2.5
		 *  @productversion Flex 4.5
		 */
		public function get actionLayout():LayoutBase
		{
			return _actionLayout;
		}
		/**
		 *  @private
		 */
		public function set actionLayout(value:LayoutBase):void
		{
			var oldValue:LayoutBase = value;
			_actionLayout = value;
			
			if (hasEventListener(PropertyChangeEvent.PROPERTY_CHANGE))
			{
				var changeEvent:PropertyChangeEvent = 
					PropertyChangeEvent.createUpdateEvent(this, "actionLayout", oldValue, _actionLayout);
				
				dispatchEvent(changeEvent);
			}
		}
		
		//----------------------------------
		//  navigationContent
		//----------------------------------
		
		private var _navigationContent:Array;
		
		[ArrayElementType("mx.core.IVisualElement")]
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
		public function get navigationContent():Array
		{
			return _navigationContent;
		}
		/**
		 *  @private
		 */
		public function set navigationContent(value:Array):void
		{
			var oldValue:Array = _navigationContent;
			_navigationContent = value;
			
			if (hasEventListener(PropertyChangeEvent.PROPERTY_CHANGE))
			{
				var changeEvent:PropertyChangeEvent = 
					PropertyChangeEvent.createUpdateEvent(this, "navigationContent", oldValue, _navigationContent);
				
				dispatchEvent(changeEvent);
			}
		}
		
		//----------------------------------
		//  navigationLayout
		//----------------------------------
		
		private var _navigationLayout:LayoutBase;
		
		/**
		 *  @copy ActionBar#navigationLayout
		 *
		 *  @default null
		 *  
		 *  @langversion 3.0
		 *  @playerversion AIR 2.5
		 *  @productversion Flex 4.5
		 */
		public function get navigationLayout():LayoutBase
		{
			return _navigationLayout;
		}
		/**
		 *  @private
		 */
		public function set navigationLayout(value:LayoutBase):void
		{
			var oldValue:LayoutBase = _navigationLayout;
			_navigationLayout = value;
			
			if (hasEventListener(PropertyChangeEvent.PROPERTY_CHANGE))
			{
				var changeEvent:PropertyChangeEvent = 
					PropertyChangeEvent.createUpdateEvent(this, "navigationLayout", _navigationLayout, value);
				
				dispatchEvent(changeEvent);
			}
		}
		
		//----------------------------------
		//  title
		//----------------------------------
		
		private var _title:String;
		
		[Bindable]
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
		public function get title():String
		{
			return _title;
		}
		/**
		 *  @private
		 */ 
		public function set title(value:String):void
		{
			if (_title != value)
			{
				var oldValue:String = _title;            
				_title = value;
				
				if (hasEventListener(PropertyChangeEvent.PROPERTY_CHANGE))
				{
					var changeEvent:PropertyChangeEvent = 
						PropertyChangeEvent.createUpdateEvent(this, "title", oldValue, _title);
					
					dispatchEvent(changeEvent);
				}
			}
		}
		
		//----------------------------------
		//  titleContent
		//----------------------------------
		
		private var _titleContent:Array;
		
		[ArrayElementType("mx.core.IVisualElement")]
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
		public function get titleContent():Array
		{
			return _titleContent;
		}
		/**
		 *  @private
		 */
		public function set titleContent(value:Array):void
		{
			var oldValue:Array = _titleContent;
			_titleContent = value;
			
			if (hasEventListener(PropertyChangeEvent.PROPERTY_CHANGE))
			{
				var changeEvent:PropertyChangeEvent = 
					PropertyChangeEvent.createUpdateEvent(this, "titleContent", oldValue, _titleContent);
				
				dispatchEvent(changeEvent);
			}
		}
		
		//----------------------------------
		//  titleLayout
		//----------------------------------
		
		private var _titleLayout:LayoutBase;
		
		/**
		 *  @copy ActionBar#titleLayout
		 *
		 *  @default null
		 *  
		 *  @langversion 3.0
		 *  @playerversion AIR 2.5
		 *  @productversion Flex 4.5
		 */
		public function get titleLayout():LayoutBase
		{
			return _titleLayout;
		}
		/**
		 *  @private
		 */
		public function set titleLayout(value:LayoutBase):void
		{
			var oldValue:LayoutBase = _titleLayout;
			_titleLayout = value;
			
			if (hasEventListener(PropertyChangeEvent.PROPERTY_CHANGE))
			{
				var changeEvent:PropertyChangeEvent = 
					PropertyChangeEvent.createUpdateEvent(this, "titleLayout", oldValue, _titleLayout);
				
				dispatchEvent(changeEvent);
			}
		}
		
		public function backKeyHandledByView():Boolean
		{
			if (hasEventListener(FlexEvent.BACK_KEY_PRESSED))
			{
				var event:FlexEvent = new FlexEvent(FlexEvent.BACK_KEY_PRESSED, false, true);
				var eventCanceled:Boolean = !dispatchEvent(event);
				
				// If the event was canceled, that means the application
				// is doing its own custom logic for the back key
				return eventCanceled;
			}
			
			return false;
		}
		
		public function canRemove():Boolean
		{
			if (hasEventListener(ViewNavigatorEvent.REMOVING))
			{
				var event:ViewNavigatorEvent = 
					new ViewNavigatorEvent(ViewNavigatorEvent.REMOVING, 
						false, true, navigator.lastAction);
				
				return dispatchEvent(event);
			}
			
			return true;
		}
		
//		//----------------------------------
//		//  actionBarVisible
//		//----------------------------------
//		private var _actionBarVisible:Boolean = true;
//		
//		[Inspectable(category="General", defaultValue="true")]
//		/**
//		 *  Specifies whether a view should show the action bar or not.
//		 *  This property does not necessarily correlate to the 
//		 *  <code>visible</code> property of the view navigator's ActionBar control. 
//		 *
//		 *  @default true
//		 * 
//		 *  @langversion 3.0
//		 *  @playerversion AIR 2.5
//		 *  @productversion Flex 4.5
//		 */
//		public function get actionBarVisible():Boolean
//		{
//			return _actionBarVisible;
//		}
//		
//		/**
//		 *  @private
//		 */ 
//		public function set actionBarVisible(value:Boolean):void
//		{
//			_actionBarVisible = value;
//			
//			// Immediately request actionBar's visibility be toggled
//			if (isActive && navigator)
//			{
//				if (_actionBarVisible)
//					navigator.showActionBar();
//				else
//					navigator.hideActionBar();
//			}
//		}
		
		public function setActionBarVisible(value:Boolean):void
		{
			_actionBarVisible = value;
		}
		
		private var _active:Boolean = false;
		
		public function get isActive():Boolean
		{
			return _active;
		}
		
		public function setActive(value:Boolean):void
		{
			if (_active != value)
			{
				_active = value;
				
				// Switch orientation states if needed
				if (_active)
					updateOrientationState();
				
				var eventName:String = _active ? 
					ViewNavigatorEvent.VIEW_ACTIVATE : 
					ViewNavigatorEvent.VIEW_DEACTIVATE;
				
				if (hasEventListener(eventName))
					dispatchEvent(new ViewNavigatorEvent(eventName, false, false, navigator.lastAction));
			}
		}
		
		/**
		 *  @private
		 */
		mx_internal function updateOrientationState():void
		{
			setCurrentState(getCurrentViewState(), false);
		}
		
		/**
		 *  @inheritDoc
		 */
		public function deserializeData(value:Object):Object
		{
			return value;
		}
		
		/**
		 *  @inheritDoc
		 */
		public function setNavigator(value:ViewNavigator):void
		{
			_navigator = value;
			
			if (hasEventListener("navigatorChanged"))
				dispatchEvent(new Event("navigatorChanged"));
		}
		
		/**
		 *  @inheritDoc
		 */
		public function createReturnObject():Object
		{
			return null;
		}
		
		/**
		 *  @inheritDoc
		 */
		public function serializeData():Object
		{
			return data;    
		}
		
		
		/**
		 *  @inheritDoc
		 */
		public function getCurrentViewState():String
		{
			var aspectRatio:String = FlexGlobals.topLevelApplication.aspectRatio;
			
			if (hasState(aspectRatio))
				return aspectRatio;
			
			// If the appropriate state for the orientation of the device
			// isn't defined, return the current state
			return currentState;
		}
		
		//----------------------------------
		//  data
		//----------------------------------
		
		private var _data:Object;
		
		[Bindable("dataChange")]
		
		/**
		 *  @inheritDoc
		 */
		public function get data():Object
		{
			return _data;
		}
		
		/**
		 *  @private
		 */ 
		public function set data(value:Object):void
		{
			_data = value;
			
			if (hasEventListener(FlexEvent.DATA_CHANGE))
				dispatchEvent(new FlexEvent(FlexEvent.DATA_CHANGE));
		}
	}
}