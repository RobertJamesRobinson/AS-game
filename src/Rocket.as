package
{
	import flash.display.Bitmap;
	import flash.display.Sprite;

	public class Rocket
	{
		[Embed(source=".\\images\\rocket.png")]
   		protected var rocketGraphic:Class;
		protected var rocketG:Bitmap = new rocketGraphic();
		protected var rocket:Sprite = new Sprite();
		protected var fuel:int=0;
		protected var startingFuel:int=500;
		protected var damageDone:int = 150;
		
		protected var sounds:SoundManager=new SoundManager();
		
		protected var trajectory:Number = 0;
		protected var speed:Number = 8;
		protected var active:Boolean=false;
		protected var rocketX:Number;
		protected var rocketY:Number;
		
		public function Rocket()
		{
			rocketG.x=-10;
			rocketG.y=-3;
			rocket.addChild(rocketG);
			rocket.visible=false;
			rocketX=50;
			rocketY=50;
		}
		public function launch(startX:Number,startY:Number,firingAngle:Number):void
		{
			var tempA:Number=0;
			
			if(!active)
			{
				active=true;
				rocket.visible=true;
				sounds.rocketLaunch();
				sounds.startRocket();
				
				fuel=startingFuel;	//set rocket fuel
				var x:Number=startX;	//set initial x coordinate to the same as the ship
				var y:Number=startY;	//set initial y coordinate to the same as the ship
				
				//get current ship angle, convert to radians
				tempA=firingAngle*(Math.PI/180);
				
				//set the rocket initial angle
				trajectory=tempA;
				
				//adjust rocket position to shoot from the front of the ship
				x=x+Math.cos(trajectory)*15;
				y=y+Math.sin(trajectory)*15;
				
				rocketX=x;
				rocketY=y;
	        	trajectory=tempA;
			}
		}
		
		public function animate(x:Number,y:Number):void
		{
			if(active)
			{
				if(getDistance(rocketX,rocketY,x,y)>5)
					trajectory=getAngle(rocketX,rocketY,x,y);
					
				rocket.rotation=trajectory*(180/Math.PI);
				moveRocket();
			}
		}
		public function destroyRocket():void
		{
			fuel=0;
			rocket.visible=false;
			active=false;
			rocketX=-20;
			rocketY=-20;
			sounds.Explosion(1);
			sounds.stopRocket();
		}
		public function getX():Number
		{
			return rocketX;
		}
		public function getY():Number
		{
			return rocketY;
		}
		public function isAlive():Boolean
		{
			return active;
		}
		public function getDamage():Number
		{
			return damageDone;
		}
		private function moveRocket():void
		{
			//if rocket has fuel calculate new x,y coordinates for it
			if(fuel>0)
			{
				//calculate new x,y coordinates
				rocketX=rocketX+Math.cos(trajectory)*speed;
				rocketY=rocketY+Math.sin(trajectory)*speed;
				
				
				//reduce rocket fuel by 1
				fuel--;
			}
			else
			{
				destroyRocket();
			}
		}
		public function getGraphic():Sprite
		{
			return rocket;
		}
		public function addRocketSprite(canvas:Sprite):Sprite
		{
			canvas.addChild(rocket);
			return canvas;
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
		private function getDistance(x1:Number,y1:Number,x2:Number,y2:Number):Number
		{
			return Math.sqrt(((x1-x2)*(x1-x2))+((y1-y2)*(y1-y2)));
		}
	}
}