package net.flashpunk
{
	import flash.display.Graphics;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;

	/**
	 * Base class for Entity collision masks.
	 */
	public class Mask 
	{
		/**
		 * If the Entity should respond to collision checks.
		 */
		public var collidable:Boolean = true;
		
		/**
		 * The parent Entity of this mask.
		 */
		public var parent:Entity;
		
		/**
		 * Constructor.
		 */
		public function Mask(type:String = null)
		{
			_type = type;
			_class = Class(getDefinitionByName(getQualifiedClassName(this)));
		}
		
		/**
		 * The collision type, used for collision checking.
		 */
		public function get type():String { return _type; }
		public function set type(value:String):void
		{
			if (_type == value) return;
			if (parent && parent._world && type)
				parent._world.removeType(this);
			
			_type = value;
			
			if (parent && parent._world && type)
				parent._world.addType(this);
		}
		
		/**
		 * Checks if this Mask collides with any others in the world.
		 * @param	x		Virtual x position to place this Mask.
		 * @param	y		Virtual y position to place this Mask.
		 * @param	types	A String or an Array or Vector of Strings, specifying the type Mask to collide against.
		 * @return	The first Mask collided with, or null if there are no collisions.
		 */
		public function collide(types:Object, x:Number, y:Number):Mask
		{
			if (!parent || !parent.world)
				return null;
				
			parent.setTempXY(x, y);
			var result:Mask = parent.world.collideMask(types, this);
			parent.restoreXY();
			
			return result;
		}
		
		/**
		 * Finds all other masks in the world that this one collides with.
		 * @param	into	A String or an Array or Vector of Strings, specifying the type Mask to collide against.
		 * @param	types	An optional list of types to collide with.
		 * @return	
		 */
		public function collideInto(types:Object, x:Number, y:Number, into:Object):void
		{
			if (!parent || !parent.world || !(into is Array || into is Vector.<*>))
				return;
				
			parent.setTempXY(x, y);
			parent.world.collideMask(types, this);
			parent.restoreXY();
		}
		
		/**
		 * Checks for collision with another Mask.
		 * @param	mask	The other Mask to check against.
		 * @return	If the Masks overlap.
		 */
		public function check(mask:Mask):Boolean
		{
			if (_check[mask._class] != null) return _check[mask._class](mask);
			if (mask._check[_class] != null) return mask._check[_class](this);
			return false;
		}
		
		/**
		 * Checks for collision with a point.
		 * @param	pX	The point's x coordinate.
		 * @param	pY	The point's y coordinate.
		 * @return	If the point collides.
		 */
		public function checkPoint(pX:Number, pY:Number):Boolean
		{
			return false;
		}
		
		/**
		 * Checks for collision with a rectangle.
		 * @param	rX		The x coordinate of the rectangle's left side.
		 * @param	rY		The y coordinate of the rectangle's top side.
		 * @param	rWidth	The rectangle's width.
		 * @param	rHeight	The rectangle's height.
		 * @return	If the rectangle collides.
		 */
		public function checkRect(rX:Number, rY:Number, rWidth:Number, rHeight:Number):Boolean
		{
			return false;
		}
		
		/** Used to render debug information in console. */
		public function renderDebug(g:Graphics):void
		{
			
		}
		
		// Mask information.
		/** @private */ internal var _type:String;
		/** @private */ private var _class:Class;
		/** @private */ protected var _check:Dictionary = new Dictionary;
		
		// Link lists
		/** @private */ internal var _typePrev:Mask;
		/** @private */ internal var _typeNext:Mask;
		/** @private */ internal var _siblingPrev:Mask;
		/** @private */ internal var _siblingNext:Mask;
	}
}
