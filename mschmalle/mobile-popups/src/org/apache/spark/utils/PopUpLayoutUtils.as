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

package org.apache.spark.utils
{

import flash.geom.Rectangle;

import mx.core.EdgeMetrics;
import mx.core.IInvalidating;
import mx.core.IVisualElement;
import mx.styles.IStyleClient;

import org.apache.spark.components.supportClasses.PopUpLayoutPlacement;

/**
 * @private 
 * 
 * @productversion 1.0
 */
public class PopUpLayoutUtils
{
	/**
	 * @private
	 */
	public static function layoutElement(element:IVisualElement,
										 position:String,
										 unscaledWidth:Number,
										 unscaledHeight:Number,
										 edges:EdgeMetrics = null):void
	{
		var b:EdgeMetrics = (edges != null) ? edges : EdgeMetrics.EMPTY;
		
		var top:Number = b.top;
		var bottom:Number = b.bottom;
		var left:Number = b.left;
		var right:Number = b.right;
		
		var paddingTop:Number = getStyle(element, "paddingTop", 0);
		var paddingBottom:Number = getStyle(element, "paddingBottom", 0);
		var paddingLeft:Number = getStyle(element, "paddingLeft", 0);
		var paddingRight:Number = getStyle(element, "paddingRight", 0);
		
		var calcX:Number = left;
		var calcY:Number = top;
		
		//element.setLayoutBoundsSize(NaN, NaN);
		var calcWidth:Number = element.getLayoutBoundsWidth();
		var calcHeight:Number = element.getLayoutBoundsHeight();
		
		var excededWidth:Boolean = false;
		var excededHeight:Boolean = false;
		
		// test that the child is not larger han parent
		if (calcWidth >= unscaledWidth) 
		{
			calcWidth = unscaledWidth;
			element.width = calcWidth;
			// I think this is the only way to get the right height instantly
			if (element is IInvalidating)
				IInvalidating(element).validateNow();
			calcHeight  = element.getLayoutBoundsHeight();
			excededWidth = true;
		}
		if (calcHeight >= unscaledHeight) 
		{
			calcHeight = unscaledHeight;
			element.height = calcHeight;
			// I think this is the only way to get the right height instantly
			if (element is IInvalidating)
				IInvalidating(element).validateNow();
			calcWidth  = element.getLayoutBoundsWidth();
			excededHeight = true;
		}
		
		switch (position)
		{
			case PopUpLayoutPlacement.TOP_LEFT :
				calcX = left;
				calcY = top;			
				break;
			
			case PopUpLayoutPlacement.TOP :
				calcX = (unscaledWidth - calcWidth) / 2;
				calcY = top;
				break;
			
			case PopUpLayoutPlacement.TOP_RIGHT :
				calcX = (unscaledWidth - calcWidth - right);
				calcY = top;
				break;
			
			case PopUpLayoutPlacement.RIGHT :
				calcX = (unscaledWidth - calcWidth - right);
				calcY = (unscaledHeight - calcHeight) / 2;
				break;
			
			case PopUpLayoutPlacement.BOTTOM_RIGHT :
				calcX = (unscaledWidth - calcWidth - right);
				calcY = (unscaledHeight - calcHeight - bottom);
				break;
			
			case PopUpLayoutPlacement.BOTTOM :
				calcX = (unscaledWidth - calcWidth) / 2;
				calcY = (unscaledHeight - calcHeight - bottom);
				break;
			
			case PopUpLayoutPlacement.BOTTOM_LEFT :
				calcX = left;
				calcY = (unscaledHeight - calcHeight - bottom);
				break;
			
			case PopUpLayoutPlacement.LEFT :
				calcX = left;
				calcY = (unscaledHeight - calcHeight) / 2;
				break;
			
			case PopUpLayoutPlacement.CENTER :
				calcX = (unscaledWidth - calcWidth) / 2;
				calcY = (unscaledHeight - calcHeight) / 2;
				break;
			
			case PopUpLayoutPlacement.CENTER_FILL_HORIZONTAL :
				calcX = b.left;
				calcY = (excededHeight) ? b.top : (unscaledHeight - calcHeight) / 2;
				calcWidth = unscaledWidth - b.left - b.right;
				calcHeight = (excededHeight) ? unscaledHeight - b.top - b.bottom : calcHeight;
				break;
			
			case PopUpLayoutPlacement.CENTER_FILL_VERTICAL :
				calcX = (excededWidth) ? b.right : (unscaledWidth - calcWidth) / 2;
				calcY = b.top
				calcWidth = (excededWidth) ? unscaledWidth - b.left - b.right : calcWidth;
				calcHeight = unscaledHeight - b.top - b.bottom;
				break;
			
			case PopUpLayoutPlacement.CENTER_FILL :
				calcX = b.left
				calcY = b.top;
				calcWidth = unscaledWidth - b.left - b.right;
				calcHeight = unscaledHeight - b.top - b.bottom;
				break;
		}
		
		element.x = Math.floor(calcX);
		element.y = Math.floor(calcY);
		element.width = calcWidth;
		element.height = calcHeight;
	}
	
	/**
	 * @private
	 */
	public static function layoutElement2(element:IVisualElement,
										  position:String,
										  rect:Rectangle,
										  edges:EdgeMetrics = null):void
	{
		var b:EdgeMetrics = (edges != null) ? edges : EdgeMetrics.EMPTY;
		
		var top:Number = b.top;
		var bottom:Number = b.bottom;
		var left:Number = b.left;
		var right:Number = b.right;
		
		var paddingTop:Number = getStyle(element, "paddingTop", 0);
		var paddingBottom:Number = getStyle(element, "paddingBottom", 0);
		var paddingLeft:Number = getStyle(element, "paddingLeft", 0);
		var paddingRight:Number = getStyle(element, "paddingRight", 0);
		
		var calcX:Number = left;
		var calcY:Number = top;
		
		//element.setLayoutBoundsSize(NaN, NaN);
		var calcWidth:Number = element.getLayoutBoundsWidth();
		var calcHeight:Number = element.getLayoutBoundsHeight();
		
		var unscaledWidth:Number = rect.width;
		var unscaledHeight:Number = rect.height;
		
		var excededWidth:Boolean = false;
		var excededHeight:Boolean = false;
		
		// test that the child is not larger han parent
		if (calcWidth >= unscaledWidth) 
		{
			calcWidth = unscaledWidth;
			element.width = calcWidth;
			// I think this is the only way to get the right height instantly
			if (element is IInvalidating)
				IInvalidating(element).validateNow();
			calcHeight  = element.getLayoutBoundsHeight();
			excededWidth = true;
		}
		if (calcHeight >= unscaledHeight) 
		{
			calcHeight = unscaledHeight;
			element.height = calcHeight;
			// I think this is the only way to get the right height instantly
			if (element is IInvalidating)
				IInvalidating(element).validateNow();
			calcWidth  = element.getLayoutBoundsWidth();
			excededHeight = true;
		}
		
		switch (position)
		{
			case PopUpLayoutPlacement.TOP_LEFT :
				calcX = rect.x + left;
				calcY = rect.y + top;			
				break;
			
			case PopUpLayoutPlacement.TOP :
				calcX = rect.x + (unscaledWidth - calcWidth) / 2;
				calcY = rect.y + top;
				break;
			
			case PopUpLayoutPlacement.TOP_RIGHT :
				calcX = rect.x + (unscaledWidth - calcWidth - right);
				calcY = rect.y + top;
				break;
			
			case PopUpLayoutPlacement.RIGHT :
				calcX = rect.x + (unscaledWidth - calcWidth - right);
				calcY = rect.y + (unscaledHeight - calcHeight) / 2;
				break;
			
			case PopUpLayoutPlacement.BOTTOM_RIGHT :
				calcX = rect.x + (unscaledWidth - calcWidth - right);
				calcY = rect.y + (unscaledHeight - calcHeight - bottom);
				break;
			
			case PopUpLayoutPlacement.BOTTOM :
				calcX = rect.x + (unscaledWidth - calcWidth) / 2;
				calcY = rect.y + (unscaledHeight - calcHeight - bottom);
				break;
			
			case PopUpLayoutPlacement.BOTTOM_LEFT :
				calcX = rect.x + left;
				calcY = rect.y + (unscaledHeight - calcHeight - bottom);
				break;
			
			case PopUpLayoutPlacement.LEFT :
				calcX = rect.x + left;
				calcY = rect.y + (unscaledHeight - calcHeight) / 2;
				break;
			
			case PopUpLayoutPlacement.CENTER :
				calcX = rect.x + (unscaledWidth - calcWidth) / 2;
				calcY = rect.y + (unscaledHeight - calcHeight) / 2;
				break;
			
			case PopUpLayoutPlacement.CENTER_FILL_HORIZONTAL :
				calcX = rect.x + b.left;
				calcY = (excededHeight) ? rect.y + b.top :  rect.y + (unscaledHeight - calcHeight) / 2;
				calcWidth = unscaledWidth - b.left - b.right;
				calcHeight = (excededHeight) ? unscaledHeight - b.top - b.bottom : calcHeight;
				break;
			
			case PopUpLayoutPlacement.CENTER_FILL_VERTICAL :
				calcX = (excededWidth) ? b.right : (unscaledWidth - calcWidth) / 2;
				calcY = b.top
				calcWidth = (excededWidth) ? unscaledWidth - b.left - b.right : calcWidth;
				calcHeight = unscaledHeight - b.top - b.bottom;
				break;
			
			case PopUpLayoutPlacement.CENTER_FILL :
				calcX = b.left
				calcY = b.top;
				calcWidth = unscaledWidth - b.left - b.right;
				calcHeight = unscaledHeight - b.top - b.bottom;
				break;
		}
		
		element.x = Math.floor(calcX);
		element.y = Math.floor(calcY);
		element.width = calcWidth;
		element.height = calcHeight;
	}
	
	/**
	 * @private 
	 */
	private static function getStyle(element:IVisualElement, 
									 name:String, 
									 defaultValue:*):*
	{
		var client:IStyleClient = element as IStyleClient;
		if (client == null)
			return defaultValue;
		
		return client.getStyle(name);
	}
	
	/**
	 * @private
	 */
	public static function findParent(owner:Object, type:Class):Object
	{
		var parent:Object = owner;
		while(parent != null)
		{
			if (parent is type)
				return parent;
			parent = parent.parent;
		}
		return null;
	}
}
}