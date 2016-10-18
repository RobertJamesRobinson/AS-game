package
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	
	public class Explosion
	{	//embed the frames for the explosion animation
		[Embed(source=".\\ExplosionGraphics\\bang0.png")]
   		protected var bang0Graphic:Class;
		protected var bang0G:Bitmap = new bang0Graphic();
		
		[Embed(source=".\\ExplosionGraphics\\bang1.png")]
   		protected var bang1Graphic:Class;
		protected var bang1G:Bitmap = new bang1Graphic();
		
		[Embed(source=".\\ExplosionGraphics\\bang2.png")]
   		protected var bang2Graphic:Class;
		protected var bang2G:Bitmap = new bang2Graphic();
		
		[Embed(source=".\\ExplosionGraphics\\bang3.png")]
   		protected var bang3Graphic:Class;
		protected var bang3G:Bitmap = new bang3Graphic();
		
		[Embed(source=".\\ExplosionGraphics\\bang4.png")]
   		protected var bang4Graphic:Class;
		protected var bang4G:Bitmap = new bang4Graphic();
		
		[Embed(source=".\\ExplosionGraphics\\bang5.png")]
   		protected var bang5Graphic:Class;
		protected var bang5G:Bitmap = new bang5Graphic();
		
		[Embed(source=".\\ExplosionGraphics\\bang6.png")]
   		protected var bang6Graphic:Class;
		protected var bang6G:Bitmap = new bang6Graphic();
		
		[Embed(source=".\\ExplosionGraphics\\bang7.png")]
   		protected var bang7Graphic:Class;
		protected var bang7G:Bitmap = new bang7Graphic();
		
		[Embed(source=".\\ExplosionGraphics\\bang8.png")]
   		protected var bang8Graphic:Class;
		protected var bang8G:Bitmap = new bang8Graphic();
		
		//declare the variables for the explosion
		protected var frameDelay:int;
		protected var delay:int=5;			//this many stage frames will occur before the next explosion frame happens
		protected var bang:Sprite = new Sprite();
		protected var bangs:Array=new Array(9);	//how many explosion frames there are
		protected var frameCounter:int;
		protected var xCoord:int=0;
		protected var yCoord:int=0;
		
		public function Explosion(scaleFactor:Number)
		{
			//set offsets for frame images
			bang0G.x=-50;
			bang0G.y=-50;
			bang1G.x=-50;
			bang1G.y=-50;
			bang2G.x=-50;
			bang2G.y=-50;
			bang3G.x=-50;
			bang3G.y=-50;
			bang4G.x=-50;
			bang4G.y=-50;
			bang5G.x=-50;
			bang5G.y=-50;
			bang6G.x=-50;
			bang6G.y=-50;
			bang7G.x=-50;
			bang7G.y=-50;
			bang8G.x=-50;
			bang8G.y=-50;
			
			//add the frames to the array
			bangs[0]=bang0G;
			bangs[1]=bang1G;
			bangs[2]=bang2G;
			bangs[3]=bang3G;
			bangs[4]=bang4G;
			bangs[5]=bang5G;
			bangs[6]=bang6G;
			bangs[7]=bang7G;
			bangs[8]=bang8G;
			
			//scale the sprite
			bang.scaleX=scaleFactor;
			bang.scaleY=scaleFactor;
		}
		
		//return the explosion graphic to the calling class
		public function getGraphic():Sprite
		{
			return bang;
		}
		
		//reset the explosion, make all frames invisible
		public function reset():void
		{
			if(bang.numChildren>0)
				bang.removeChildAt(0);
		}
		
		//enter the animation at the frame numbered num
		public function enterFrame(num:int):void
		{
			bang.addChild(bangs[num]);
			frameCounter=num;
		}
		public function start():void
		{
			if(bang.numChildren>0)
				bang.removeChildAt(0);
			bang.addChild(bangs[0]);
			frameCounter=0;
		}
		public function getX():int
		{
			return xCoord;
		}
		public function getY():int
		{
			return yCoord;
		}
		public function setXY(x:int,y:int):void
		{
			xCoord=x;
			yCoord=y;
		}
		//find the frame currently visible then make that frame invisible and make the next frame visible
		public function nextFrame():void
		{
			if(frameDelay==0)
			{
				//remove the old frame
				bang.removeChildAt(0);
	
				//increment the frame, reverting to 0 if over the max number of frames
				frameCounter++;
				if(frameCounter>8)
					frameCounter=0;
					
				//make new frame visible
				bang.addChild(bangs[frameCounter]);
			}
			
			//iterate the frameDelay variable and reset the framedelay when it hits delay
			frameDelay++;
			if(frameDelay==delay)
			{
				frameDelay=0;
			}
		}
	}
}