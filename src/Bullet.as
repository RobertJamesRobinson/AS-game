package
{
	import flash.display.Sprite;
	
	public class Bullet
	{
		private var bullet:Sprite;
		private var angle:Number;
		private var speed:Number;
		private var x:Number;
		private var y:Number;
		private var fuel:Number;
		private var startingFuel:Number=30;	//dictates how far the bullet will go, each move reduces the fuel by 1. 75 considered max, more than this and a constant stream of bullets cannot be maintained.
		private var bulletSpeed:Number=10;	//dictates the speed of the bullet, this is how many pixels each frame
		
		//constructor, create a new bullet sprite, each bullet has an x and y location but the sprite locations are handled in the calling class
		public function Bullet()
		{
			speed=0;
			angle=0;
			fuel=0;
			x=-20;
			y=-20;
			
			bullet=new Sprite();
			
			//each bullet consists of two concentric circles, outer cirle is white, inner circle is black, makes the bullet visible on a variety of backgrounds
			bullet.graphics.beginFill(0xffffff);
			bullet.graphics.drawCircle(0,0,2);
			bullet.graphics.endFill();
			
			bullet.graphics.beginFill(0x000000);
			bullet.graphics.drawCircle(0,0,1);
			bullet.graphics.endFill();
			
			bullet.visible=false;
		}
		
		//return the bullet sprite to the calling class
		public function getGraphic():Sprite
		{
			return bullet;
		}
		
		//return the x coordinate location of the bullet to the calling class
		public function getX():Number
		{
			return x;
		}
		
		//return the y coordinate location of the bullet to the calling class
		public function getY():Number
		{
			return y;
		}
		
		//returns whether or not the bullet is still alive, returns true or false, bullet is alive if it has fuel
		//this function also sets the visibility of the bullet, for some reason this works better, bullets dont end up sitting on the screen doing nothing!
		public function isAlive():Boolean
		{
			if(fuel>0)
			{
				bullet.visible=true;
				return true;
			}
			else
			{
				bullet.visible=false;
				return false;
			}
		}
		
		//ship coordinates, ship speed, ship trajectory and ship heading angles are in degrees
		public function fireBullet(startX:Number,startY:Number,shipSpeed:Number,shipAngle:Number,firingAngle:Number):void
		{
			var tempA:Number=0;
			var tempX:Number=0;
			var tempY:Number=0;
			var resX:Number=0;
			var resY:Number=0;
			
			fuel=startingFuel;	//set bullet fuel
			x=startX;	//set initial x coordinate to the same as the ship
			y=startY;	//set initial y coordinate to the same as the ship
			
			//get current ship angle, convert to radians
			tempA=firingAngle*(Math.PI/180);
			
			//set the bullets initial angle
			angle=tempA;
			
			//adjust bullets position to shoot from the front of the ship
			x=x+Math.cos(angle)*15;
			y=y+Math.sin(angle)*15;
			
			//set bullet speed, basic speed of bullet + vector of ship trajectory
			
			//starting from the origin (offset is zero), find the result of applying the ships vector and put values into tempX and tempY
			tempX=Math.cos(shipAngle)*shipSpeed;
			tempY=Math.sin(shipAngle)*shipSpeed;
		
			//starting from the last point (offset is x and y), find the result of applying the second vector (bullet vector) and put values into resX and resY
			resX=Math.cos(tempA)*bulletSpeed+tempX;
			resY=Math.sin(tempA)*bulletSpeed+tempY;
		
			//find resultant, final vector//
			//set resultant vector angle(bullet trajectory)
        	angle=getAngle(0,0,resX,resY);
		
			//set resultant vector magnitude(bullet speed)
			speed=Math.sqrt((resX*resX)+(resY*resY));
		}
		
		public function moveBullet():void
		{
			//if bullet has fuel calculate new x,y coordinates for it
			if(fuel>0)
			{
				//calculate new x,y coordinates
				x=x+Math.cos(angle)*speed;
				y=y+Math.sin(angle)*speed;
				
				//reduce bullet fuel by 1
				fuel--;
			}
			else
			{
				x=-20;
				y=-20;
			}
		}
		
		public function killBullet():void
		{
			fuel=0;
		}
		
		private function getAngle(currentX:Number,currentY:Number,targetX:Number,targetY:Number):Number
		{
			var q:Number;
		 
		    if(targetX>currentX&&targetY<currentY)
		    	q=Math.atan((currentY - targetY)/(currentX - targetX))+(2*Math.PI);
		    
		    else if(targetX<currentX&&targetY>currentY)
		    	q=Math.atan((currentY - targetY)/(currentX - targetX))+Math.PI;
		    
		    else if(targetX<currentX&&targetY<currentY)
		    	q=Math.atan((currentY - targetY)/(currentX - targetX))+Math.PI;
		    
		    else if(targetX>currentX&&targetY>currentY)
		    	q=Math.atan((currentY - targetY)/(currentX - targetX));
		    
		    else if(targetX==currentX&&targetY>currentY)
		    	q=Math.PI/2;
		    
		    else if(targetX==currentX&&targetY<currentY)
		    	q=Math.PI*1.5;
		    
		    else if(targetX>currentX&&targetY==currentY)
		    	q=0;
		    	
		    else if(targetX<currentX&&targetY==currentY)
		    	q=Math.PI;
		    	
			return q;
		}
	}
}