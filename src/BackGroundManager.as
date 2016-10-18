package
{
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	
	public class BackGroundManager
	{
		protected var viewX:int;
		protected var viewY:int;
		protected var view:Rectangle;
		protected var tiles:TileManager 
		protected var numXTiles:int;
		protected var numYTiles:int;
		protected var tileHeight:int;
		protected var tileWidth:int;
		protected var canvas:Sprite=new Sprite();
		protected var tempSprite:Sprite=new Sprite();
		protected var topX:int;
		protected var topY:int;
		protected var xOldIndex:int=-1;	//set to minus 1 to ensure that the first call to setView actually calculates new tiles
		protected var yOldIndex:int=-1;	//set to minus 1 to ensure that the first call to setView actually calculates new tiles
		protected var background:Array;
		
		public function BackGroundManager(width:int, height:int,tileSize:int)
		{
			tileHeight=tileSize;
			tileWidth=tileSize;
			tiles=new TileManager(tileSize);
			//initialise the background
			view=new Rectangle(0,0,width,height);
			view.x=0;
			view.y=0;
			
			//discover the number of tiles needed to fill the canvas at all times
			numXTiles=width/tileWidth+1;
			numYTiles=height/tileHeight+1;
			
			//add another tile row or colum if the given view size is not exactly divisible by the tile size
			if(width%tileWidth>0)
				numXTiles++;
			if(height%tileHeight>0)
				numYTiles++;
			
			//set up the background array, all the sprites that make up the background image in an array
			background=new Array(numXTiles);
			for(var i:int=0;i<numXTiles;i++)
			{
				background [i] = new Array(numYTiles);
			}
			
			for(var x:int=0; x<numXTiles; x++)
			{
				for(var y:int=0; y<numYTiles; y++)
				{
					background[x][y]=new Sprite();
				}
			}
			
			//setup the canvas sprite with 0 offsets
			for(x=0; x<numXTiles; x++)
			{
				for(y=0; y<numYTiles; y++)
				{
					canvas.addChild(background[x][y]);
					background[x][y].x=x*tileWidth;
					background[x][y].y=y*tileHeight;
				}
			}
			canvas.scrollRect=view;
		}
		
		//sets the size of the map, ie how many tiles wide by how many tiles high
		public function setMapSize(x:int,y:int):void
		{
			tiles.setXYDimensions(x,y);
		}
		
		//creates a random map of tile indices
		public function createRandomMap():void
		{
			tiles.createRandomMap();
		}
		public function createEmptyMap():void
		{
			tiles.createEmptyMap();
		}
		public function pumpLineIntoMap(line:int,data:Array):void
		{
			var test:int=data[0];
			var test1:int=data[6];
			var test2:int=data[9];
			var test3:int=data[10];
			
			tiles.insertLine(line,data);
		}
		 
		public function setView(x:int, y:int):void
		{
			//if the given x and y coordinates are outside the map dimensions then reset the offending coordinate to its limit
			if(x<0)
				x=0;
			if(x>(tiles.getMapGraphicWidth()-view.width))
				x=tiles.getMapGraphicWidth()-view.width;
			if(y<0)
				y=0;
			if(y>(tiles.getMapGraphicHeight()-view.height))
				y=tiles.getMapGraphicHeight()-view.height;
			
			//calculate which tile should appear in the top left of the grid of tiles
			var xStartIndex:int=(x/tileWidth);
			var yStartIndex:int=(y/tileHeight);
			
			//find the offset amount that the local scroll rect has to move
			var xOffset:int=(x%tileWidth);
			var yOffset:int=(y%tileHeight);
			
			//only perform the next segment (swap all tile bitmaps!) if its necessary, ie the new x,y coords are outside the bounds of the existing tiles.
			if(xOldIndex!=xStartIndex||yOldIndex!=yStartIndex)
			{
				//scan through all tiles on display and remove the old bitmaps and replace them with nice shiney new ones! (from the next row or column along)
				for(var i:int=0; i<numXTiles; i++)
				{
					for(var j:int=0; j<numYTiles; j++)
					{
						//remove the old sprite from the background array 
						if(background[i][j].numChildren>0)
							background[i][j].removeChildAt(0);
						
						//make tx and ty the next tile index (iterated through by the nested for loop)
						var tX:int=i+xStartIndex;
						var tY:int=j+yStartIndex;
						
						//only add the new tile if the new tile is within the map boundaries
						if(tY<tiles.getMapHeightUnits()&&tX<tiles.getMapWidthUnits())
							background[i][j].addChild(tiles.returnTileGraphicAt(tX,tY));
					}
				}
			}
			//code to adjust the scroll rect goes here
			view.x=xOffset;
			view.y=yOffset;
			canvas.scrollRect=view;
			
			//set the old index values for the next time through
			xOldIndex=xStartIndex;
			yOldIndex=yStartIndex;
		}
		public function getBackground():Sprite
		{
			//return new canvas
			return canvas;
		}
	}
}