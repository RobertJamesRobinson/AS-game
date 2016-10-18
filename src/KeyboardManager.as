package
{
	public class KeyboardManager
	{
		//check to see what keys are down or up to allow for more accurate multiple key traps
		protected var keysDown:Array = new Array(5);
		public function KeyboardManager()
		{
			for(var i:int;i<5;i++)
			{
				keysDown[i]=false;
			}
		}
		public function clear():void
		{
			for(var i:int=0;i<4;i++)
				keysDown[i]=false;
		}
		public function anyKeyDown():Boolean
		{
			var result:Boolean=false;
			
			for(var i:int=0;i<4;i++)
			{
				if(keysDown[i])
					result=true;
			}
			
			//detect if incorrect key combinations are in existance and return a false, to prevent movement when the wrong keys are pressed
			if(keysDown[0]&&keysDown[1])
				result=false;
			if(keysDown[2]&&keysDown[3])
				result=false;
			
			return result;
		}
		public function setDown(k:String):void
		{
			if(k=="W")
				keysDown[0]=true;
			if(k=="S")
				keysDown[1]=true;
			if(k=="A")
				keysDown[2]=true;
			if(k=="D")
				keysDown[3]=true;
//			if(k=="spc")
//				keysDown[4]=true;
		}
		public function setUp(k:String):void
		{
			if(k=="W")
				keysDown[0]=false;
			if(k=="S")
				keysDown[1]=false;
			if(k=="A")
				keysDown[2]=false;
			if(k=="D")
				keysDown[3]=false;
//			if(k=="spc")
//				keysDown[4]=false;
		}
		public function getDirection():Number
		{
			var angle:Number;
			
			//cardinal points
			if(keysDown[0]&&!keysDown[1]&&!keysDown[2]&&!keysDown[3])//W is down only
				angle=0;	
			if(!keysDown[0]&&keysDown[1]&&!keysDown[2]&&!keysDown[3])//S is down only
				angle=180;
			if(!keysDown[0]&&!keysDown[1]&&keysDown[2]&&!keysDown[3])//A is down only
				angle=270;
			if(!keysDown[0]&&!keysDown[1]&&!keysDown[2]&&keysDown[3])//D is down only
				angle=90;
			
			//45 degree increments
			if(keysDown[0]&&!keysDown[1]&&keysDown[2]&&!keysDown[3])//W and A are down only
				angle=315;
			if(keysDown[0]&&!keysDown[1]&&!keysDown[2]&&keysDown[3])//W and D are down only
				angle=45;	
			if(!keysDown[0]&&keysDown[1]&&keysDown[2]&&!keysDown[3])//S and A are down only
				angle=225;
			if(!keysDown[0]&&keysDown[1]&&!keysDown[2]&&keysDown[3])//S and D are down only
				angle=135;
			return angle;
		}
		public function firingRocket():Boolean
		{
			return keysDown[4];
		}

	}
}