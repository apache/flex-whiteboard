package org.apache.components
{
	import flash.events.Event;
	
	import mx.core.UIComponent;
	import mx.core.mx_internal;
	import mx.events.FlexEvent;
	
	import spark.components.supportClasses.StyleableTextField;
	import spark.core.IDisplayText;
	
	use namespace mx_internal;
	
	// created by JH DotComIt to make this component publicly available so it can be used as a skin part for the ToggleSwitch
	// originally this was hidden as part of the ToggleSwitch
	/**
	 *  @private
	 *  Component combining two labels to create the effect of text and its drop
	 *  shadow. The component can be used with advanced style selectors and the
	 *  styles "color", "textShadowColor", and "textShadowAlpha". Based off of
	 *  ActionBar.TitleDisplayComponent. These two should eventually be factored.
	 */
	public class LabelDisplayComponent extends UIComponent implements IDisplayText
	{
		public var shadowYOffset:Number = 0;
		private var labelChanged:Boolean = false;
		private var labelDisplay:StyleableTextField;
		private var labelDisplayShadow:StyleableTextField;
		private var _text:String;
		
		public function LabelDisplayComponent() 
		{
			super();
			_text = "";
		}
		
		override public function get baselinePosition():Number 
		{
			return labelDisplay.baselinePosition;
		}
		
		override protected function createChildren():void 
		{
			super.createChildren();
			
			labelDisplay = StyleableTextField(createInFontContext(StyleableTextField));
			labelDisplay.styleName = this;
			labelDisplay.editable = false;
			labelDisplay.selectable = false;
			labelDisplay.multiline = false;
			labelDisplay.wordWrap = false;
			labelDisplay.addEventListener(FlexEvent.VALUE_COMMIT,
				labelDisplay_valueCommitHandler);
			
			labelDisplayShadow = StyleableTextField(createInFontContext(StyleableTextField));
			labelDisplayShadow.styleName = this;
			labelDisplayShadow.colorName = "textShadowColor";
			labelDisplayShadow.editable = false;
			labelDisplayShadow.selectable = false;
			labelDisplayShadow.multiline = false;
			labelDisplayShadow.wordWrap = false;
			
			addChild(labelDisplayShadow);
			addChild(labelDisplay);
		}
		
		override protected function commitProperties():void 
		{
			super.commitProperties();
			
			if (labelChanged)
			{
				labelDisplay.text = text;
				invalidateSize();
				invalidateDisplayList();
				labelChanged = false;
			}
		}
		
		override protected function measure():void 
		{
			if (labelDisplay.isTruncated)
				labelDisplay.text = text;
			labelDisplay.commitStyles();
			measuredWidth = labelDisplay.getPreferredBoundsWidth();
			measuredHeight = labelDisplay.getPreferredBoundsHeight();
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void 
		{
			if (labelDisplay.isTruncated)
				labelDisplay.text = text;
			labelDisplay.commitStyles();
			
			var labelHeight:Number = labelDisplay.getPreferredBoundsHeight();
			var labelY:Number = (unscaledHeight - labelHeight) / 2;
			
			var labelWidth:Number = Math.min(unscaledWidth, labelDisplay.getPreferredBoundsWidth());
			var labelX:Number = (unscaledWidth - labelWidth) / 2;
			
			labelDisplay.setLayoutBoundsSize(labelWidth, labelHeight);
			labelDisplay.setLayoutBoundsPosition(labelX, labelY);
			
			labelDisplay.truncateToFit();
			
			labelDisplayShadow.commitStyles();
			labelDisplayShadow.setLayoutBoundsSize(labelWidth, labelHeight);
			labelDisplayShadow.setLayoutBoundsPosition(labelX, labelY + shadowYOffset);
			
			labelDisplayShadow.alpha = getStyle("textShadowAlpha");
			
			// unless the label was truncated, labelDisplayShadow.text was set in
			// the value commit handler
			if (labelDisplay.isTruncated)
				labelDisplayShadow.text = labelDisplay.text;
		}
		
		private function labelDisplay_valueCommitHandler(event:Event):void 
		{
			labelDisplayShadow.text = labelDisplay.text;
		}
		
		public function get text():String 
		{
			return _text;
		}
		
		public function set text(value:String):void 
		{
			_text = value;
			labelChanged = true;
			invalidateProperties();
		}
		
		public function get isTruncated():Boolean 
		{
			return labelDisplay.isTruncated;
		}
		
		public function showShadow(value:Boolean):void 
		{
			labelDisplayShadow.visible = value;
		}
	}
}