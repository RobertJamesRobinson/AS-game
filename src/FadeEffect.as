package
{
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	public class FadeEffect
	{
		protected var fadeInTimer:Timer;
		protected var fadeOutTimer:Timer;
		protected var currentAlpha:Number;
		protected var storedDelay:int;
		protected var currentSprite:Sprite;
		protected var framesPerSecForEffect:Number=60
		protected var fpsInms:Number;
		
		public function FadeEffect(delay:int)
		{
			storedDelay=delay;
			fpsInms=(1/framesPerSecForEffect)*1000;
			fadeInTimer=new Timer(fpsInms);
			fadeOutTimer=new Timer(fpsInms);
			fadeInTimer.addEventListener(TimerEvent.TIMER,increaseAlpha);
			fadeOutTimer.addEventListener(TimerEvent.TIMER,decreaseAlpha);
		}
		private function stopAllTimers():void
		{
			fadeOutTimer.stop();
			fadeInTimer.stop();
		}
		public function fadeIn(canvas:Sprite):void
		{
			canvas.alpha=0;
			canvas.visible=true;
			stopAllTimers();
			fadeInTimer.reset();
			currentSprite=canvas;
			currentAlpha=currentSprite.alpha;
			fadeInTimer.start();
		}
		public function isActive():Boolean
		{
			var test:Boolean=false;
			if(fadeOutTimer.running||fadeInTimer.running)
				test=true;
			return test;
		}
		private function decreaseAlpha(event:TimerEvent):void
		{
			var dx:Number=(1/(storedDelay/fpsInms));
			
			currentAlpha=currentAlpha-dx;
			if(currentAlpha<0)
				currentAlpha=0;
			currentSprite.alpha=currentAlpha;
			if(currentAlpha==0)
			{	
				fadeOutTimer.stop();
				fadeOutTimer.reset();
				currentSprite.visible=false;
			}
		}
		private function increaseAlpha(event:TimerEvent):void
		{
			var tx:Number=(1/(storedDelay/fpsInms)); 
			
			currentAlpha=currentAlpha+tx
			if(currentAlpha>1)
				currentAlpha=1;
			currentSprite.alpha=currentAlpha;
			if(currentAlpha==1)
			{	
				fadeInTimer.stop();
				fadeInTimer.reset();
				currentSprite.visible=true;
			}
		}
		
		public function fadeOut(canvas:Sprite):void
		{
			canvas.visible=true;
			canvas.alpha=1;
			stopAllTimers();
			fadeOutTimer.reset();
			currentSprite=canvas;
			currentAlpha=currentSprite.alpha;
			fadeOutTimer.start();
		}
	}
}