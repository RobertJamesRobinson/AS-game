package
{
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.utils.Timer;
	
	public class SoundManager
	{
		[Embed(source=".\\sounds\\bang.mp3")]
   		protected var BangSound:Class;
		protected var bangS:Sound = new BangSound();
		
		[Embed(source=".\\sounds\\rocketLaunch.mp3")]
   		protected var rocketLaunchSound:Class;
		protected var rocketLaunchS:Sound = new rocketLaunchSound();
		
		[Embed(source=".\\sounds\\reload.mp3")]
   		protected var reloadSound:Class;
		protected var reloadS:Sound = new reloadSound();
		
		[Embed(source=".\\sounds\\klaxon.mp3")]
   		protected var klaxonSound:Class;
		protected var klaxonS:Sound = new klaxonSound();
		
		[Embed(source=".\\sounds\\birdsong.mp3")]
   		protected var birdsongSound:Class;
		protected var birdsongS:Sound = new birdsongSound();
		
		[Embed(source=".\\sounds\\getsome.mp3")]
   		protected var getsomeSound:Class;
		protected var getsomeS:Sound = new getsomeSound();
		
		[Embed(source=".\\sounds\\gettothechopper.mp3")]
   		protected var gettothechopperSound:Class;
		protected var gettothechopperS:Sound = new gettothechopperSound();
		
		[Embed(source=".\\sounds\\goindown.mp3")]
   		protected var goindownSound:Class;
		protected var goindownS:Sound = new goindownSound();
		
		[Embed(source=".\\sounds\\goindown2.mp3")]
   		protected var goindown2Sound:Class;
		protected var goindown2S:Sound = new goindown2Sound();
		
		[Embed(source=".\\sounds\\moveout.mp3")]
   		protected var moveoutSound:Class;
		protected var moveoutS:Sound = new moveoutSound();
		
		[Embed(source=".\\sounds\\paybacktime.mp3")]
   		protected var paybacktimeSound:Class;
		protected var paybacktimeS:Sound = new paybacktimeSound();
		
		[Embed(source=".\\sounds\\valkyriesSong.mp3")]
   		protected var valkyriesSongSound:Class;
		protected var valkyriesSongS:Sound = new valkyriesSongSound();
		
		[Embed(source=".\\sounds\\warSong.mp3")]
   		protected var warSongSound:Class;
		protected var warSongS:Sound = new warSongSound();
		
		[Embed(source=".\\sounds\\bulletImpact.mp3")]
   		protected var bulletImpactSound:Class;
		protected var bulletImpactS:Sound = new bulletImpactSound();
		
		[Embed(source=".\\sounds\\wilhelmScream.mp3")]
   		protected var wilhelmScreamSound:Class;
		protected var wilhelmScreamS:Sound = new wilhelmScreamSound();
		
		[Embed(source=".\\sounds\\rocketFlight.mp3")]
   		protected var rocketFlightSound:Class;
		protected var rocketFlightS:Sound = new rocketFlightSound();
		protected var rocketFlightChannel:SoundChannel = new SoundChannel;
		
		[Embed(source=".\\sounds\\gun.mp3")]
   		protected var GunSound:Class;
		protected var gunS:Sound = new GunSound();
		protected var gunChannel:SoundChannel = new SoundChannel;
		
		[Embed(source=".\\sounds\\heliFlight.mp3")]
   		protected var heliFlightSound:Class;
		protected var heliFlightS:Sound = new heliFlightSound();
		protected var heliFlightChannel:SoundChannel = new SoundChannel;
		
		protected var heliSoundOn:Boolean;
		protected var radioOn:Boolean=false;
		protected var gunOn:Boolean;
		protected var radioTime:Timer;
		protected var radioChannel:SoundChannel=new SoundChannel();
		protected var volumeControl:SoundTransform=new SoundTransform();
		
		protected var songSelection:int;
		
		public function SoundManager()
		{
			radioTime = new Timer(60000);		//every 1000 = 1 sec, delay between the start of each song
			radioTime.start();
			songSelection=0;
			radioTime.addEventListener(TimerEvent.TIMER,changeRadio);
			gunOn=false;
		}
		public function goinDown(n:int):void
		{
			//var volumeControl:SoundTransform=new SoundTransform(1,0);
			volumeControl.volume=1.3;
			if(n==1)
				goindownS.play(0,0,volumeControl);
			else
				goindown2S.play(0,0,volumeControl);
		}
		public function getToTheChopper():void
		{
			//var volumeControl:SoundTransform=new SoundTransform(0.75,0);
			volumeControl.volume=0.2;
			gettothechopperS.play(0,0,volumeControl);
		}
		public function bulletHit():void
		{
			//var volumeControl:SoundTransform=new SoundTransform(1,0);
			volumeControl.volume=0.2;
			bulletImpactS.play(0,0,volumeControl);
		}
		private function changeRadio(event:TimerEvent):void
		{
			//var volumeControl:SoundTransform;
			if(radioOn)
			{
				switch(songSelection)
				{
					case 0:
						//volumeControl=new SoundTransform(0.12,0);
						volumeControl.volume=0.175;
						radioChannel=birdsongS.play(0,0,volumeControl);
						break;
					case 1:
						//volumeControl=new SoundTransform(0.3,0);
						volumeControl.volume=0.38;
						radioChannel=warSongS.play(0,0,volumeControl);
						break;
					case 2:
						//volumeControl=new SoundTransform(0.2,0);
						volumeControl.volume=0.28;
						radioChannel=valkyriesSongS.play(0,0,volumeControl);
						break;
				}
				songSelection++;
				if(songSelection>2)
					songSelection=0;
			}
		}
		public function payBackTime():void
		{
			//var volumeControl:SoundTransform=new SoundTransform(0.75,0);
			volumeControl.volume=0.25;
			paybacktimeS.play(0,0,volumeControl);
		}
		public function radio(state:Boolean):void
		{
			//var volumeControl:SoundTransform=new SoundTransform(0.2,0);
			radioChannel.stop();
			radioOn=state;
		}
		public function isFlying():Boolean
		{
			return heliSoundOn;
		}
		public function wilhelm():void
		{
			volumeControl.volume=0.4;
			wilhelmScreamS.play(0,1,volumeControl);
		}
		public function Explosion(n:int):void
		{
			volumeControl.volume=0.5;
			bangS.play(0,n,volumeControl);
		}
		public function startGun():void
		{
			if(!gunOn)
			{	
				volumeControl.volume=0.5;
				gunChannel=gunS.play(60,100,volumeControl); 
				gunOn=true;
			}
		}
		public function reload():void
		{
			volumeControl.volume=0.3;
			reloadS.play(0,1,volumeControl);
		}
		public function alarm():void
		{
			//var volumeControl:SoundTransform=new SoundTransform(0.25,0);
			volumeControl.volume=0.20;
			klaxonS.play(0,1,volumeControl);
		}
		public function rocketLaunch():void
		{
			volumeControl.volume=0.3;
			rocketLaunchS.play(0,1,volumeControl);
		}
		public function stopGun():void
		{
			if(gunOn)
			{
				if(gunChannel!=null)
				gunChannel.stop();
				gunOn=false;
			}
		}
		public function startRocket():void
		{
			volumeControl.volume=0.6;
			rocketFlightChannel=rocketFlightS.play(60,10000,volumeControl);
		}
		public function stopRocket():void
		{
			if(rocketFlightChannel!=null)
				rocketFlightChannel.stop();
		}
		public function startFlight():void
		{
			//var volumeControl:SoundTransform=new SoundTransform(1,0);
			volumeControl.volume=0.4;
			heliFlightChannel=heliFlightS.play(50,1,volumeControl);
			heliFlightChannel.addEventListener(Event.SOUND_COMPLETE,playFlightAgain);
			heliSoundOn=true;
		}
		private function playFlightAgain(event:Event):void
		{
			if(heliSoundOn)
			{
				//var volumeControl:SoundTransform=new SoundTransform(1,0);
				volumeControl.volume=0.4;
				heliFlightChannel=heliFlightS.play(50,1,volumeControl);
				heliFlightChannel.addEventListener(Event.SOUND_COMPLETE,playFlightAgain);
			}
				
		}
		public function stopFlight():void
		{
			heliFlightChannel.stop();
			heliSoundOn=false;
		}
		
	}
}