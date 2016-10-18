package
{
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	public class EnemyHelicoptor
	{		
		protected var gameScreenLeftBound:int;
		protected var gameScreenRightBound:int;
		protected var gameScreenTopBound:int;
		protected var gameScreenBottomBound:int;
		
		protected var strategyTimer:Timer;
		
		protected var fire:Sprite = new Sprite();
		//protected var blades:Sprite = new Sprite();
		//protected var heliBody:Sprite = new Sprite();
		protected var heli:Sprite = new Sprite();
		protected var enemyGraphic:EnemyHeliGraphic=new EnemyHeliGraphic();
		protected var heliX:Number;
		protected var heliY:Number;
		protected var enemyRot:Number;
		
		protected var sounds:SoundManager=new SoundManager();
		protected var explosion:Explosion=new Explosion(1.5);
		
		protected var scaleFactor:Number;
		protected var beingDestroyed:Boolean=false;
		protected var destroyed:Boolean=false;
		protected var counter:int=0;
		
		protected var trajectory:Number; //radians
		protected var velocity:Number;
		protected var maxSpeed:Number;
		protected var thrust:Number;
		protected var currentStrategy:int;
		
		protected var hitPoints:int;
		protected var hitPointsMax:int=10;
		protected var bulletAmmo:int;
		protected var maxBulletAmmo:int=100;
		protected var explosionAngle:Number;
//		protected var blast:Boolean=false; //detects if under the influenece of a blast
//		protected var blastCounter:int=0;
//		
		protected var targX:Number;
		protected var targY:Number;
		protected var targTraj:Number;
		protected var targVelocity:Number;
		protected var targHeading:Number;
		protected var hovering:Boolean;
		protected var enemyBaseX:int;
		protected var enemyBaseY:int;
		//weapons
		protected var maxBulletsOnScreen:int=10;
		protected var allBulletSprites:Array = new Array(maxBulletsOnScreen); 
		protected var allBullets:Array = new Array(maxBulletsOnScreen);
		protected var firingBullets:Boolean=false;
		protected var bulletTimer:int=0;
		protected var bulletDelay:int=10;
		
		public function EnemyHelicoptor(size:Number)
		{
			
			//set helicopter variables
			scaleFactor=size;
			velocity=0;
			maxSpeed=1.8;
			trajectory=0;
			thrust=0.075;
			hovering=false;
			bulletAmmo=maxBulletAmmo;
			hitPoints=hitPointsMax;
			
			//add the explosion to the helicoptior (dont worry its invisible at this stage)
			fire.addChild(explosion.getGraphic());
			
			//heliG.x=-186;
			//heliG.y=-186;
			//heliBody.addChild(heliG);
			
			//heliBladesG.x=-106;
			//heliBladesG.y=-106;
			//blades.addChild(heliBladesG);
			
			heli.addChild(enemyGraphic.getGraphic());
			//heli.addChild(blades);
			heli.addChild(fire);
			
			heliX=0;
			heliY=0;
			
			heli.scaleX=scaleFactor;
			heli.scaleY=scaleFactor;
			enemyRot=-45;
			
			fire.visible=false;
			heli.visible=false;
			
			//initialise bullet arrays, there are two arrays 1 stores the bullet sprites
			//the other stores each bullets data, the bullet class stores all the bullets properties
			for(var i:int=0;i<maxBulletsOnScreen;i++)
			{
				allBulletSprites[i]=new Sprite();
				allBullets[i]=new Bullet();
				allBulletSprites[i]=allBullets[i].getGraphic();
			}
			
			//each helicoptor will change its strategy at a predefined time interval
			//this interval is initially set between 100 and 1000 ms, so some enemys respond quicker than others
			//this stops all the helicoptors on the screen appearing to do everything in a 
			//syncronised fashion
			strategyTimer=new Timer(Math.random()*900+100);
			strategyTimer.start();
			strategyTimer.addEventListener(TimerEvent.TIMER,changeStrategy);	
		}
		public function setScreenBounds(left:int,right:int,top:int,bottom:int):void
		{
			gameScreenLeftBound=left;
			gameScreenRightBound=right;
			gameScreenTopBound=top;
			gameScreenBottomBound=bottom;
		}
		public function setEnemyBase(x:int,y:int):void
		{
			enemyBaseX=x;
			enemyBaseY=y;
		}
		//takes values from the calling class to change the trajectory and speed of the heli. the target angle is the direction of heading, where the mouse is pointed, 
		//angle offset is for move left, right forwards or back from this heading, angles are taken in degrees, converted to radians for the helper function
		public function alterCourse(targetAngle:Number, angleOffset:Number):void
		{
			targetAngle=targetAngle//*(Math.PI/180);//convert to radians no need to convert to radians as this will be called internally
			angleOffset=angleOffset*(Math.PI/180);//convert to radians
			calculateNewTrajectory(targetAngle+angleOffset);
		}
		//adjusts the helis parameters to make it harder to kill
		public function adjustParameters(hpMod:Number, thrustMod:Number, maxspeedMod:Number):void
		{
			hitPoints=hpMod;
			hitPointsMax=hpMod;
			thrust=thrustMod;
			maxSpeed=maxspeedMod;
		}
		
		//adjust the current trajectory and velocity to accomodate the new thrust vector
		private function calculateNewTrajectory(targetAngle:Number):void
		{
			var x:Number;
			var y:Number;
			var resX:Number;
			var resY:Number;
			
			//uses simple vector addition, add two vectors together and find the resultant vector from the origin to the end of the second vector
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
			if(hovering)
				velocity=0;
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
		
		//this function gets called every frame
		public function animate(viewX:Number,viewY:Number):void
		{
			//test to see if helicopter is currently being destroyed and perform the explosion animation
			//the explosion will occur for 150 frames, uses the counter variable to keep track of this
			if(beingDestroyed&&counter<150)
			{
				fire.visible=true;
				if(counter==0)
				{
					sounds.Explosion(3);
					sounds.goinDown(1);
				}	
				explosion.nextFrame();
				counter++;
			}
			//if the helicoptor is completely destroyed (counter gets to 150) set it to destroyed (invisible)
			if(counter==150)
			{
				heli.visible=false;
				heliX=-100;
				heliY=-100;
				destroyed=true;
				explosion.reset();
			}
			
			// move the helicopter according to its current trajectory and velocity
			heliX=heliX+Math.cos(trajectory)*velocity;
			heliY=heliY+Math.sin(trajectory)*velocity;
			
			//stay inside the game boundaries
			if(heliX>gameScreenRightBound-50)
				heliX=gameScreenRightBound-50;		
			if(heliY>gameScreenBottomBound-50)
				heliY=gameScreenBottomBound-50;
			if(heliX<gameScreenLeftBound+50)
				heliX=gameScreenLeftBound+50;
			if(heliY<gameScreenTopBound+50)
				heliY=gameScreenTopBound+50;
		
			//slowly decay the velocity
			velocity-=0.01;
			if(velocity<0)
				velocity=0;
			
			//animate the blades
			enemyGraphic.nextFrame();
			
			//set the rotation of the helis body
			enemyGraphic.setRotation(enemyRot+90);
			//blades.rotation-=55;
			
			//check if firing bullets is true and fire a bullet if this is so
			if(firingBullets&&bulletAmmo>0&&!beingDestroyed)
			{
				if(bulletTimer==0)
				{
					for(i=0;i<maxBulletsOnScreen;i++)
					{
						if(!allBullets[i].isAlive())
						{
							allBullets[i].fireBullet(heliX,heliY,velocity,trajectory,enemyRot+45);
							bulletAmmo--
							i=maxBulletsOnScreen;
						}
					}
				}
				bulletTimer++;
				if(bulletTimer==bulletDelay)
					bulletTimer=0;
				
			}
			//animate the bullets (move them only)
			for(var i:int=0;i<maxBulletsOnScreen;i++)
			{
				if(allBullets[i].isAlive())
				{
					allBullets[i].moveBullet();
					
					allBulletSprites[i].x=allBullets[i].getX()-viewX;
					allBulletSprites[i].y=allBullets[i].getY()-viewY;
					
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
		//return the counter
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
		
		//returns the velocity of the helicopter (vector magnitude)
		public function getVelocity():Number
		{
			return velocity;
		}
		
		//repair the helicopter by n amount
		public function repair(n:int):void
		{
			if(hitPoints<hitPointsMax)
				hitPoints+=n;
			if(hitPoints>hitPointsMax)
				hitPoints=hitPointsMax;
		}
		
		//resets the helicoptor and gives it a new starting point
		public function reset():void
		{
			var z:int;
			
			destroyed=false;	
			fire.visible=false;
			heli.visible=true;
			hitPoints=hitPointsMax;
			counter=0;
			beingDestroyed=false;
			bulletAmmo=maxBulletAmmo;
			trajectory=0;
			velocity=0;
			
			//set new location somewhere on the edge of the map
			z=Math.random()*100;	//used to decide on which edge of the screen the new heli should appear
			heliX=Math.random()*(gameScreenRightBound-100)+50;
			heliY=Math.random()*(gameScreenBottomBound-100)+50;
			if(z>=0 && z<25)
				heliX=50;
			if(z>=25 && z<50)
				heliX=gameScreenRightBound-50;
			if(z>=50 && z<75)
				heliY=50;
			if(z>=75)
				heliY=gameScreenBottomBound-50;
		}
		
		//reduce the heli health by n amount
		public function damage(n:int):void
		{
			var score:int=0;
			if(hitPoints>0)
			{
				hitPoints-=n;
				if(n>0)
					sounds.bulletHit();
				
				if(hitPoints<0)
					hitPoints=0;
				
				if(hitPoints==0)
					destroy();
			}
			
			
		}
		
		//sets the heli to being destroyed
		public function destroy():void
		{
			beingDestroyed=true;
			explosion.start();
		}
		
		//returns the current hit points of the heli
		public function getHP():int
		{
			return hitPoints;
		}
		
		//make the heli visible
		public function show():void
		{
			heli.visible=true;
		}
		
		//make the heli invisible
		public function hide():void
		{
			heli.visible=false;
		}
		
		//arbitrarily set the x and y coordinates of the heli
		public function setXY(x:Number,y:Number):void
		{
			heliX=x;
			heliY=y;
		}
		
		//return the x coordinate of the heli
		public function getX():Number
		{
			return heliX;
		}
		
		//return the y coordinate of the heli
		public function getY():Number
		{
			return heliY;
		}
		
		//returns the associated sprite for this heli
		public function getGraphic():Sprite
		{
			return heli;
		}
		
		//arbitrarily set the rotation of the heli (note the 45 deg offset for the sprites image)
		public function setRotation(r:Number):void
		{
			enemyRot=r-45;
			enemyGraphic.setRotation(enemyRot);
		}
		
		//returns the state of the destroyed boolean variable, if this heli is destroyed, returns true
		public function isDestroyed():Boolean
		{
			return destroyed;
		}
		
		//returns whether or not this heli is in the process of being destroyed, used to stop scoreing on an already destroyed heli 
		public function isBeingDestroyed():Boolean
		{
			return beingDestroyed;
		}
		
		//returns the rotation of the heli sprite, (note the 45 degree offset for the heli graphic)
		public function getRotation():Number
		{
			return enemyRot+45;
		}
		
		//set the scale factor of the heli sprite
		public function setScale(s:int):void
		{
			heli.scaleX=(s/100)*scaleFactor;
			heli.scaleY=(s/100)*scaleFactor;
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
		}
		
		//returns the bullet ammo 
		public function getBulletAmmo():int
		{
			return bulletAmmo;
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
		public function setTrajectory(ang:Number):void
		{
			trajectory=ang;
		}
		public function setVelocity(vel:Number):void
		{
			velocity=vel
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
	   		
			//halve the speed of the heli after impact
			velocity/=2; 
		}
		
		//bounce the heli on the x plane
		public function bounceX():void
		{
			trajectory=Math.PI-trajectory;
			velocity/=2;
		}
		
		//bounce the heli on the y plane
		public function bounceY():void
		{
			trajectory=(2*Math.PI)-trajectory;
			velocity/=2;
		}
		
		//move the helicopter along its current trajectory until the distance from the point refX,refY to the heli is > dist, used for arbitrary bounces where the distance between the two
		//objects may cause the bounce to occur again, causing game bugs
		public function moveOnTrajectoryFromRef(refX:Number,refY:Number,dist:Number):void
		{
			var startingX:Number=heliX;
			var startingY:Number=heliY;
			
			while(getDistance(startingX,startingY,refX,refY)<dist)
			{
				startingX=startingX+Math.cos(trajectory);
				startingY=startingY+Math.sin(trajectory);
			}
			heliX=startingX;
			heliY=startingY;
		}
		
		//test distance from base and reload/repair if neccessary
		public function reloading():void
		{
			repair(5);
			bulletAmmo=maxBulletAmmo;
		}
		
		//decision made for the heli strategy here
		private function changeStrategy(event:TimerEvent):void
		{
			//enemy AI logic goes here
			/*
			logic elements guide
			getDistance(targX,targY,enemyBaseX,enemyBaseY)<40					##the target is at his base
			getDistance(heliX,heliY,targX,targY)<200			##the target is within 200 pixels
			hitPoints<hitPointsMax*0.5							##current hit points are less than 50%
			bulletAmmo<maxBulletAmmo*0.5						##current ammo is less than 50%
			targVelocity<1										##the target is moving very slowly
			getDistance(heliX,heliY,targX,targY)<150			##the target is within 150 pixels
			*/
			if(getDistance(targX,targY,enemyBaseX,enemyBaseY)<40&&getDistance(targX,targY,heliX,heliY)>250)
				reloading();	
			if(targVelocity<1)
				currentStrategy=0;
			else
				currentStrategy=1;
			if(getDistance(heliX,heliY,targX,targY)<300)
				currentStrategy=2;
			if(getDistance(targX,targY,enemyBaseX,enemyBaseY)<40&&hitPoints<hitPointsMax*0.5&&bulletAmmo<maxBulletAmmo*0.5)
				currentStrategy=3;
			if(getDistance(heliX,heliY,targX,targY)<100)
				currentStrategy=4;
			if(bulletAmmo==0)
				currentStrategy=3;
			if(beingDestroyed)
				currentStrategy=3;	
		}
		
		//the current strategy is applied here
		public function pilot(ntargX:Number,ntargY:Number,ntargTraj:Number,ntargVelocity:Number,ntargHeading:Number):void
		{
			//set new values into remembered values so changestrategy can access them later for deciding the strategy
			targX=ntargX;
			targY=ntargY;
			targTraj=ntargTraj;
			targVelocity=ntargVelocity;
			targHeading=ntargHeading;
			
			var targetAngle:Number=getAngle(heliX,heliY,targX,targY);
//			if(!blast)
//			{
				switch(currentStrategy)
				{
					//stalking manuevures
					case 0:			//head directly to target with out firing, rotation = target
						hovering=false;
						enemyRot=targetAngle*(180/Math.PI)-45;
						alterCourse(targetAngle,0);
						setFiringBullets(false);
						break;
					case 1:			//move to behind target with out firing, rotation = target
						hovering=false;
						enemyRot=targetAngle*(180/Math.PI)-45;
						alterCourse(getAngle(heliX,heliY,findXPoint(targX,targY,(180-targHeading)*(Math.PI/180),150),findYPoint(targX,targY,(180-targHeading)*(Math.PI/180),150)),0);
						setFiringBullets(false);
						break;
					case 2:			//move towards target firing
						hovering=false;
						enemyRot=targetAngle*(180/Math.PI)-45;
						alterCourse(targetAngle,0);
						setFiringBullets(true);
						break;
					case 3:			//move away from target
						hovering=false;
						enemyRot=targetAngle*(180/Math.PI)-45-180;
						alterCourse(targetAngle-Math.PI,0);
						setFiringBullets(false);
						break;
					case 4:			//hover and fire, face target
						hovering=true;
						enemyRot=targetAngle*(180/Math.PI)-45;
						alterCourse(targetAngle,0);
						setFiringBullets(true);
				}
//			}
//			else
//			{
//				blastCounter++;
//				if(blastCounter===60)
//				{
//					blast=false;
//					blastCounter=0;
//				}
//			}
		}
//		public function setBlast():void
//		{
//			blast=true;
//		}
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
		    else
		    	q=0	
		    	    	
			return q;
		}
		
		//returns the distance between two points
		private function getDistance(x1:Number,y1:Number,x2:Number,y2:Number):Number
		{
			return Math.sqrt(((x1-x2)*(x1-x2))+((y1-y2)*(y1-y2)));
		}
		
		//return the x coordinate when moving the distance dist from point origX,origY at an angle of ang(degrees)
		private function findXPoint(origX:Number, origY:Number, ang:Number, dist:Number):Number
		{
			return Math.cos(ang*(Math.PI/180))*dist+origX;
		}
		
		//return the y coordinate when moving the distance dist from point origX,origY at an angle of ang(degrees)
		private function findYPoint(origX:Number, origY:Number, ang:Number, dist:Number):Number
		{
			return Math.sin(ang*(Math.PI/180))*dist+origY;
		}
	}
}