package
{
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	public class Helicoptor
	{
		protected var gameScreenLeftBound:int;
		protected var gameScreenRightBound:int;
		protected var gameScreenTopBound:int;
		protected var gameScreenBottomBound:int;
		
		protected var fire:Sprite = new Sprite();
		protected var heli:Sprite = new Sprite();
		
		//location of heli
		protected var heliXPos:Number;
		protected var heliYPos:Number;
		protected var heliRot:Number;
		
		protected var sounds:SoundManager=new SoundManager();
		protected var explosion:Explosion=new Explosion(1.5);
		
		protected var scaleFactor:Number;
		protected var beingDestroyed:Boolean=false;
		protected var destroyed:Boolean=false;
		protected var counter:int=0;
		
		protected var trajectory:Number; //radians
		protected var velocity:Number;
		protected var explosionAngle:Number;
		
		//some "constants"
		protected var maxFuel:Number=5000;
		protected var hitPointsMax:int=1000;
		protected var maxBulletAmmo:int=400;
		protected var maxRocketAmmo:int=4;
		protected var bulletDelay:int;
		protected var bulletDelayConst:int=3;
		protected var maxSpeed:Number=5; 	//old value = 2.75
		protected var thrust:Number=0.3;	//old value = 0.1
		
		protected var fuel:Number;
		protected var hitPoints:int;
		protected var bulletAmmo:int;
		protected var rocketAmmo:int;
		protected var reloadingState:Boolean=false;
		protected var reloadTimer:Timer; 
		protected var moving:Boolean;
		protected var baseX:int;
		protected var baseY:int;
		
		//weapons
		protected var rocket:Rocket; 
		protected var rocketSprite:Sprite=new Sprite();
		protected var maxBulletsOnScreen:int=10;		//this was set to 75, reduced bullet range and now this can be lower (optimization for crappy computers at school) also only fires once every 3 frames now
		protected var allBulletSprites:Array = new Array(maxBulletsOnScreen); 
		protected var allBullets:Array = new Array(maxBulletsOnScreen);
		protected var heliGraphic:PlayerHeliGraphic=new PlayerHeliGraphic();
		protected var firingBullets:Boolean=false;
		
		public function Helicoptor(size:Number)
		{
			
			scaleFactor=size;
			velocity=0;
			
			fuel=maxFuel;
			trajectory=0;
			
			bulletAmmo=maxBulletAmmo;
			hitPoints=hitPointsMax;
			rocketAmmo=maxRocketAmmo;
			rocket=new Rocket();
			rocketSprite.addChild(rocket.getGraphic());
			fire.addChild(explosion.getGraphic());
			moving=false;
			heli.addChild(heliGraphic.getGraphic());		//new code
			heli.addChild(fire);
			
			heli.scaleX=scaleFactor;
			heli.scaleY=scaleFactor;
			
			heliRot=-45;
			
			heli.visible=false;
			fire.visible=false;
			
			//initialise bullet arrays
			for(var i:int=0;i<maxBulletsOnScreen;i++)
			{
				allBulletSprites[i]=new Sprite();
				allBullets[i]=new Bullet();
				allBulletSprites[i]=allBullets[i].getGraphic();
			}
			reloadTimer=new Timer(1000);
			reloadTimer.addEventListener(TimerEvent.TIMER,reloadTimed);
		}
		public function setScreenBounds(left:int,right:int,top:int,bottom:int):void
		{
			gameScreenLeftBound=left;
			gameScreenRightBound=right;
			gameScreenTopBound=top;
			gameScreenBottomBound=bottom;
		}
		public function setBase(x:int,y:int):void
		{
			baseX=x;
			baseY=y;
		}
		//stop all ongoin sounds caused by this class, clears up a few sound bugs
		public function stopSounds():void
		{
			sounds.stopFlight();
			sounds.stopGun();
			sounds.stopRocket();
			rocket.destroyRocket();
		}
		
		//takes values from the calling class to change the trajectory and speed of the heli. the target angle is the direction of heading, where the mouse is pointed, 
		//angle offset is for move left, right forwards or back from this heading, angles are taken in degrees, converted to radians for the helper function
		public function alterCourse(targetAngle:Number, angleOffset:Number):void
		{
			moving=true;
			targetAngle=targetAngle*(Math.PI/180);//convert to radians
			angleOffset=angleOffset*(Math.PI/180);//convert to radians
			calculateNewTrajectory(targetAngle+angleOffset);
		}
		
		//adjust the current trajectory and velocity to accomodate the new thrust vector
		private function calculateNewTrajectory(targetAngle:Number):void
		{
			var x:Number;
			var y:Number;
			var resX:Number;
			var resY:Number;
			
			//starting from the origin (offset is zero), find the result of applying the first vector (current trajectory) and put values into x and y
			x=Math.cos(trajectory)*velocity;
			y=Math.sin(trajectory)*velocity;
			
			//starting from the last point (offset is x and y), find the result of applying the second vector (target trajectory) and put values into x and y
			resX=Math.cos(targetAngle)*thrust+x;
			resY=Math.sin(targetAngle)*thrust+y;
		
			//find resultant, final vector//
			//set resultant vector angle
	   		trajectory=getAngle(0,0,resX,resY);
		
			//set resultant vector magnitude and limit maximum speed
			velocity=Math.sqrt((resX*resX)+(resY*resY));
			if(velocity>maxSpeed)
				velocity=maxSpeed;
		}
		public function getFuel():int
		{
			return fuel;
		}
		//damage the helicopter by n amount
		public function damage(n:int):void
		{
			if(hitPoints>0)
			{
				hitPoints-=n;
				if(n>0)
					sounds.bulletHit();
			}
			
			if(hitPoints<1&&!beingDestroyed)
				destroy();
		}
		
		//repair the helicopter by n amount
		public function repair(n:int):void
		{
			if(hitPoints<hitPointsMax)
				hitPoints+=n;
		}
		
		//fire a rocket, only one at a time and not when hovering over your base!
		public function fireRocket():void
		{
			if(rocketAmmo>0&&!rocket.isAlive()&&!(getDistance(heliXPos,heliYPos,baseX,baseY)<25))
			{
				rocket.launch(heliXPos,heliYPos,heliRot-45);
				rocketAmmo--;
			}
		}
		public function isRocketAlive():Boolean
		{
			return rocket.isAlive();
		}
		
		public function destroyRocket():void
		{
			if(rocket.isAlive())
				rocket.destroyRocket();
		}
		
		//animates the helicopter, spins blades, blows it up, moves the sprite according to trajectory, also slowly reduces the velocity
		public function animate(mouseX:Number,mouseY:Number,viewX:Number,viewY:Number):void
		{
			//test if being destroyed
			if(beingDestroyed&&counter<150)
			{
				fire.visible=true;
				if(counter==0)
					sounds.Explosion(3);
				explosion.nextFrame();
				
				counter++;
			}
			//heli is now destroyed
			if(counter==150)
			{
				heli.visible=false;
				sounds.stopFlight();
				destroyed=true;
				explosion.reset();
			}
			
			// move the helicopter according to the trajectory and velocity
			heliXPos=heliXPos+Math.cos(trajectory)*velocity;
			heliYPos=heliYPos+Math.sin(trajectory)*velocity;
			
			//slowly decay the velocity
			if(!moving)
				velocity-=0.075;
			if(velocity<0)
				velocity=0;
			moving=false;
			
			//reduce fuel
			if(fuel>0)
				fuel--;
			else
				damage(1);
			
			//fuel alarm
			if(fuel==1000&&!reloadingState)
				sounds.alarm();
			
			//animate the blades
			//blades.rotation-=55;
			heliGraphic.nextFrame()
			
			//animate the rocket if needed
			rocket.animate(mouseX+viewX,mouseY+viewY);
			
			//check if firing bullets is true and fire a bullet if this is so
			if(firingBullets&&bulletAmmo>0&&!isNearBase())
			{
				sounds.startGun();
				//actually fire a bullet (once every bullDelayConst frames)
				if(bulletDelay==0)
				{	
					for(i=0;i<maxBulletsOnScreen;i++)
					{
						if(!allBullets[i].isAlive())
						{
							allBullets[i].fireBullet(heliXPos,heliYPos,velocity,trajectory,heliRot+45);
							bulletAmmo--
							i=maxBulletsOnScreen;
						}
					}
				}
				bulletDelay--;
				if(bulletDelay<0)
					bulletDelay=bulletDelayConst;
			}
			else
			{
				sounds.stopGun();
			}
			
			//animate the bullets (move them only)
			for(var i:int=0;i<maxBulletsOnScreen;i++)
			{
				//only move a bullet if it is alive
				if(allBullets[i].isAlive())
				{
					allBullets[i].moveBullet();
					
					//set the new locations of the bullets after they have been moved
					allBulletSprites[i].x=allBullets[i].getX()-viewX;
					allBulletSprites[i].y=allBullets[i].getY()-viewY;
					
					//if any bullets hit the side of the map, kill them, preventing bullets from flying off the screen.
					if(allBullets[i].getX()>gameScreenRightBound)
						allBullets[i].killBullet();
					if(allBullets[i].getX()<gameScreenLeftBound)
						allBullets[i].killBullet();
					if(allBullets[i].getY()>gameScreenBottomBound)
						allBullets[i].killBullet();
					if(allBullets[i].getY()<gameScreenTopBound)
						allBullets[i].killBullet();
				}
			}
		}
		
		//check all bullets and test for collision with point targX,targY,
		//add to counter for each bullet that has collided (radius of dist from point targX,targY)
		//return the counter (used to calculate damage per bullet)
		public function testBulletCollisions(targX:Number,targY:Number,dist:Number):int
		{
			var counter:int=0;
		
			for(var i:int=0;i<maxBulletsOnScreen;i++)
			{
				if(allBullets[i].isAlive())
				{
					if(getDistance(allBullets[i].getX(),allBullets[i].getY(),targX,targY)<dist)
					{
						allBullets[i].killBullet();
						counter++;
					}
				}
			}
			return counter;
		}
		
		public function testRocketCollisions(targX:Number,targY:Number,dist:Number):int
		{
			var counter:int=0;
			
			if(getDistance(rocket.getX(),rocket.getY(),targX,targY)<dist&&rocket.isAlive())
			{
				counter=rocket.getDamage();
				rocket.destroyRocket();
				sounds.wilhelm();
			}
			
			return counter;
		}
		
		//adds all bullet sprites to the given sprite, in this case canvas
		public function addBulletSprites(canvas:Sprite):Sprite
		{
			for(var i:int=0;i<maxBulletsOnScreen;i++)
			{
				canvas.addChild(allBulletSprites[i]);
			}
			return canvas;
		}
		
		public function addRocketSprite():Sprite
		{
			return rocketSprite;
		}
		public function getRocketX():Number
		{
			return rocket.getX();
		}
		public function getRocketY():Number
		{
			return rocket.getY();
		}
		//resets a heli from being destroyed, or just from being initialized
		public function reset():void
		{
			destroyed=false;
			fire.visible=false;
			heli.visible=true;
			counter=0;
			beingDestroyed=false;
			hitPoints=hitPointsMax;
			fuel=maxFuel;
			bulletAmmo=maxBulletAmmo;
			rocketAmmo=maxRocketAmmo;
			trajectory=0;
			velocity=0;
		}
		public function softReset():void
		{
			destroyed=false;
			fire.visible=false;
			heli.visible=true;
			counter=0;
			beingDestroyed=false;
			trajectory=0;
			velocity=0;
		}
		//show the heli sprite
		public function show():void
		{
			heli.visible=true;
		}
		
		//return the hit points of the heli
		public function getHP():int
		{
			return hitPoints
		}
		
		//reduce the bullet ammo by n
		public function reduceBulletAmmo(n:int):void
		{
			if(bulletAmmo>0)
				bulletAmmo-=n;
			
		}
		
		//reload bullet ammo by n
		public function increaseBulletAmmo(n:int):void
		{
			if(bulletAmmo<maxBulletAmmo)
				bulletAmmo+=n;
			if(bulletAmmo>maxBulletAmmo)
				bulletAmmo=maxBulletAmmo;
		}
		
		//come 'on isnt this self explanatory? reduce rocket ammo by n
		public function reduceRocketAmmo(n:int):void
		{
			if(rocketAmmo>0)
				rocketAmmo-=n;
			if(rocketAmmo<0)
				rocketAmmo=0;
		}
		
		//increase rocket ammo by n
		public function increaseRocketAmmo(n:int):void
		{
			if(rocketAmmo<maxRocketAmmo)
				rocketAmmo+=n;
			if(rocketAmmo>maxRocketAmmo)
				rocketAmmo=maxRocketAmmo;
		}
		
		//return the rocket ammo left to the calling class
		public function getRocketAmmo():int
		{
			return rocketAmmo;
		}
		
		//returns the bullet ammo 
		public function getBulletAmmo():int
		{
			return bulletAmmo;
		}
		
		//sets the heli for destruction
		public function destroy():void
		{
			beingDestroyed=true;
			sounds.goinDown(2);
			sounds.stopFlight();
			explosion.start();
		}
		
		//hides the heli sprite
		public function hide():void
		{
			heli.visible=false;
		}
		
		//sets the x and y coordinates for the heli sprite 
		public function setXY(x:Number,y:Number):void
		{
			heliXPos=x;
			heliYPos=y;
		}
		
		//returns the helis x coordinate
		public function getX():Number
		{
			return heliXPos;
		}
		
		//returns the helis y coordinate
		public function getY():Number
		{
			return heliYPos;
		}
		
		//returns the heli sprite
		public function getGraphic():Sprite
		{
			return heli;
		}
		
		public function setRotation(r:Number):void
		{
			heliRot=r-45;
			heliGraphic.setRotation(r+45);
		}
		//returns whether or not the heli is destroyed
		public function isDestroyed():Boolean
		{
			return destroyed;
		}
		
		//returns the trajectory of the helicopter in degrees
		public function getTraj():Number
		{
			return trajectory*(180/Math.PI);
		}
		
		//sets the firingBullets state to true or false
		public function setFiringBullets(state:Boolean):void
		{
			firingBullets=state;
		}
		
		//returns the velocity of the helicopter
		public function getVelocity():Number
		{
			return velocity;
		}
		
		//returns the current rotation of the heli in degrees, takes into account the 45 deg offset, so 0deg=right, 180deg=right
		public function getRotation():Number
		{
			return heliRot+45;
		}
		
		//changes the scaling of the heli, takes a percentage, can go over 100%, 100%=the full size set by the constructor
		public function setScale(s:int):void
		{
			heli.scaleX=(s/100)*scaleFactor;
			heli.scaleY=(s/100)*scaleFactor;
		}
		
		//rapidly change the trajectory based on an angle of impact (ang) and the current trajectory
		public function bounceArbitrary(ang:Number):void
		{
			//convert ang to radians
			ang=ang*(Math.PI/180);
		
			//invert impact vector
			ang=(ang-Math.PI);
			
			var x:Number;
			var y:Number;
			var resX:Number;
			var resY:Number;
			
			//starting from the origin (offset is zero), find the result of applying the first vector (current trajectory) and put values into x and y
			x=Math.cos(trajectory)*0.9;
			y=Math.sin(trajectory)*0.9;
			
			//starting from the last point (offset is x and y), find the result of applying the second vector (target trajectory) and put values into x and y
			resX=Math.cos(ang)+x;
			resY=Math.sin(ang)+y;
		
			//find resultant, final vector//
			//set resultant vector angle
	   		trajectory=getAngle(0,0,resX,resY);
		}
		
		//bounce the heli on the x plane
		public function bounceX():void
		{
			trajectory=Math.PI-trajectory;
		}
		
		//bounce the heli on the y plane
		public function bounceY():void
		{
			trajectory=(2*Math.PI)-trajectory;
		}
		
		//move the helicopter along its current trajectory until the distance from the point refX,refY to the heli is > dist
		//helps the collision detection by stopping multiple collisions when objects are still too close after a collision calculation
		public function moveOnTrajectoryFromRef(refX:Number,refY:Number,dist:Number):void
		{
			var x:Number=heliXPos;
			var y:Number=heliYPos;
			
			while(getDistance(x,y,refX,refY)<dist)
			{
				x=x+Math.cos(trajectory);
				y=y+Math.sin(trajectory);
			}
			heliXPos=x;
			heliYPos=y;
		}
		
		//this event is triggered whilst reloading, so that rockets are reloaded slowly
		private function reloadTimed(event:TimerEvent):void
		{
			if(rocketAmmo<maxRocketAmmo)
				{
					rocketAmmo++;
				}
		}
		
		//test distance from base and reload/repair if neccessary
		public function reloading():void
		{
			//if the heli is near the base and speed is low, reload.
			if(isNearBase() && velocity<(maxSpeed/2))
			{
				//only fire the reloading sound once when reloading starts, problem is small movements trigger this too, cant be bothered fixing it
				if(!reloadingState&&(bulletAmmo<maxBulletAmmo||rocketAmmo<maxRocketAmmo||fuel<maxFuel))
					sounds.reload();
				
				//only reload fuel if fuel is less than max, at a rate of 10 units per frame
				if(fuel<maxFuel)
					fuel+=10;
				if(fuel>maxFuel)
					fuel=maxFuel;
				
				//repair the heli by 1 unit each frame, reload bullets by 10 units per frame
				repair(1);
				increaseBulletAmmo(10);
				
				//start the timer for rocket reloads
				reloadingState=true;
				reloadTimer.start();
			}
			else
			{
				//stop the timer for rocket reloads
				reloadingState=false;
				reloadTimer.stop();
			}
		}
		
		//internal function to return an angle between two coordinates, takes radians, returns radians
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
		
		//private function to help with calculating distances between two points
		private function getDistance(x1:Number,y1:Number,x2:Number,y2:Number):Number
		{
			return Math.sqrt(((x1-x2)*(x1-x2))+((y1-y2)*(y1-y2)));
		}
		
		//returns true if player is near the base (within 25 pixels of its center)
		public function isNearBase():Boolean
		{
			return (getDistance(heliXPos,heliYPos,baseX,baseY)<25);
		}
	}
}