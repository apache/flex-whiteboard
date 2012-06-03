
package ws.tink.spark.primitives
{
	import flash.display.Graphics;
	
	import spark.primitives.supportClasses.FilledElement;
	
	
	
	public class Wedge extends FilledElement
	{
		
		//--------------------------------------------------------------------------
		//
		//      Constructor  
		//
		//--------------------------------------------------------------------------
		
		
		/**
		 *  Constructor.
		 *
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function Wedge()
		{
			super();
		}
		
		
		
		//--------------------------------------------------------------------------
		//
		//      Properties  
		//
		//--------------------------------------------------------------------------
		
		//-----------------------
		//  startAngle    
		//-----------------------
		
		private var _startAngle:Number;
		
		/**
		 *  The beginning angle of the arc. If not specified
		 *  a default value of 0 is used.
		 *
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get startAngle():Number
		{
			if (!_startAngle)
			{
				return 0;
			}
			return _startAngle;
		}
		
		/**
		 *  @private
		 */
		public function set startAngle(value:Number):void
		{
			if (_startAngle != value)
			{
				_startAngle = value;
				
				invalidateSize();
				invalidateDisplayList();
				invalidateParentSizeAndDisplayList();
			}
		}
		
		
		
		//-----------------------
		//  arc   
		//-----------------------
		
		private var _arc:Number;
		
		/**
		 *  The angular extent of the arc. If not specified
		 *  a default value of 0 is used.
		 *
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get arc():Number
		{
			if (!_arc)
			{
				return 0;
			}
			return _arc;
		}
		
		/**
		 *  @private
		 */
		public function set arc(value:Number):void
		{
			if (_arc != value)
			{
				_arc = value;
				
				invalidateSize();
				invalidateDisplayList();
				invalidateParentSizeAndDisplayList();
			}
		}
		
		
		
		//-----------------------
		//  closureType   
		//-----------------------
		
		private var _closureType:String;
		
		[Inspectable(category="General",enumeration="open,chord,pie",defaultValue="open")]
		
		/**
		 * The method in which to close the arc.
		 * <p>
		 * <li><b>open</b> will apply no closure.</li>
		 * <li><b>chord</b> will close the arc with a strait line to the start.</li>
		 * <li><b>pie</b> will draw a line from center to start and end to center forming a pie shape.</li>
		 * </p>
		 **/
		public function get closureType():String
		{
			if (!_closureType)
			{
				return "open";
			}
			return _closureType;
		}
		
		public function set closureType(value:String):void
		{
			if (_closureType != value)
			{
				_closureType = value;
				
				invalidateSize();
				invalidateDisplayList();
				invalidateParentSizeAndDisplayList();
			}
		}
		
		
		
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Overridden methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @inheritDoc
		 *
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		override protected function draw(g:Graphics):void
		{
			if( Math.abs( arc ) >= 360 )
			{
				g.drawEllipse( x, y, width, height );
			}
			else
			{
				const segments:uint = Math.ceil( Math.abs( arc ) / 45 );
				if( segments == 0 ) return;
				
				var radians:Number = startAngle * ( Math.PI / 180 );
				const radiusX:Number = width / 2;
				const radiusY:Number = height / 2;
				
				var sx:Number = radiusX + ( radiusX * Math.cos( radians ) );
				var sy:Number = radiusY + ( radiusY * Math.sin( radians ) );
				
				//draw the start line in the case of a pie type
				if (closureType == "pie")
				{
					g.moveTo( x + radiusX, y + radiusY );
					g.lineTo( x + sx, y + sy );
				}
				else
				{
					g.moveTo( x + sx, y + sy );
				}
				
				
				// Now calculate the sweep of each segment
				const angleDelta:Number = arc / segments;
				
				const radiansDelta:Number = angleDelta * ( Math.PI / 180 );
				const halfRadiansDelta:Number = radiansDelta / 2;
				
				var px:Number;
				var py:Number;
				var cx:Number;
				var cy:Number;
				
				// Loop for drawing arc segments
				for( var i:int = 0; i < segments; i++)
				{
					radians += radiansDelta;
					
					px = radiusX + ( radiusX * Math.cos( radians ) );
					py = radiusY + ( radiusY * Math.sin( radians ) );
					
					cx = radiusX + Math.cos(radians - halfRadiansDelta ) * (radiusX / Math.cos( halfRadiansDelta ) );
					cy = radiusY + Math.sin(radians - halfRadiansDelta ) * (radiusY / Math.cos( halfRadiansDelta ) );
					
					g.curveTo( x + cx, y + cy, x + px, y + py);
				}
				
				
				// close the arc if required
				if (closureType == "pie")
				{
					g.lineTo( x + radiusX, y + radiusY );
				}
				else if (closureType == "chord")
				{
					g.lineTo( sx, sy );
				}
				
			}
		}
			
		
		
		
//		/**
//		 *  @private
//		 */
//		protected static function drawEllipticalArc(x:Number, y:Number, startAngle:Number, arc:Number, radius:Number,
//													yRadius:Number, g:Graphics):void
//		{
//			
//			var ax:Number;
//			var ay:Number;
//			
//			// Circumvent drawing more than is needed
//			if (Math.abs(arc) > 360)
//			{
//				arc = 360;
//			}
//			
//			// Draw in a maximum of 45 degree segments. First we calculate how many 
//			// segments are needed for our arc.
//			var segs:Number = Math.ceil(Math.abs(arc) / 45);
//			
//			// Now calculate the sweep of each segment
//			var segAngle:Number = arc / segs;
//			
//			// The math requires radians rather than degrees. To convert from degrees
//			// use the formula (degrees/180)*Math.PI to get radians. 
//			var theta:Number = (segAngle / 180) * Math.PI;
//			
//			// convert angle startAngle to radians
//			var angle:Number = (startAngle / 180) * Math.PI;
//			
//			// find our starting points (ax,ay) relative to the secified x,y
//			ax = x - Math.cos(angle) * radius;
//			ay = y - Math.sin(angle) * yRadius;
//			
//			trace( Math.cos(angle) * radius, Math.sin(angle) * yRadius, "x", x, "y", y, radius, yRadius );
//			
//			// Draw as 45 degree segments
//			if (segs > 0)
//			{
//				var oldX:Number = x;
//				var oldY:Number = y;
//				var cx:Number;
//				var cy:Number;
//				var x1:Number;
//				var y1:Number;
//				
//				// Loop for drawing arc segments
//				for (var i:int = 0; i < segs; i++)
//				{
//					
//					// increment our angle
//					angle += theta;
//					
//					//find the angle halfway between the last angle and the new one,
//					//calculate our end point, our control point, and draw the arc segment
//					
//					cx = ax + Math.cos(angle - (theta / 2)) * (radius / Math.cos(theta / 2));
//					
//					cy = ay + Math.sin(angle - (theta / 2)) * (yRadius / Math.cos(theta / 2));
//					
//					x1 = ax + Math.cos(angle) * radius;
//					
//					y1 = ay + Math.sin(angle) * yRadius;
//					
//					g.curveTo(cx, cy, x1, y1);
//					
//					oldX = x1;
//					oldY = y1;
//				}
//			}
//		}
		
	}
}
