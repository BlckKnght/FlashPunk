package net.flashpunk
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;

	import net.flashpunk.graphics.*;

	/**
	 * Main game Entity class updated by World.
	 */
	public class Entity extends Tweener
	{
		/**
		 * If the Entity should render.
		 */
		public var visible:Boolean = true;
		
		/**
		 * If the Entity should respond to collision checks.
		 */
		//public var collidable:Boolean = true;
		
		/**
		 * X position of the Entity in the World.
		 */
		public var x:Number = 0;
		
		/**
		 * Y position of the Entity in the World.
		 */
		public var y:Number = 0;
		
		/**
		 * Width of the Entity's hitbox.
		 */
		//public var width:int;
		
		/**
		 * Height of the Entity's hitbox.
		 */
		//public var height:int;
		
		/**
		 * X origin of the Entity's hitbox.
		 */
		//public var originX:int;
		
		/**
		 * Y origin of the Entity's hitbox.
		 */
		//public var originY:int;
		
		/**
		 * The BitmapData target to draw the Entity to. Leave as null to render to the current screen buffer (default).
		 */
		public var renderTarget:BitmapData;
		
		/**
		 * Constructor. Can be usd to place the Entity and assign a graphic and mask.
		 * @param	x			X position to place the Entity.
		 * @param	y			Y position to place the Entity.
		 * @param	graphic		Graphic to assign to the Entity.
		 * @param	mask		Mask to assign to the Entity.
		 */
		public function Entity(x:Number = 0, y:Number = 0, graphic:Graphic = null, mask:Mask = null) 
		{
			this.x = x;
			this.y = y;
			if (graphic) this.graphic = graphic;
			if(mask) addMask(mask);
			_class = Class(getDefinitionByName(getQualifiedClassName(this)));
		}
		
		/**
		 * Override this, called when the Entity is added to a World.
		 */
		public function added():void
		{
			
		}
		
		/**
		 * Override this, called when the Entity is removed from a World.
		 */
		public function removed():void
		{
			
		}
		
		/**
		 * Updates the Entity.
		 */
		override public function update():void 
		{
			
		}
		
		/**
		 * Renders the Entity. If you override this for special behaviour,
		 * remember to call super.render() to render the Entity's graphic.
		 */
		public function render():void 
		{
			if (_graphic && _graphic.visible)
			{
				if (_graphic.relative)
				{
					_point.x = x;
					_point.y = y;
				}
				else _point.x = _point.y = 0;
				_camera.x = _world ? _world.camera.x : FP.camera.x;
				_camera.y = _world ? _world.camera.y : FP.camera.y;
				_graphic.render(renderTarget ? renderTarget : FP.buffer, _point, _camera);
			}
		}
		
		/**
		 * Checks for a collision against an Entity type.
		 * @param	type		String, or an Array or Vector of Strings specifying the collision types to check against.
		 * @param	x			Virtual x position to place this Entity.
		 * @param	y			Virtual y position to place this Entity.
		 * @param	myTypes		Optional String, or Array or Vector of Strings, specifying the types of our masks to test with. If null, test with all masks.
		 * @return	The first Mask collided with, or null if none were collided.
		 */
		public function collide(types:Object, x:Number, y:Number, myTypes:Object = null):Mask
		{
			if (!_world) return null;
			setTempXY(x, y);
			var result:Mask = _world.collideEntity(types, this, myTypes);
			restoreXY();
			
			return result;
		}
		
		/**
		 * Depreciated, use collide() instead! Collide with multiple types.
		 * @param	type		String, or an Array or Vector of Strings specifying the collision types to check against.
		 * @param	x			Virtual x position to place this Entity.
		 * @param	y			Virtual y position to place this Entity.
		 * @return	The first Mask collided with, or null if none were collided.
		 */
		public function collideTypes(types:Object, x:Number, y:Number):Mask
		{
			return collide(types, x, y);
		}
		
		/**
		 * Checks if this Entity collides with a specific Mask.
		 * @param	m			The Mask to collide against.
		 * @param	myTypes		Optional String, or Array or Vector of Strings, specifying the types of our masks to test with. If null, test with all masks.
		 * @return	If the mask overlaps one of this Entity's Masks.
		 */
		public function check(other:Mask, myTypes:Object = null):Boolean
		{
			var s:String = myTypes as String;
			var a:Array = myTypes as Array;
			var v:Vector.<String> = myTypes as Vector.<String>;
			if (myTypes && !s && !a && !v) return false;
			
			var m:Mask = maskFirst;
			while (m)
			{
				if (m.collidable
					&& (!myTypes
						|| (s && s == m.type)
						|| (a && a.indexOf(m.type) > 0)
						|| (v && v.indexOf(m.type) > 0))
					&& m.check(other))
				{
					return true;
				}
				m = m._siblingNext;
			}
			return false;
		}
		
		/**
		 * Checks if this Entity overlaps the specified rectangle.
		 * @param	x			Virtual x position to place this Entity.
		 * @param	y			Virtual y position to place this Entity.
		 * @param	rX			X position of the rectangle.
		 * @param	rY			Y position of the rectangle.
		 * @param	rWidth		Width of the rectangle.
		 * @param	rHeight		Height of the rectangle.
		 * @return	If they overlap.
		 */
		/*public function collideRect(x:Number, y:Number, rX:Number, rY:Number, rWidth:Number, rHeight:Number):Boolean
		{
			if (x - originX + width >= rX && y - originY + height >= rY
			&& x - originX <= rX + rWidth && y - originY <= rY + rHeight)
			{
				if (!_mask) return true;
				_x = this.x; _y = this.y;
				this.x = x; this.y = y;
				FP.entity.x = rX;
				FP.entity.y = rY;
				FP.entity.width = rWidth;
				FP.entity.height = rHeight;
				if (_mask.collide(FP.entity.HITBOX))
				{
					this.x = _x; this.y = _y;
					return true;
				}
				this.x = _x; this.y = _y;
				return false;
			}
			return false;
		}*/
		
		/**
		 * Checks if this Entity overlaps the specified position.
		 * @param	x			Virtual x position to place this Entity.
		 * @param	y			Virtual y position to place this Entity.
		 * @param	pX			X position.
		 * @param	pY			Y position.
		 * @return	If the Entity intersects with the position.
		 */
		/*public function collidePoint(x:Number, y:Number, pX:Number, pY:Number):Boolean
		{
			if (pX >= x - originX && pY >= y - originY
			&& pX < x - originX + width && pY < y - originY + height)
			{
				if (!_mask) return true;
				_x = this.x; _y = this.y;
				this.x = x; this.y = y;
				FP.entity.x = pX;
				FP.entity.y = pY;
				FP.entity.width = 1;
				FP.entity.height = 1;
				if (_mask.collide(FP.entity.HITBOX))
				{
					this.x = _x; this.y = _y;
					return true;
				}
				this.x = _x; this.y = _y;
				return false;
			}
			return false;
		}*/
		
		/**
		 * Populates an array with all collided Entities of a type.
		 * @param	type		The Entity type to check for.
		 * @param	x			Virtual x position to place this Entity.
		 * @param	y			Virtual y position to place this Entity.
		 * @param	array		The Array or Vector object to populate.
		 * @param	myTypes		Optional String, or Array or Vector of Strings, specifying the types of our masks to test with. If null, test with all masks.
		 */
		public function collideInto(types:Object, x:Number, y:Number, array:Object, myTypes:Object):void
		{
			if (!_world) return;
			if (myTypes && !(myTypes is String || myTypes is Array || myTypes is Vector.<String>)) return;
			
			setTempXY(x, y);
			_world.collideEntityInto(types, this, array, myTypes);
			restoreXY();
		}
		
		/**
		 * If the Entity collides with the camera rectangle.
		 */
		/*public function get onCamera():Boolean
		{
			return collideRect(x, y, _world.camera.x, _world.camera.y, FP.width, FP.height);
		}*/
		
		/**
		 * The World object this Entity has been added to.
		 */
		public function get world():World
		{
			return _world;
		}
		
		/**
		 * Half the Entity's width.
		 */
		//public function get halfWidth():Number { return width / 2; }
		
		/**
		 * Half the Entity's height.
		 */
		//public function get halfHeight():Number { return height / 2; }
		
		/**
		 * The center x position of the Entity's hitbox.
		 */
		//public function get centerX():Number { return x - originX + width / 2; }
		
		/**
		 * The center y position of the Entity's hitbox.
		 */
		//public function get centerY():Number { return y - originY + height / 2; }
		
		/**
		 * The leftmost position of the Entity's hitbox.
		 */
		//public function get left():Number { return x - originX; }
		
		/**
		 * The rightmost position of the Entity's hitbox.
		 */
		//public function get right():Number { return x - originX + width; }
		
		/**
		 * The topmost position of the Entity's hitbox.
		 */
		//public function get top():Number { return y - originY; }
		
		/**
		 * The bottommost position of the Entity's hitbox.
		 */
		//public function get bottom():Number { return y - originY + height; }
		
		/**
		 * The rendering layer of this Entity. Higher layers are rendered first.
		 */
		public function get layer():int { return _layer; }
		public function set layer(value:int):void
		{
			if (_layer == value) return;
			if (!_world)
			{
				_layer = value;
				return;
			}
			_world.removeRender(this);
			_layer = value;
			_world.addRender(this);
		}
		
		/**
		 * The collision type, used for collision checking.
		 */
		/*public function get type():String { return _type; }
		public function set type(value:String):void
		{
			if (_type == value) return;
			if (!_world)
			{
				_type = value;
				return;
			}
			if (_type) _world.removeType(this);
			_type = value;
			if (value) _world.addType(this);
		}*/
		
		/**
		 * An optional Mask component, used for specialized collision. If this is
		 * not assigned, collision checks will use the Entity's hitbox by default.
		 */
		/*public function get mask():Mask { return _mask; }
		public function set mask(value:Mask):void
		{
			if (_mask == value) return;
			if (_mask) _mask.assignTo(null);
			_mask = value;
			if (value) _mask.assignTo(this);
		}*/
		
		/**
		 * Add a Mask to this Entity, for collisiton testing.
		 * @param	m	The mask to add.
		 * @return	The Mask.
		 */
		public function addMask(m:Mask):Mask
		{
			if (m.parent) return m;
			
			m._siblingNext = maskFirst;
			if (maskFirst) maskFirst._siblingPrev = m;
			maskFirst = m;
			m.parent = this;
			
			if (_world)
				_world.addType(m);
				
			return m;
		}
		
		/**
		 * Remove a Mask from this Entity.
		 * @param	m	The mask to remove.
		 * @return	The Mask.
		 */
		public function removeMask(m:Mask):Mask
		{
			if (m.parent != this) return m;
			
			if (m._siblingNext) m._siblingNext._siblingPrev = m._siblingPrev;
			if (m._siblingPrev) m._siblingPrev._siblingNext = m._siblingNext;
			m._siblingNext = m._siblingPrev = null;
			m.parent = null;
			
			if (_world)
				_world.removeType(m);
				
			return m;
		}
		
		/**
		 * Graphical component to render to the screen.
		 */
		public function get graphic():Graphic { return _graphic; }
		public function set graphic(value:Graphic):void
		{
			if (_graphic == value) return;
			_graphic = value;
			if (value && value._assign != null) value._assign();
		}
		
		/**
		 * Adds the graphic to the Entity via a Graphiclist.
		 * @param	g		Graphic to add.
		 */
		public function addGraphic(g:Graphic):Graphic
		{
			if (graphic is Graphiclist) (graphic as Graphiclist).add(g);
			else
			{
				var list:Graphiclist = new Graphiclist;
				if (graphic) list.add(graphic);
				list.add(g);
				graphic = list;
			}
			return g;
		}
		
		/**
		 * Sets the Entity's hitbox properties.
		 * @param	width		Width of the hitbox.
		 * @param	height		Height of the hitbox.
		 * @param	originX		X origin of the hitbox.
		 * @param	originY		Y origin of the hitbox.
		 */
		/*public function setHitbox(width:int = 0, height:int = 0, originX:int = 0, originY:int = 0):void
		{
			this.width = width;
			this.height = height;
			this.originX = originX;
			this.originY = originY;
		}*/
		
		/**
		 * Sets the Entity's hitbox to match that of the provided object.
		 * @param	o		The object defining the hitbox (eg. an Image or Rectangle).
		 */
		/*public function setHitboxTo(o:Object):void
		{
			if (o is Image || o is Rectangle) setHitbox(o.width, o.height, -o.x, -o.y);
			else
			{
				if (o.hasOwnProperty("width")) width = o.width;
				if (o.hasOwnProperty("height")) height = o.height;
				if (o.hasOwnProperty("originX") && !(o is Graphic)) originX = o.originX;
				else if (o.hasOwnProperty("x")) originX = -o.x;
				if (o.hasOwnProperty("originY") && !(o is Graphic)) originY = o.originY;
				else if (o.hasOwnProperty("y")) originY = -o.y;
			}
		}*/
		
		/**
		 * Sets the origin of the Entity.
		 * @param	x		X origin.
		 * @param	y		Y origin.
		 */
		/*public function setOrigin(x:int = 0, y:int = 0):void
		{
			originX = x;
			originY = y;
		}*/
		
		/**
		 * Center's the Entity's origin (half width & height).
		 */
		/*public function centerOrigin():void
		{
			originX = width / 2;
			originY = height / 2;
		}*/
		
		/**
		 * Calculates the distance from another Entity.
		 * @param	e				The other Entity.
		 * @param	useHitboxes		If hitboxes should be used to determine the distance. If not, the Entities' x/y positions are used.
		 * @return	The distance.
		 */
		/*public function distanceFrom(e:Entity, useHitboxes:Boolean = false):Number
		{
			if (!useHitboxes) return Math.sqrt((x - e.x) * (x - e.x) + (y - e.y) * (y - e.y));
			return FP.distanceRects(x - originX, y - originY, width, height, e.x - e.originX, e.y - e.originY, e.width, e.height);
		}*/
		
		/**
		 * Calculates the distance from this Entity to the point.
		 * @param	px				X position.
		 * @param	py				Y position.
		 * @param	useHitbox		If hitboxes should be used to determine the distance. If not, the Entities' x/y positions are used.
		 * @return	The distance.
		 */
		/*public function distanceToPoint(px:Number, py:Number, useHitbox:Boolean = false):Number
		{
			if (!useHitbox) return Math.sqrt((x - px) * (x - px) + (y - py) * (y - py));
			return FP.distanceRectPoint(px, py, x - originX, y - originY, width, height);
		}*/
		
		/**
		 * Calculates the distance from this Entity to the rectangle.
		 * @param	rx			X position of the rectangle.
		 * @param	ry			Y position of the rectangle.
		 * @param	rwidth		Width of the rectangle.
		 * @param	rheight		Height of the rectangle.
		 * @return	The distance.
		 */
		/*public function distanceToRect(rx:Number, ry:Number, rwidth:Number, rheight:Number):Number
		{
			return FP.distanceRects(rx, ry, rwidth, rheight, x - originX, y - originY, width, height);
		}*/
		
		/**
		 * Gets the class name as a string.
		 * @return	A string representing the class name.
		 */
		public function toString():String
		{
			var s:String = String(_class);
			return s.substring(7, s.length - 1);
		}
		
		/**
		 * Moves the Entity by the amount, retaining integer values for its x and y.
		 * @param	x			Horizontal offset.
		 * @param	y			Vertical offset.
		 * @param	solidType	An optional collision type (or array of types) to stop flush against upon collision.
		 * @param	sweep		If sweeping should be used (prevents fast-moving objects from going through solidType).
		 */
		public function moveBy(x:Number, y:Number, solidType:Object = null, sweep:Boolean = false):void
		{
			_moveX += x;
			_moveY += y;
			x = Math.round(_moveX);
			y = Math.round(_moveY);
			_moveX -= x;
			_moveY -= y;
			if (solidType)
			{
				var sign:int, m:Mask;
				if (x != 0)
				{
					if (sweep || collide(solidType, this.x + x, this.y))
					{
						sign = x > 0 ? 1 : -1;
						while (x != 0)
						{
							if ((m = collide(solidType, this.x + sign, this.y)))
							{
								if (moveCollideX(m)) break;
								else this.x += sign;
							}
							else this.x += sign;
							x -= sign;
						}
					}
					else this.x += x;
				}
				if (y != 0)
				{
					if (sweep || collide(solidType, this.x, this.y + y))
					{
						sign = y > 0 ? 1 : -1;
						while (y != 0)
						{
							if ((m = collide(solidType, this.x, this.y + sign)))
							{
								if (moveCollideY(m)) break;
								else this.y += sign;
							}
							else this.y += sign;
							y -= sign;
						}
					}
					else this.y += y;
				}
			}
			else
			{
				this.x += x;
				this.y += y;
			}
		}
		
		/**
		 * Moves the Entity to the position, retaining integer values for its x and y.
		 * @param	x			X position.
		 * @param	y			Y position.
		 * @param	solidType	An optional collision type (or array of types) to stop flush against upon collision.
		 * @param	sweep		If sweeping should be used (prevents fast-moving objects from going through solidType).
		 */
		public function moveTo(x:Number, y:Number, solidType:Object = null, sweep:Boolean = false):void
		{
			moveBy(x - this.x, y - this.y, solidType, sweep);
		}
		
		/**
		 * Moves towards the target position, retaining integer values for its x and y.
		 * @param	x			X target.
		 * @param	y			Y target.
		 * @param	amount		Amount to move.
		 * @param	solidType	An optional collision type (or array of types) to stop flush against upon collision.
		 * @param	sweep		If sweeping should be used (prevents fast-moving objects from going through solidType).
		 */
		public function moveTowards(x:Number, y:Number, amount:Number, solidType:Object = null, sweep:Boolean = false):void
		{
			_point.x = x - this.x;
			_point.y = y - this.y;
			
			if (_point.x*_point.x + _point.y*_point.y > amount*amount) {
				_point.normalize(amount);
			}
			
			moveBy(_point.x, _point.y, solidType, sweep);
		}
		
		/**
		 * When you collide with an Mask on the x-axis with moveTo() or moveBy().
		 * @param	m		The Mask you collided with.
		 */
		public function moveCollideX(m:Mask):Boolean
		{
			return true;
		}
		
		/**
		 * When you collide with an Entity on the y-axis with moveTo() or moveBy().
		 * @param	m		The Mask you collided with.
		 */
		public function moveCollideY(m:Mask):Boolean
		{
			return true;
		}
		
		/**
		 * Clamps the Entity's hitbox on the x-axis.
		 * @param	left		Left bounds.
		 * @param	right		Right bounds.
		 * @param	padding		Optional padding on the clamp.
		 */
		/*public function clampHorizontal(left:Number, right:Number, padding:Number = 0):void
		{
			if (x - originX < left + padding) x = left + originX + padding;
			if (x - originX + width > right - padding) x = right - width + originX - padding;
		}*/
		
		/**
		 * Clamps the Entity's hitbox on the y axis.
		 * @param	top			Min bounds.
		 * @param	bottom		Max bounds.
		 * @param	padding		Optional padding on the clamp.
		 */
		/*public function clampVertical(top:Number, bottom:Number, padding:Number = 0):void
		{
			if (y - originY < top + padding) y = top + originY + padding;
			if (y - originY + height > bottom - padding) y = bottom - height + originY - padding;
		}*/
		
		/**
		 * The Entity's instance name. Use this to uniquely identify single
		 * game Entities, which can then be looked-up with World.getInstance().
		 */
		public function get name():String { return _name; }
		public function set name(value:String):void
		{
			if (_name == value) return;
			if (_name && _world) _world.unregisterName(this);
			_name = value;
			if (_name && _world) _world.registerName(this);
		}
		
		public function getClass ():Class { return _class; }
		
		/**
		 * Temporarily set x and y to specified values, saving their current ones.
		 * @param	tempX	Temporary value for x coordinate.
		 * @param	tempY	Temporary value for y coordinate.
		 */
		public function setTempXY(tempX:Number, tempY:Number):void
		{
			_x = x;
			x = tempX;
			
			_y = y;
			y = tempY;
		}
		
		/**
		 * Restore x and y values previously saved with setTempXY.
		 */
		public function restoreXY():void
		{
			x = _x;
			y = _y;
		}
		
		// Entity information.
		/** @private */ internal var _class:Class;
		/** @private */ internal var _world:World;
		/** @private */ internal var _name:String;
		/** @private */ internal var _layer:int;
		/** @private */ internal var _updatePrev:Entity;
		/** @private */ internal var _updateNext:Entity;
		/** @private */ internal var _renderPrev:Entity;
		/** @private */ internal var _renderNext:Entity;
		/** @private */ internal var _recycleNext:Entity;
		
		// Collision information.
		/** @private */ internal var maskFirst:Mask;
		/** @private */ private var _x:Number; // temp
		/** @private */ private var _y:Number; // temp
		/** @private */ private var _moveX:Number = 0;
		/** @private */ private var _moveY:Number = 0;
		
		// Rendering information.
		/** @private */ internal var _graphic:Graphic;
		/** @private */ private var _point:Point = FP.point;
		/** @private */ private var _camera:Point = FP.point2;
	}
}
