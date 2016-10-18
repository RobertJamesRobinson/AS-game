package {
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.ui.Mouse;
	import flash.utils.Timer;
	
	public class RPGGame extends Sprite
	{
		//embeded graphics
		[Embed(source=".\\images\\miniMap.png")]
   		protected var miniMapGraphic:Class;
   		[Embed(source=".\\images\\splash.jpg")]
   		protected var splashGraphic:Class;
   		[Embed(source=".\\images\\splash2.jpg")]
   		protected var splash2Graphic:Class;
   		[Embed(source=".\\images\\playbutton.png")]
   		protected var playGraphic:Class;
   		[Embed(source=".\\images\\highscoresbutton.png")]
   		protected var highscoresGraphic:Class;
   		[Embed(source=".\\images\\back.png")]
   		protected var backButtonGraphic:Class;
   		[Embed(source=".\\images\\instructionsbutton.png")]
   		protected var instructionsGraphic:Class;
   		[Embed(source=".\\images\\base.jpg")]
   		protected var baseGraphic:Class;
   		[Embed(source=".\\images\\paused.png")]
   		protected var pausedGraphic:Class;
   		[Embed(source=".\\images\\gotTimeGamesLogo.jpg")]
   		protected var logoGraphic:Class;
   		[Embed(source=".\\images\\reticule.png")]
   		protected var reticuleGraphic:Class;
   		[Embed(source=".\\images\\blank.png")]
   		protected var blankGraphic:Class;
   		
   		protected var miniMapG:Bitmap = new miniMapGraphic();
   		protected var splashG:Bitmap = new splashGraphic();
   		protected var splash2G:Bitmap = new splash2Graphic();
   		protected var playG:Bitmap = new playGraphic();
   		protected var highscoresG:Bitmap = new highscoresGraphic();
   		protected var backButtonG:Bitmap = new backButtonGraphic();
   		protected var instructionsG:Bitmap = new instructionsGraphic();
   		protected var baseG:Bitmap = new baseGraphic();
   		protected var pausedG:Bitmap=new pausedGraphic();
   		protected var logoG:Bitmap=new logoGraphic();
   		protected var reticuleG:Bitmap=new reticuleGraphic();
   		protected var blankG:Bitmap=new blankGraphic();
   		
		//constants
		protected var mapUnitsWide:int=30;
		protected var mapUnitsHigh:int=30;
		protected var tileSize:int=100; 
		protected var viewWide:int=600;
		protected var viewHigh:int=400;
		protected var highScoreListLength:int=8;
		protected var maxMaps:int=1;
		protected var minMaps:int=0;
		
		//screen boundarys
		protected var gameScreenHeliBuffer:int=40;
		protected var gameScreenLeftBound:int;
		protected var gameScreenRightBound:int;
		protected var gameScreenTopBound:int;
		protected var gameScreenBottomBound:int;
		
		//background layer sprites
		protected var background:Sprite=new Sprite();		//actual scrolling background, nothing else on this layer
		protected var enemyLayer:Sprite=new Sprite();		//use this as a layer for enemy helis to sit on
		protected var enemyBulletsLayer:Sprite=new Sprite();
		protected var baseLayer:Sprite=new Sprite();
		protected var playerLayer:Sprite=new Sprite();
		protected var pointExplosionLayer:Sprite=new Sprite();
		
		//other elements
   		protected var back:BackGroundManager=new BackGroundManager(viewWide,viewHigh,tileSize);
   		protected var effects:VisualEffectsManager=new VisualEffectsManager(1000);
   		protected var keys:KeyboardManager=new KeyboardManager;
		protected var highScores:HighScoreBoard=new HighScoreBoard(highScoreListLength);
		protected var heli:Helicoptor=new Helicoptor(0.6);
		protected var text:TextManager=new TextManager();
		protected var text2:TextManager=new TextManager();
		protected var text3:TextManager=new TextManager();
		protected var text4:TextManager=new TextManager();
		protected var health:BarGraph=new BarGraph(1000,0x00ff00);
		protected var bulletAmmo:BarGraph=new BarGraph(400,0xb7ab7a);	//damm magic numbers floating around!!!!! here is the graph limits ROB!
		protected var fuel:BarGraph=new BarGraph(heli.getFuel(),0x00fcff);;
		protected var rocketAmmo:RocketAmmoGraph=new RocketAmmoGraph(4);
		protected var sounds:SoundManager=new SoundManager();
		protected var introTimer:Timer=new Timer(1000);
		protected var transTimer:Timer=new Timer(1000);
		protected var ptExplosion:Explosion=new Explosion(0.9);
		
		//background layer view rects
		protected var enemyLayerRect:Rectangle=new Rectangle(0,0,viewWide,viewHigh);
		protected var enemyBulletsLayerRect:Rectangle=new Rectangle(0,0,viewWide,viewHigh);
		protected var baseLayerRect:Rectangle=new Rectangle(0,0,viewWide,viewHigh);
		protected var playerLayerRect:Rectangle=new Rectangle(0,0,viewWide,viewHigh);
		protected var pointExplosionLayerRect:Rectangle=new Rectangle(0,0,viewWide,viewHigh);
		
		//other sprites
		protected var heliSprite:Sprite=new Sprite();
   		protected var miniMap:Sprite=new Sprite();
   		protected var splash:Sprite=new Sprite();
   		protected var splash2:Sprite=new Sprite();
   		protected var play:Sprite=new Sprite();
   		protected var highscores:Sprite=new Sprite();
   		protected var backButton:Sprite=new Sprite();
   		protected var instructions:Sprite=new Sprite();
   		protected var base:Sprite=new Sprite();
   		protected var textSprite:Sprite=new Sprite();
   		protected var textSprite2:Sprite=new Sprite();
   		protected var textSprite3:Sprite=new Sprite();
   		protected var textSprite4:Sprite=new Sprite();
   		protected var bulletAmmoSprite:Sprite=new Sprite();
   		protected var healthSprite:Sprite=new Sprite();
   		protected var fuelSprite:Sprite=new Sprite();
   		protected var rocketAmmoSprite:Sprite=new Sprite();
   		protected var miniMapOverlay:Sprite=new Sprite();
   		protected var borderSprite:Sprite=new Sprite();
   		protected var pausedScreen:Sprite=new Sprite();
   		protected var logo:Sprite=new Sprite();
   		protected var reticule:Sprite=new Sprite();
   		protected var pointExplosionSprite:Sprite=new Sprite();
   		protected var blank:Sprite=new Sprite();
   		
   		//arrays
   		protected var enemyHelis:Array=new Array();
		
		//various variables
		protected var viewX:Number=0,viewY:Number=0;		//the top left position on the map that is viewable in pixels
		protected var score:Number;
		protected var nowPlaying:Boolean;
		protected var baseX:Number;
		protected var baseY:Number;
		protected var paused:Boolean=false;
		protected var explosionAtPointTrue:Boolean=false;
		protected var explosionCounter:int=0;
		
		//stuff needed for high score entrys
		protected var highScoreEntry:TextField=new TextField();
		protected var scoresFormat:TextFormat=new TextFormat;
		protected var firstEnteredText:Boolean;
   		
   		//variables to keep track of game state
   		protected var prevState:int=-1;
   		protected var gameState:int=0;
   		protected var level:int=0;
   		protected var logoState:int=0;
   		protected var transState:int=0;
   		protected var currentMap:int=0;
   		protected var mapForward:Boolean=true;
   		
		//yeah! lets do it
		public function RPGGame()
		{
			nowPlaying=false;
			stage.frameRate=60;
			stage.scaleMode="noScale";
			
			//add all graphics to sprites
			logo.addChild(logoG);
			base.addChild(baseG);
			instructions.addChild(instructionsG);
			miniMap.addChild(miniMapG);
			miniMap.addChild(miniMapOverlay);
			backButton.addChild(backButtonG);
			play.addChild(playG);
			highscores.addChild(highscoresG);
			splash.addChild(splashG);
			splash2.addChild(splash2G);
			textSprite.addChild(text.getGraphic());
			textSprite2.addChild(text2.getGraphic());
			textSprite3.addChild(text3.getGraphic());
			textSprite4.addChild(text4.getGraphic());
			borderSprite.graphics.lineStyle(5, 0x000000);
			borderSprite.graphics.drawRect(0,0,600,400);
			bulletAmmoSprite.addChild(bulletAmmo.getGraphic());
			healthSprite.addChild(health.getGraphic());
			fuelSprite.addChild(fuel.getGraphic());
			rocketAmmoSprite.addChild(rocketAmmo.getGraphic());
			pausedScreen.addChild(pausedG);
			reticule.addChild(reticuleG);
			pointExplosionSprite.addChild(ptExplosion.getGraphic());
			blank.addChild(blankG);
			
			//add all stage elements
			stage.addChild(logo);
			stage.addChild(splash);
			stage.addChild(splash2);
			stage.addChild(background);
			stage.addChild(baseLayer);
			stage.addChild(enemyBulletsLayer);
			stage.addChild(enemyLayer);
			stage.addChild(playerLayer);
			stage.addChild(pointExplosionLayer);
			background.addChildAt(back.getBackground(),0);
			baseLayer.addChild(base);
			pointExplosionLayer.addChild(pointExplosionSprite);
			
			//buttons
			stage.addChild(play);
			stage.addChild(instructions);
			stage.addChild(highscores);
			stage.addChild(backButton);
			
			//display components
			stage.addChild(bulletAmmoSprite);
			stage.addChild(healthSprite);
			stage.addChild(fuelSprite);
			stage.addChild(rocketAmmoSprite);
			stage.addChild(textSprite);
			stage.addChild(textSprite2);
			stage.addChild(textSprite3);
			stage.addChild(highScoreEntry);
			stage.addChild(miniMap);
			stage.addChild(pausedScreen);
			stage.addChild(blank);
			stage.addChild(textSprite4);
			
			//border
			stage.addChild(borderSprite);
			
			//reticule
			stage.addChild(reticule);
			
			//set initial visibilities
			logo.visible=false;
			bulletAmmoSprite.visible=false;
			healthSprite.visible=false;
			fuelSprite.visible=false;
			rocketAmmoSprite.visible=false;
			textSprite.visible=false;
			textSprite2.visible=false;
			textSprite3.visible=false;
			textSprite4.visible=false;
			borderSprite.visible=true;
			background.visible=false;
			enemyLayer.visible=false;
			enemyBulletsLayer.visible=false;
			baseLayer.visible=false;
			playerLayer.visible=false;
			splash.visible=false;
			splash2.visible=false;
			play.visible=false;
			highscores.visible=false;
			instructions.visible=false;
			backButton.visible=false;
			highScoreEntry.visible=false;
			miniMap.visible=false;
			base.visible=true;
			pausedScreen.visible=false;
			reticule.visible=false;
			blank.visible=false;
			
			//set locations
			instructions.x=220;
			instructions.y=350;
			play.x=250;
			play.y=300;
			highscores.x=220;
			highscores.y=325;
			backButton.x=220;
			backButton.y=320;
			miniMap.x=0;
			miniMap.y=300;
			bulletAmmo.setXY(395,5);
			health.setXY(395,21);
			fuel.setXY(395,37);
			rocketAmmo.setXY(547,67);
			baseG.x=-25;
			baseG.y=-25;
			
			//high score entry stuff
			scoresFormat.size=26;
			highScoreEntry.x=20;
			highScoreEntry.y=120;
			highScoreEntry.height=35;
			highScoreEntry.width=300;
			highScoreEntry.restrict = "\u0020-\u007E";
			highScoreEntry.defaultTextFormat=scoresFormat;
			highScoreEntry.border=true;
			highScoreEntry.type = TextFieldType.INPUT;
			
			//add some bogus high scores
			highScores.addScore("Rob is da king",39015,12);
			highScores.addScore("William Robinson",528624,56);
			highScores.addScore("Frank was ere",12385,6); 
			highScores.addScore("ben just did it",7364,5);
			highScores.addScore("paul didnt",5141,4);
			highScores.addScore("Nearly Made It",1380,3);
			highScores.addScore("dudley did",1092,2);
			highScores.addScore("Scott No Friend",43,1);
			
			//set all the scroll rect properties, only do this here, once set they dont need to be changed (mangles offsets)
			enemyLayer.scrollRect=enemyLayerRect;
			enemyBulletsLayer.scrollRect=enemyBulletsLayerRect;
			baseLayer.scrollRect=baseLayerRect;
			playerLayer.scrollRect=playerLayerRect;
			pointExplosionLayer.scrollRect=pointExplosionLayerRect;
						
			//add event listeners to everything
			play.addEventListener(MouseEvent.MOUSE_DOWN,changeToPlaying);
			instructions.addEventListener(MouseEvent.MOUSE_DOWN,changeToInstructions);
			backButton.addEventListener(MouseEvent.MOUSE_DOWN,changeToSplash);
			highscores.addEventListener(MouseEvent.MOUSE_DOWN,changeToHighScores);
			stage.addEventListener(Event.ENTER_FRAME,updateElements);
			stage.addEventListener(KeyboardEvent.KEY_DOWN,reportKeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP,reportKeyUp);
			stage.addEventListener(MouseEvent.MOUSE_DOWN,reportMouseDown);
			stage.addEventListener(MouseEvent.MOUSE_UP,reportMouseUp);
			highScoreEntry.addEventListener(KeyboardEvent.KEY_DOWN,hitEnter);
			introTimer.addEventListener(TimerEvent.TIMER,drawLogo);
			transTimer.addEventListener(TimerEvent.TIMER,transitionHandler);
			introTimer.start();
			
			//custom mouse
			Mouse.hide();
			reticuleG.x=-20;
			reticuleG.y=-20;
			reticule.mouseEnabled = false;
			reticule.mouseChildren = false;
		}
		
		//this is for high score entry,
		//just listeneing for: 
		//1: the first entered text into the text box clears the existing text
		//2: enter triggers the next state 
		private function hitEnter(event:KeyboardEvent):void
		{
			if(firstEnteredText)
			{
				firstEnteredText=false;
				highScoreEntry.text="";
			}
			if(event.keyCode==13)
			{
				highScoreEntry.visible=false;
				var name:String=new String();
				name=highScoreEntry.getRawText();
				if(name.length>15)
					name=name.substring(0,15);
				highScores.addScore(name,score,level);
				sounds.bulletHit();
				prevState=gameState;
				gameState=0;
				changeState();
			}
		}

		private function setLevel(num:int):void
		{
			switch(num)
			{
				case 0:
					baseX=500;
					baseY=500;
					
					mapUnitsWide=10;
					mapUnitsHigh=10;
					
					gameScreenLeftBound=0;
					gameScreenTopBound=0;
					gameScreenRightBound=mapUnitsWide*tileSize;
					gameScreenBottomBound=mapUnitsHigh*tileSize;
					
					heli.setBase(baseX,baseY);
					heli.setScreenBounds(gameScreenLeftBound,gameScreenRightBound,gameScreenTopBound,gameScreenBottomBound);
					heli.setXY(baseX,baseY);
					heli.softReset();
					keys.clear();
					for(i=0;i<enemyHelis.length;i++)
					{
						enemyHelis[i].setScreenBounds(gameScreenLeftBound,gameScreenRightBound,gameScreenTopBound,gameScreenBottomBound);
						enemyHelis[i].setEnemyBase(baseX,baseY);
						enemyHelis[i].reset();
					}
					//initialise the map
					back.setMapSize(mapUnitsWide,mapUnitsHigh);
					back.createEmptyMap();
					
					//put map values into array
					back.pumpLineIntoMap(0,new Array(1,12,7,0,0,0,0,6,13,1));
					back.pumpLineIntoMap(1,new Array(11,1,12,7,0,0,6,13,1,10));
					back.pumpLineIntoMap(2,new Array(8,11,1,12,7,6,13,1,10,9));
					back.pumpLineIntoMap(3,new Array(0,8,11,1,12,13,1,10,9,0));
					back.pumpLineIntoMap(4,new Array(0,0,8,11,1,1,10,9,0,0));
					back.pumpLineIntoMap(5,new Array(0,0,6,13,1,1,12,7,0,0));
					back.pumpLineIntoMap(6,new Array(0,6,13,1,10,11,1,12,7,0));
					back.pumpLineIntoMap(7,new Array(6,13,1,10,9,8,11,1,12,7));
					back.pumpLineIntoMap(8,new Array(13,1,10,9,0,0,8,11,1,12));
					back.pumpLineIntoMap(9,new Array(1,10,9,0,0,0,0,8,11,1));
				break;
				case 1:
					baseX=1100;
					baseY=1300;
					
					mapUnitsWide=30;
					mapUnitsHigh=30;
					
					gameScreenLeftBound=0;
					gameScreenTopBound=0;
					gameScreenRightBound=mapUnitsWide*tileSize;
					gameScreenBottomBound=mapUnitsHigh*tileSize;
					
					heli.setBase(baseX,baseY);
					heli.setScreenBounds(gameScreenLeftBound,gameScreenRightBound,gameScreenTopBound,gameScreenBottomBound);
					heli.setXY(baseX,baseY);
					heli.softReset();
					keys.clear();
					for(var i:int=0;i<enemyHelis.length;i++)
					{
						enemyHelis[i].setScreenBounds(gameScreenLeftBound,gameScreenRightBound,gameScreenTopBound,gameScreenBottomBound);
						enemyHelis[i].setEnemyBase(baseX,baseY);
						enemyHelis[i].reset();
					}
					
					//initialise the map
					back.setMapSize(mapUnitsWide,mapUnitsHigh);
					back.createEmptyMap();
					
					//put map values into array
					back.pumpLineIntoMap(0,new Array(1,14,14,12,7,60,58,61,0,0,60,58,58,61,56,57,0,20,18,18,18,18,18,21,0,6,4,7,0,0));
					back.pumpLineIntoMap(1,new Array(1,1,14,14,3,62,59,63,20,21,56,29,29,66,67,57,0,22,19,19,19,19,19,23,6,13,14,12,7,0));
					back.pumpLineIntoMap(2,new Array(11,1,14,14,3,0,20,18,27,17,62,65,29,29,29,57,0,0,0,0,0,0,0,0,2,14,14,14,3,0));
					back.pumpLineIntoMap(3,new Array(8,11,1,14,3,0,16,28,28,26,21,62,59,65,64,63,6,4,4,4,4,4,7,0,8,11,14,10,9,60));
					back.pumpLineIntoMap(4,new Array(0,8,5,5,9,0,22,25,24,19,23,0,0,62,63,6,13,14,48,46,46,49,3,0,0,8,5,9,60,67));
					back.pumpLineIntoMap(5,new Array(0,0,6,4,4,4,7,22,23,6,7,0,0,0,6,13,42,48,55,38,39,45,3,60,58,58,58,58,67,29));
					back.pumpLineIntoMap(6,new Array(0,0,8,5,5,5,9,0,6,13,12,7,0,6,13,14,48,55,38,37,30,45,3,62,65,29,64,59,59,65));
					back.pumpLineIntoMap(7,new Array(6,7,0,20,18,21,0,0,8,11,10,9,6,13,14,48,55,38,37,28,30,45,12,7,62,65,66,61,0,56));
					back.pumpLineIntoMap(8,new Array(2,3,0,16,28,17,20,21,0,8,9,6,13,42,48,55,38,37,28,28,30,54,49,12,7,62,65,57,0,56));
					back.pumpLineIntoMap(9,new Array(2,3,0,16,28,17,16,17,0,0,0,2,48,46,55,29,40,32,32,32,41,29,54,49,12,7,56,66,61,56));
					back.pumpLineIntoMap(10,new Array(2,3,20,27,43,26,27,26,21,0,0,2,50,47,47,47,47,47,47,47,47,53,29,54,49,3,62,65,57,56));
					back.pumpLineIntoMap(11,new Array(8,9,16,28,43,43,28,28,17,0,0,8,5,11,14,10,5,11,14,10,11,44,29,29,45,3,0,56,57,56));
					back.pumpLineIntoMap(12,new Array(0,0,22,25,28,24,19,19,23,0,20,21,0,2,14,3,0,8,5,9,2,50,47,47,51,12,7,56,66,67));
					back.pumpLineIntoMap(13,new Array(18,18,21,22,19,23,20,21,0,0,22,23,0,8,5,9,0,0,6,7,8,5,5,11,1,1,3,56,29,64));
					back.pumpLineIntoMap(14,new Array(15,15,26,21,0,0,22,23,20,21,0,0,20,18,18,18,18,21,2,3,0,6,4,13,1,1,3,62,59,63));
					back.pumpLineIntoMap(15,new Array(28,28,15,26,21,20,18,21,16,26,21,0,22,19,19,19,25,17,2,3,0,8,11,42,42,10,9,0,0,0));
					back.pumpLineIntoMap(16,new Array(15,15,24,19,23,16,28,17,22,19,23,20,21,20,18,21,16,17,2,3,6,7,8,5,5,9,0,0,0,0));
					back.pumpLineIntoMap(17,new Array(25,24,23,0,20,27,28,26,18,21,0,16,17,16,28,17,16,17,2,3,2,3,6,7,0,0,60,58,61,0));
					back.pumpLineIntoMap(18,new Array(22,23,0,20,27,34,35,28,28,17,0,16,17,16,28,26,27,17,2,3,2,3,2,3,6,7,62,59,63,0));
					back.pumpLineIntoMap(19,new Array(0,0,20,27,34,41,31,24,19,23,0,16,17,22,25,43,43,17,2,3,2,12,13,12,13,3,0,6,4,4));
					back.pumpLineIntoMap(20,new Array(0,0,16,34,41,29,31,26,18,21,20,27,26,21,22,19,19,23,2,12,13,48,46,46,49,12,4,13,48,46));
					back.pumpLineIntoMap(21,new Array(0,20,27,30,29,29,40,32,35,17,16,34,35,17,6,4,4,4,13,1,42,44,38,39,54,46,46,46,55,29));
					back.pumpLineIntoMap(22,new Array(0,16,43,30,29,38,33,39,31,17,16,36,37,17,2,1,48,46,46,46,46,55,31,36,33,33,33,33,33,39));
					back.pumpLineIntoMap(23,new Array(0,16,43,30,29,31,28,30,31,17,22,19,19,23,8,11,44,52,53,52,53,38,37,28,28,28,34,32,32,41));
					back.pumpLineIntoMap(24,new Array(0,22,25,36,39,40,35,30,31,26,18,18,18,18,21,2,44,45,50,51,44,31,28,34,35,34,41,29,64,59));
					back.pumpLineIntoMap(25,new Array(20,21,22,25,36,39,31,30,40,32,32,32,32,35,17,2,44,45,48,46,55,40,32,41,40,41,64,65,57,0));
					back.pumpLineIntoMap(26,new Array(22,23,0,22,25,30,31,36,33,33,33,33,39,31,17,2,44,54,55,29,52,47,47,47,47,53,66,67,66,58));
					back.pumpLineIntoMap(27,new Array(0,0,20,18,27,30,40,32,32,32,32,32,41,31,17,2,44,29,52,47,51,48,46,46,46,55,29,52,47,47));
					back.pumpLineIntoMap(28,new Array(20,21,22,19,25,36,39,29,29,38,33,33,33,37,17,2,50,47,51,10,11,44,29,52,47,47,47,51,10,5));
					back.pumpLineIntoMap(29,new Array(22,23,0,0,22,25,30,38,33,37,24,19,19,19,23,8,5,5,5,9,2,44,29,45,10,5,5,5,9,0));
				break;
			}
		}
		private function drawLogo(event:TimerEvent):void
		{
			switch(logoState)
			{
				case 0:
				effects.fadeIn(logo);
				break;
				case 2:
				effects.fadeOut(logo);
				break;
				case 3:
				introTimer.stop();
				stage.removeChild(logo);
				reticule.visible=true;
				changeState();
				break;
			}
			logoState++;
		}
		
		//changes state, could get rid of needToChangeState boolean now as its not a timed event
		private function changeState():void  //event:TimerEvent
		{
			var i:int=0;
			var j:int=0;
			
			//undo old state
			switch(prevState)
			{
				case -1://active when first played
					sounds.payBackTime();
					break;
					
				case 0://the prvious state was the intro screen
					//undo intro screen
					effects.fadeOut(play); //.visible=false;
					effects.fadeOut(instructions); //.visible=false;
					effects.fadeOut(highscores); //.visible=false;
					effects.fadeOut(splash); //.visible=false;
					effects.fadeOut(textSprite); //.visible=false;
					//text.clear();
					break;
					
				case 1://the previous state was the instructions screen
					//undo instructions screen
					effects.fadeOut(backButton);//.visible=false;
					effects.fadeOut(textSprite);//.visible=false;
					effects.fadeOut(splash2);//.visible=false;
					break;
					
				case 2://the previous state was playing the game
					nowPlaying=false;
					//undo game playing screen
					//clear the text fields
					text2.clear();
					text.clear();
					
					//clean up occasional stuff ups
					heli.setFiringBullets(false);
					
					//reset enemys array
					while(enemyHelis.length>0)
					{
						enemyHelis.pop();
						
					}
					background.visible=false;
					enemyLayer.visible=false;
					enemyBulletsLayer.visible=false;
					baseLayer.visible=false;
					playerLayer.visible=false;
					bulletAmmoSprite.visible=false;
					healthSprite.visible=false;
					fuelSprite.visible=false;
					rocketAmmoSprite.visible=false;
					miniMap.visible=false;
					
					//remove all enemy helis
					j=enemyLayer.numChildren;
					for(i=j;i>0;i--)
					{
						enemyLayer.removeChildAt(i-1);
					
					}
					//remove all enemy heli bullets
					j=enemyBulletsLayer.numChildren;
					for (i=j;i>0;i--)
					{
						enemyBulletsLayer.removeChildAt(i-1);
						
					}
					//remove all player layer objects
					j=playerLayer.numChildren;
					for (i=j;i>0;i--)
					{
						playerLayer.removeChildAt(i-1);
						
					}
					

				case 3:			//undo high scores entry
					//add background to stage 
					effects.fadeOut(splash2);//.visible=false;
					highScoreEntry.visible=false;
					effects.fadeOut(textSprite);//.visible=false;
					break;
					
				case 4:			//undo high scores list
					effects.fadeOut(splash2);//.visible=false;
					textSprite.visible=false;
					textSprite2.visible=false;
					textSprite3.visible=false;
					text.clear();
					text2.clear();
					text3.clear();
					effects.fadeOut(textSprite3);//.visible=false;
					effects.fadeOut(backButton);//.visible=false;
					break;
			}
			
			//draw new game state
			switch(gameState)
			{
				case 0:
					//draw intro screen
					
					//switch off need to change state
					//needToChangeState=false;
					text.setXY(5,7);
					text.setColouredText();
					text.setScaleFactor(0.50);
					text.clear();
					text.write("Desert Flash");
					
					effects.fadeIn(splash);
					effects.fadeIn(play);
					effects.fadeIn(instructions);
					effects.fadeIn(highscores);
					effects.fadeIn(textSprite);
					
					break;
				case 1:
					//draw instructions screen
					effects.fadeIn(splash2);//.visible);//=true;
					effects.fadeIn(textSprite);//.visible=true;
					effects.fadeIn(backButton);//.visible=true;
					
					//setup text object and write text to text object
					text.setScaleFactor(0.3);
					text.setBlackText();
					text.setXY(20,50);
					text.clear();
					text.write("Instructions:\nKeyboard/mouse commands\nP - Pause\nW - Forwards\nS - Backwards\nA - Left\nD - right\nSpace bar - fire rocket\nmouse button - fire gun");
					break;
				case 2:
					//draw game playing screen
					//needToChangeState=false;
					setLevel(0);
					currentMap=0;
					effects.fadeIn(background);//.visible=true;
					effects.fadeIn(enemyLayer);//.visible=true;
					effects.fadeIn(enemyBulletsLayer);//.visible=true;
					effects.fadeIn(playerLayer);//.visible=true;
					effects.fadeIn(baseLayer);//.visible=true;
					effects.fadeIn(bulletAmmoSprite);//.visible=true;
					effects.fadeIn(healthSprite);//.visible=true;
					effects.fadeIn(fuelSprite);//.visible=true;
					effects.fadeIn(rocketAmmoSprite);//.visible=true;
					effects.fadeIn(miniMap);//.visible=true;
					
					heliSprite.addChild(heli.getGraphic());
					playerLayer.addChild(heliSprite);
					playerLayer=heli.addBulletSprites(playerLayer);
					playerLayer.addChildAt(heli.addRocketSprite(),0);
					
					
					//add 1 enemy to the enemy array
					addEnemyHeli();
					enemyHelis[0].reset();
					
					//add the stats to the display
					effects.fadeIn(textSprite);//.visible=true;
					text.setXY(5,7);
					text.setScaleFactor(0.50);
					text.clear();
					
					effects.fadeIn(textSprite2);//.visible=true;
					text2.setXY(397,6)
					text2.setScaleFactor(0.16);
					text2.lineSpacing(0);
					text2.setBlackText();
					text2.write("Bullets\nHealth\nFuel");
					
					//set initial score
					score=0;
					level=1;
					
					//show helis
					enemyHelis[0].show();
					heli.reset();
					heli.show();
					
					//start the radio and other sounds
					sounds.radio(true);
					sounds.startFlight();
					nowPlaying=true;
					break;
				case 3:			
					//enter high score page
					firstEnteredText=true;
					highScoreEntry.text="Enter your name here";
					highScoreEntry.visible=true;
					
					//setup text object and write text to text object
					text.setScaleFactor(0.3);
					text.setBlackText();
					text.setXY(20,50);
					text.clear();
					text.write("Final score: "+score+"\nLevel: "+level+"\n\n\nThen just press enter");
					
					//display screen elements
					effects.fadeIn(textSprite);//.visible=true;
					effects.fadeIn(splash2);//.visible=true;
					break;
				case 4:			//show high score page
					//setup text objects
					text.setScaleFactor(0.3);
					text.setBlackText();
					text.setXY(20,50);
					text.clear();
					
					text2.setScaleFactor(0.3);
					text2.setBlackText();
					text2.setXY(320,50);
					text2.clear();
					
					text3.setScaleFactor(0.3);
					text3.setBlackText();
					text3.setXY(480,50);
					text3.clear();
					
					//write the values to the text sprites
					text.write("Name:\n");
					for(i=0;i<highScoreListLength;i++)
					{
						text.write(highScores.getNameAt(i)+"\n");
					}
					
					text2.write("Score:\n");
					for(i=0;i<highScoreListLength;i++)
					{
						text2.write(highScores.getScoreAt(i)+"\n");
					}
					
					text3.write("Level:\n");
					for(i=0;i<highScoreListLength;i++)
					{
						text3.write(highScores.getLevelAt(i)+"\n");
					}
					
					//fade in the page elements
					effects.fadeIn(textSprite);//.visible=true;
					effects.fadeIn(textSprite2);//.visible=true;
					effects.fadeIn(textSprite3);//.visible=true;
					effects.fadeIn(backButton);//.visible=true;
					effects.fadeIn(splash2);//.visible=true;
					break;
			}		
		}
		
		//draws the base location, player location and the enemy heli locations to the minimap.
		private function drawElementsToMiniMap():void
		{
			//clear points off old map
			miniMapOverlay.graphics.clear();
			
			//draw base position
			miniMapOverlay.graphics.beginFill(0x0000ff);
			miniMapOverlay.graphics.drawCircle(baseX/(gameScreenRightBound/100),baseY/(gameScreenBottomBound/100),1);
			miniMapOverlay.graphics.endFill();
			
			//draw heli position
			miniMapOverlay.graphics.beginFill(0x00ff00);
			miniMapOverlay.graphics.drawCircle(heli.getX()/(gameScreenRightBound/100),heli.getY()/(gameScreenBottomBound/100),1);
			miniMapOverlay.graphics.endFill();
			
			//draw enemy helis
			miniMapOverlay.graphics.beginFill(0xff0000);
			for(var i:int=0;i<enemyHelis.length;i++)
			{
				if(!enemyHelis[i].isDestroyed())
				{
					miniMapOverlay.graphics.drawCircle(enemyHelis[i].getX()/(gameScreenRightBound/100),enemyHelis[i].getY()/(gameScreenBottomBound/100),1);
				}
			}
			miniMapOverlay.graphics.endFill();
		}
		
		//the "button listener" for the instructions button
		private function changeToInstructions(event:MouseEvent):void
		{
			
			if(!effects.isActive())
			{
				sounds.bulletHit();
				prevState=gameState;
				gameState=1;
				changeState();
			}
		}
		
		//the "button listener" for the high scores page button
		private function changeToHighScores(event:MouseEvent):void
		{
			
			if(!effects.isActive())
			{
				sounds.bulletHit();
				prevState=gameState;
				gameState=4;
				changeState();
			}
		}
		
		//the "button listener" for the play now button
		private function changeToPlaying(event:MouseEvent):void
		{
			
			if(!effects.isActive())
			{
				sounds.getToTheChopper();
				prevState=gameState;
				gameState=2;
				changeState();
			}
		}
		
		//revert to the splash screen from either the instructions or the high score screens
		private function changeToSplash(event:MouseEvent):void
		{
			
			if(!effects.isActive())
			{
				sounds.bulletHit();
				prevState=gameState;
				gameState=0;
				changeState();
			}
		}
		private function explosionAtPoint():void
		{
			if(explosionAtPointTrue)
			{
				if(explosionCounter==0)
				{
//					//find any helis in range of the explosion and change their trajectorys and speed away from the blast
//					for(var i:int=0; i<enemyHelis.length; i++)
//					{
//						if(getDistance(stage.mouseX+viewX,stage.mouseY+viewY,enemyHelis[i].getX(),enemyHelis[i].getY())<200)
//						{
//							enemyHelis[i].setTrajectory(getAngle(stage.mouseX+viewX,stage.mouseY+viewY,enemyHelis[i].getX(),enemyHelis[i].getY())*(180/Math.PI));
//							enemyHelis[i].setVelocity((200-getDistance(stage.mouseX+viewX,stage.mouseY+viewY,enemyHelis[i].getX(),enemyHelis[i].getY()))*0.02);
//							enemyHelis[i].setBlast();
//						}
//					}
					
					//first explosion frame code
					ptExplosion.start();
					pointExplosionSprite.visible=true;
					ptExplosion.setXY(stage.mouseX+viewX,stage.mouseY+viewY);
					sounds.Explosion(1);
				}
				else
				{
					ptExplosion.nextFrame()
				}
				explosionCounter++;
				if(explosionCounter==46)
				{
					pointExplosionSprite.visible=false;
					explosionAtPointTrue=false;
					explosionCounter=0;
				}
			}
		}
		
		//special case needed, cant remember why now.... going from playing the game, back to the splash screen
		private function bugOutOfGame():void
		{
			prevState=2;
			gameState=3;
			sounds.radio(false);
			sounds.stopFlight();
			heli.setFiringBullets(false);
			heli.stopSounds();
			changeState();
		}
		
		//registers keyboard events keys pressed down
		private function reportKeyDown(event:KeyboardEvent):void
		{
			if(gameState==2)
			{
				var targetAngle:Number=getAngle(heliSprite.x-viewX,heliSprite.y-viewY,stage.mouseX,stage.mouseY)
				trace("keydown: "+event.keyCode);			
				switch(event.keyCode)
				{
					
					case 32:
						heli.fireRocket();
						rocketAmmo.setValue(heli.getRocketAmmo());
						break;
					case 87:
						keys.setDown("W");
						break;
					case 83:
						keys.setDown("S");
						break;
					case 65:
						keys.setDown("A");
						break;
					case 68:
						keys.setDown("D");
						break;
					case 80:
						pauseGame();
						break;
				}
			}
		}
		
		//register keyboard events, keys let go
		private function reportKeyUp(event:KeyboardEvent):void
		{
			if(gameState==2)
			{
				var targetAngle:Number=getAngle(heliSprite.x-viewX,heliSprite.y-viewY,stage.mouseX,stage.mouseY)
							
				switch(event.keyCode)
				{
					case 32:
						keys.setUp("spc");
						break;
					case 87:
						keys.setUp("W");
						break;
					case 83:
						keys.setUp("S");
						break;
					case 65:
						keys.setUp("A");
						break;
					case 68:
						keys.setUp("D");
						break;
					
				}
			}
		}
		
		//pushs 1 enemy heli onto the enemy helis array
		private function addEnemyHeli():void
		{
			enemyHelis.push(new EnemyHelicoptor(0.6));
			enemyHelis[enemyHelis.length-1].setScreenBounds(gameScreenLeftBound,gameScreenRightBound,gameScreenTopBound,gameScreenBottomBound)
			enemyHelis[enemyHelis.length-1].setEnemyBase(baseX,baseY);
			enemyBulletsLayer=enemyHelis[enemyHelis.length-1].addBulletSprites(enemyBulletsLayer);
			enemyLayer.addChild(enemyHelis[enemyHelis.length-1].getGraphic());
		}
		
		// test if mouse button is pushed down, start firing bullets
		private function reportMouseDown(event:MouseEvent):void
		{
			if(gameState==2)
			{
				heli.setFiringBullets(true);
			}
		}
		
		//test if mouse is let go, stop firing bullets
		private function reportMouseUp(event:MouseEvent):void
		{
			if(gameState==2)
			{
				heli.setFiringBullets(false);
			}
		}

		private function drawScreen():void
		{
			//draw stats
			text.clear();
			text.setColouredText();
			text.write("Score: "+score);
			rocketAmmo.setValue(heli.getRocketAmmo());
			if(heli.getBulletAmmo()%4==0||heli.getBulletAmmo()==0)
				bulletAmmo.setValue(heli.getBulletAmmo());
			if(heli.getFuel()%50==0)
				fuel.setValue(heli.getFuel());
			if(heli.getHP()%10==0||heli.getHP()<1)
				health.setValue(heli.getHP());
			
			//set the "viewing window" to track the heli (just moves the background)
			viewX=heli.getX()-(viewWide/2);
			viewY=heli.getY()-(viewHigh/2);
			
			//constrain the view coordinates for the sake of positioning the heli sprite, this is also done by the background manager at set view
			if(viewX<0)
				viewX=0;
			if(viewY<0)
				viewY=0;
			if(viewX>(mapUnitsWide*tileSize)-viewWide)
				viewX=(mapUnitsWide*tileSize)-viewWide;
			if(viewY>(mapUnitsHigh*tileSize)-viewHigh)
				viewY=(mapUnitsHigh*tileSize)-viewHigh;
			
			//actually move the background
			back.setView(viewX,viewY);
		
			//set the helisprite
			heliSprite.x=heli.getX()-viewX;
			heliSprite.y=heli.getY()-viewY;
			
			//set the point explosion sprite
			pointExplosionSprite.x=ptExplosion.getX()-viewX;
			pointExplosionSprite.y=ptExplosion.getY()-viewY
			
			//set the rocketsprite
			playerLayer.getChildAt(0).x=heli.getRocketX()-viewX;
			playerLayer.getChildAt(0).y=heli.getRocketY()-viewY;
			
			//animate the explosion at point
			explosionAtPoint();
			
			//set the base sprite
			base.x=baseX-viewX;
			base.y=baseY-viewY;
			
			//move all the other layers to match up with the players view
			enemyLayerRect.x=viewX;
			enemyLayerRect.y=viewY;
			enemyBulletsLayerRect.x=viewX;
			enemyBulletsLayerRect.y=viewY;
			baseLayerRect.x=viewX;
			baseLayerRect.y=viewY;
			playerLayerRect.x=viewX;
			playerLayerRect.y=viewY;
			pointExplosionLayerRect.x=viewX;
			pointExplosionLayerRect.y=viewY;
			
			//animate the heli (this includes adjusting its coordinates! so the mouse locations need to be converted to global coordinates, not stage coordinates)
			heli.animate(stage.mouseX,stage.mouseY,viewX,viewY);

			//aim heading at the mouse location
			heli.setRotation(getAngle(heliSprite.x,heliSprite.y,stage.mouseX,stage.mouseY));
			
			//update the minimap
			drawElementsToMiniMap();
							
		}
		private function testForImpacts():void
		{
			var temp:int=0;
			var test:Boolean=false;
			
			//test for impacts between enemy helis and bouce if needed
			for(var k:int=0;k<enemyHelis.length;k++)
			{
				for(var l:int=0;l<enemyHelis.length;l++)
				{
					if(k!=l)
					{
						if(!enemyHelis[k].isDestroyed()&&getDistance(enemyHelis[k].getX(),enemyHelis[k].getY(),enemyHelis[l].getX(),enemyHelis[l].getY())<60)
						{
							enemyHelis[k].bounceArbitrary(getAngle(enemyHelis[k].getX(),enemyHelis[k].getY(),enemyHelis[l].getX(),enemyHelis[l].getY()));
							enemyHelis[k].moveOnTrajectoryFromRef(enemyHelis[l].getX(),enemyHelis[l].getY(),60);
						}
					}
				}
			}
				
			//scan through all enemy helis and trigger: ai, enemy animations, collisions between player and enemys,
			//collisions between player bullets and each enemy, player rockets and enemy heli, collisions between enemy bullets and player
			for(var i:int=0;i<enemyHelis.length;i++)
			{
				if(!enemyHelis[i].isDestroyed())
				{
					//activate enemy AI
					enemyHelis[i].pilot(heli.getX(),heli.getY(),heli.getTraj(),heli.getVelocity(),heli.getRotation());
					
					//animate enemy helis
					enemyHelis[i].animate(viewX,viewY);
					enemyLayer.getChildAt(i).x=enemyHelis[i].getX()-viewX;
					enemyLayer.getChildAt(i).y=enemyHelis[i].getY()-viewY;
					
					//test for impacts between helicopter and enemy and bounce if needed
					if(getDistance(heli.getX(),heli.getY(),enemyHelis[i].getX(),enemyHelis[i].getY())<60)
					{
						//bounce heli if heli is moving faster than enemy, else bounce the enemy heli
						if(heli.getVelocity()>=enemyHelis[i].getVelocity())
						{
							heli.bounceArbitrary(getAngle(heli.getX(),heli.getY(),enemyHelis[i].getX(),enemyHelis[i].getY()));
							heli.moveOnTrajectoryFromRef(enemyHelis[i].getX(),enemyHelis[i].getY(),60);
								
							if(!enemyHelis[i].isBeingDestroyed())
							{
								heli.damage(5);
								enemyHelis[i].damage(5);
							}
						}
						else
						{
							enemyHelis[i].bounceArbitrary(getAngle(enemyHelis[i].getX(),enemyHelis[i].getY(),heli.getX(),heli.getY()));
							enemyHelis[i].moveOnTrajectoryFromRef(heli.getX(),heli.getY(),60);
								
							if(!enemyHelis[i].isBeingDestroyed())
							{
								heli.damage(5);
								enemyHelis[i].damage(5);
							}
						}
					}
					
					//test for impacts of bullets with enemy heli and update enemy accordingly
					//reworked for optimization! was several nested loops outside this loop
					temp=heli.testBulletCollisions(enemyHelis[i].getX(),enemyHelis[i].getY(),30); //get the damage amount
					if(enemyHelis[i].getHP()>0)
						score+=temp;
					enemyHelis[i].damage(temp*5);
					
					//test for impacts between rockets and enemy helis and update enemy accordingly
					temp=heli.testRocketCollisions(enemyHelis[i].getX(),enemyHelis[i].getY(),30);  //get the damage amount
					if(enemyHelis[i].getHP()>0)
						score+=(temp*10);
					enemyHelis[i].damage(temp);
					
					//test for impacts of enemy bullets with heli and update heli accordingly
					temp=enemyHelis[i].testBulletCollisions(heli.getX(),heli.getY(),30); //get the damage amount
					//if heli is landed at base, do 10 times the damage (incentive to keep moving!)
					if(heli.isNearBase())
						temp*=10;
					heli.damage(temp);
					
					//test if rocket hits mouse and destroy it
					if(heli.isRocketAlive())
					{
						if(getDistance(heli.getRocketX(),heli.getRocketY(),stage.mouseX+viewX,stage.mouseY+viewY)<=5)
						{
							explosionAtPointTrue=true;
							heli.destroyRocket();
						}
					}
					
					//check that this heli is still alive (after doin all that stuff above!) and if it still is alive, set test to true
					//ie at least 1 heli is still alive
					
					if(!enemyHelis[i].isDestroyed())
					{
						test=true;
					}
				}
			}
			
			//test for screen boundarys and bounce if necessary
			if(heli.getX()>gameScreenRightBound-gameScreenHeliBuffer)
			{
				heli.bounceX();
				heli.setXY(gameScreenRightBound-gameScreenHeliBuffer,heli.getY());
			}
			if(heli.getY()>gameScreenBottomBound-gameScreenHeliBuffer)
			{
				heli.bounceY();
				heli.setXY(heli.getX(),gameScreenBottomBound-gameScreenHeliBuffer);
			}
			if(heli.getX()<gameScreenLeftBound+gameScreenHeliBuffer)
			{
				heli.bounceX();
				heli.setXY(gameScreenLeftBound+gameScreenHeliBuffer,heli.getY());
			}
			if(heli.getY()<gameScreenTopBound+gameScreenHeliBuffer)
			{
				heli.bounceY();
				heli.setXY(heli.getX(),gameScreenTopBound+gameScreenHeliBuffer);
			}
			
			//go up a level if all enemys destroyed
			//if all helis are destroyed add another to the array and reset them all add 1 to the level
			if(!test)
			{
				level++;
				addEnemyHeli();
				
				//reset all new heli's
				for(i=0;i<enemyHelis.length;i++)
				{
					enemyHelis[i].reset();
					enemyHelis[i].adjustParameters((level*20),(level*0.015)+0.06,(level*0.3)+1.5);
				}
				if(level%2==0)
				{
					
					if(currentMap==maxMaps)
						mapForward=false;
					if(currentMap==minMaps)
						mapForward=true;
					
					if(mapForward)
						currentMap++;
					else
						currentMap--;
					
					transition("Level "+level+", Map "+currentMap);
					//setLevel(currentMap);
				}	
				
					
			}
			
			//reload, repair, refuel player heli if near base
			heli.reloading();
		}
		private function transitionHandler(event:TimerEvent):void
		{
			transition("");
		}
		private function transition(str:String):void
		{
			switch(transState)
			{
				case 0:		//first call
				transTimer.start();
				text4.clear();
				text4.setColouredText();
				text4.setScaleFactor(0.5);
				text4.write(str);
				text4.setXY((viewWide/2)-(text4.getWidth()/2),(viewHigh/2)-(text4.getHeight()/2));
				paused=true;
				effects.fadeIn(blank);
				effects.fadeIn(textSprite4);
				effects.fadeOut(reticule);
				break;
				
				case 2:
				setLevel(currentMap);
				drawScreen();
				break;
				
				case 3:
				effects.fadeOut(blank);
				effects.fadeOut(textSprite4);
				effects.fadeIn(reticule);
				break;
				
				case 4:
				transTimer.stop();
				transTimer.reset();
				paused=false;
				transState=-1;
				break;
			}
			transState++;
		}
		private function pauseGame():void
		{
			if(paused&&!effects.isActive())
			{
				paused=false;
				effects.fadeOut(pausedScreen);
			}
			else
			{
				paused=true;
				effects.fadeIn(pausedScreen);
			}
				
		}
		//frame based update of all elements on screen during play
		private function updateElements(event:Event):void
		{
			reticule.x=stage.mouseX;
			reticule.y=stage.mouseY;
			
			if(!paused)
			{
			
				if(gameState==2&&nowPlaying) //&&!effects.isActive()
				{
					//fire a rocket if space is being held down and there is no current rocket
//					if(keys.firingRocket()&&!heli.isRocketAlive())
//					{
//						heli.fireRocket();
//						rocketAmmo.setValue(heli.getRocketAmmo());
//					}
					
					//draw all screen things
					drawScreen();
					
					//see if still holding down keys and move accordingly
					if(keys.anyKeyDown())
					{
						heli.alterCourse(getAngle(heliSprite.x,heliSprite.y,stage.mouseX,stage.mouseY),keys.getDirection());
					}
					
					//test for any impacts (and activate enemy ai)
					testForImpacts();
					
					//reset game if helicoptor is destroyed
					if(heli.isDestroyed())
					{
						bugOutOfGame();
					}
				}
				else if((gameState==2&&nowPlaying))
				{
					drawScreen();
				}
			}
		}
		
		//get the angle between 2 points and return the result in degrees
		private function getAngle(currentX:Number,currentY:Number,targetX:Number,targetY:Number):Number
		{
			var q:Number=0;
		 
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
		    	
		    //convert result to degrees
		    q=q*(180/Math.PI);
		    	
			return q;
		}
		
		//using pythagoras, find and return the distance between two points
		private function getDistance(x1:Number,y1:Number,x2:Number,y2:Number):Number
		{
			return Math.sqrt(((x1-x2)*(x1-x2))+((y1-y2)*(y1-y2)));
		}
	}
}
