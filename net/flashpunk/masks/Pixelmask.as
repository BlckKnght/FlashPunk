package net.flashpunk.masks
{
	import flash.display.*;
	import flash.geom.*;
	import net.flashpunk.*;
	
	/**
	 * A bitmap mask used for pixel-perfect collision. 
	 */
	public class Pixelmask extends Hitbox
	{
		/**
		 * Alpha threshold of the bitmap used for collision.
		 */
		public var threshold:uint = 1;
		
		/**
		 * Pixel data used for collision tests.
		 */
		public var data:BitmapData;
		
		/**
		 * Constructor.
		 * @param	source		The image to use as a mask.
		 * @param	x			X offset of the mask.
		 * @param	y			Y offset of the mask.
		 */
		public function Pixelmask(source:*, type:String = null, x:int = 0, y:int = 0)
		{
			// fetch mask data
			if (source is BitmapData) data = source;
			if (source is Class) data = FP.getBitmap(source);
			if (data)
				super(type, data.width, data.height, x, y);
			else
				throw new Error("Invalid Pixelmask source image.");
			
			// set callback functions
			_check[Pixelmask] = checkPixelmaskPixelmask;
			_check[Hitbox] = checkPixelmaskHitbox;
		}
		
		// TODO: checkPoint and checkRect overrides
		
		// TODO: update all checks to allow unparented masks to collide without errors
		override public function check(other:Mask):Boolean
		{
			if (!parent)
				return false;
			else
				return super.check(other);
		}
		
		/** Collide against a Hitbox. */
		protected function checkPixelmaskHitbox(other:Hitbox):Boolean
		{
			if (!checkHitboxHitbox(other)) return false;
			_point.x = parent.x + x;
			_point.y = parent.y + y;
			_rect.x = other.parent.x + other.x;
			_rect.y = other.parent.y + other.y;
			_rect.width = other.width;
			_rect.height = other.height;
			return data.hitTest(_point, threshold, _rect);
		}
		
		/** Collide against a Pixelmask. */
		protected function checkPixelmaskPixelmask(other:Pixelmask):Boolean
		{
			if (!super.checkHitboxHitbox(other)) return false;
			_point.x = parent.x + x;
			_point.y = parent.y + y;
			_point2.x = other.parent.x + other.x;
			_point2.y = other.parent.y + other.y;
			return data.hitTest(_point, threshold, other.data, _point2, other.threshold);
		}
		
		public override function renderDebug(g:Graphics):void
		{
			if (! _debug) {
				_debug = new BitmapData(data.width, data.height, true, 0x0);
			}
			
			FP.rect.x = 0;
			FP.rect.y = 0;
			FP.rect.width = data.width;
			FP.rect.height = data.height;
			
			_debug.fillRect(FP.rect, 0x0);
			_debug.threshold(data, FP.rect, FP.zero, ">=", threshold << 24, 0x40FFFFFF, 0xFF000000);
			
			var sx:Number = FP.screen.scaleX * FP.screen.scale;
			var sy:Number = FP.screen.scaleY * FP.screen.scale;
			
			FP.matrix.a = sx;
			FP.matrix.d = sy;
			FP.matrix.b = FP.matrix.c = 0;
			FP.matrix.tx = (parent.x + x - FP.camera.x)*sx;
			FP.matrix.ty = (parent.y + y - FP.camera.y)*sy;
			
			g.lineStyle();
			g.beginBitmapFill(_debug, FP.matrix);
			g.drawRect(FP.matrix.tx, FP.matrix.ty, data.width*sx, data.height*sy);
			g.endFill();
		}
		
		// Pixelmask information.
		/** @private */ internal var _debug:BitmapData;
		
		// Global objects.
		/** @private */ private var _rect:Rectangle = FP.rect;
		/** @private */ private var _point:Point = FP.point;
		/** @private */ private var _point2:Point = FP.point2;
	}
}
