package
{	
	import flash.display.Sprite;
	
	public class VisualEffectsManager
	{
		protected var storedDelay:int;
		protected var fader:FadeEffect;
		
		public function VisualEffectsManager(delay:int)
		{
			storedDelay=delay;
		}
		
		public function fadeIn(canvas:Sprite):void
		{
			fader=new FadeEffect(storedDelay);
			fader.fadeIn(canvas);
		}
		public function isActive():Boolean
		{
			return fader.isActive();
		}
		public function fadeOut(canvas:Sprite):void
		{
			fader=new FadeEffect(storedDelay);
			fader.fadeOut(canvas);
		}
	}
}