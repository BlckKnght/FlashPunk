package net.flashpunk.masks 
{
	import net.flashpunk.Mask;
	
	/**
	 * Uses parent's hitbox to determine collision. This class is used
	 * internally by FlashPunk, you don't need to use this class because
	 * this is the default behaviour of Entities without a Mask object.
	 */
	public class Hitbox extends Mask
	{
		/**
		 * The coordinates of the hitbox, relative to its parent Entity.
		 */
		public var x:Number;
		public var y:Number;
		
		/**
		 * The dimensions of the hitbox.
		 */
		public var width:Number;
		public var height:Number;
		
		/**
		 * Constructor.
		 * @param	type		The collision type of the hitbox.
		 * @param	width		Width of the hitbox.
		 * @param	height		Height of the hitbox.
		 * @param	x			X offset of the hitbox.
		 * @param	y			Y offset of the hitbox.
		 */
		public function Hitbox(type:String = null, width:uint = 1, height:uint = 1, x:int = 0, y:int = 0) 
		{
			this.type = type;
			this.width = width;
			this.height = height;
			this.x = x;
			this.y = y;
			_check[Hitbox] = checkHitboxHitbox;
		}
		
		/**
		 * Checks for collision with a point.
		 * @param	pX	The point's x coordinate.
		 * @param	pY	The point's y coordinate.
		 * @return	If the point collides.
		 */
		override public function checkPoint(pX:Number, pY:Number):Boolean
		{
			if (parent)
				return parent.x + x + width  > pX && parent.x + x < pX
					&& parent.y + y + height > pY && parent.y + y < pY;
			else
				return x + width  > pX && x < pX
					&& y + height > pY && y < pY;
		}
		
		/**
		 * Checks for collision with a rectangle.
		 * @param	rX		The x coordinate of the rectangle's left side.
		 * @param	rY		The y coordinate of the rectangle's top side.
		 * @param	rWidth	The rectangle's width.
		 * @param	rHeight	The rectangle's height.
		 * @return	If the rectangle collides.
		 */
		override public function checkRect(rX:Number, rY:Number, rWidth:Number, rHeight:Number):Boolean
		{
			if (parent)
				return parent.x + x + width  > rX && parent.x + x < rX + rWidth
					&& parent.y + y + height > rY && parent.y + y < rY + rHeight;
			else
				return x + width  > rX && x < rX + rWidth
					&& y + height > rY && y < rY + rWidth;
		}
		
		/** Collides against another Hitbox. */
		protected function checkHitboxHitbox(other:Hitbox):Boolean
		{
			return checkRect(other.parent.x + other.x, other.parent.y + other.y, other.width, other.height);
		}
	}
}
