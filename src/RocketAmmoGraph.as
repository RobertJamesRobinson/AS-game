package
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	
	public class RocketAmmoGraph
	{
		[Embed(source=".\\images\\rocket.png")]
   		protected var rocketGraphic:Class;
		protected var rocketG:Bitmap = new rocketGraphic();
		
		protected var bar:Sprite;
		protected var value:int;
		protected var maxValue:int;
		protected var cursorX:int;
		
		public function RocketAmmoGraph(num:int)
		{
			value=num;
			maxValue=num;
			cursorX=0;
			bar=new Sprite();
			updateSprite();
		}
		public function getValue():int
		{
			return value;
		}
		public function setValue(num:int):void
		{
			if(value!=num)
			{
				value=num;
				updateSprite();
			}
		}
		public function getGraphic():Sprite
		{
			return bar;
		}
		public function incr():void
		{
			value++;
			if(value>maxValue)
				value=maxValue;
			updateSprite();
		}
		public function decr():void
		{
			value--;
			if(value<0)
				value=0;
			updateSprite();
		}
		private function updateSprite():void
		{
			var i:int=0;
			var numOfRockets:int=bar.numChildren;
			
			if(numOfRockets<value)
			{
				for (i=0;i<(value-numOfRockets);i++)
				{
					addRocket();
				}
			}
			else
			{
				for (i=0;i<(numOfRockets-value);i++)
				{
					delRocket();
				}
			}
		}
		
		private function delRocket():void
		{
			bar.removeChildAt(bar.numChildren-1);
			cursorX-=10;
		}
		private function addRocket():void
		{
			//create a new bitmap from the bitmap data of the rocket bitmap
			var newRocket:Bitmap=new Bitmap(rocketG.bitmapData);
			
			//add the new bitmap to the bar
			bar.addChild(newRocket);
			//set the new bitmap at the current cursor position and rotate it
			newRocket.x=cursorX;
			newRocket.rotation=315;
			//move the cursor along by a set amount
			cursorX+=10;
		}
		public function setXY(x:Number,y:Number):void
		{
			bar.x=x;
			bar.y=y;
		}


	}
}