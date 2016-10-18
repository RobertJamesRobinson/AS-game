package
{
	import flash.display.Sprite;
	
	public class BarGraph
	{
		//declare required values
		protected var value:int;
		protected var maxValue:int;
		protected var bar:Sprite;
		protected var fillColour:uint;
		
		//constructor, takes num: the maximum value for the graph and colour: the colour of the graph
		public function BarGraph(num:int,colour:uint)
		{
			value=num;
			maxValue=num;
			fillColour=colour;
			bar=new Sprite();
			updateSprite();
		}
		
		//returns the value associated with the graph, ie the actual value being stored
		public function getValue():int
		{
			return value;
		}
		
		//arbitrarily set the value of the graph, won't go above the defined max value
		public function setValue(num:int):void
		{
			//only updates the graph if the value is different from the already stored value: optimization
			if(value!=num)
			{
				value=num;
				if(value<0)
					value=0;
				if(value>maxValue)
					value=maxValue;
				updateSprite();
			}
		}
		
		//returns the sprite associated with this graph object to the calling class
		public function getGraphic():Sprite
		{
			return bar;
		}
		
		//add 1 to the graph value
		public function incr():void
		{
			var oldValue:int=value;
			value++;
			if(value>maxValue)
				value=maxValue;
			//only update the sprite if the new value is different from the existing value: optimization
			if(oldValue!=value)
				updateSprite();
		}
		
		//reduce the graph value by 1
		public function decr():void
		{
			var oldValue:int=value;
			value--;
			if(value<0)
				value=0;
			//only update the sprite if the new value is different from the old value: optimization
			if(oldValue!=value)
				updateSprite();
		}
		
		//redraw the sprite to display the new value, a graph object is 200px wide, 15px high
		private function updateSprite():void
		{
			//clear the old sprite and set the line style
			bar.graphics.clear();
			bar.graphics.lineStyle(2, 0x000000);
			
			//draw the black outline of the graph
			bar.graphics.drawRoundRect(0,0,200,15,5,5);
			
			//fill the graph with enough colour to represent the current value
			bar.graphics.beginFill(fillColour);
			bar.graphics.drawRoundRect(0,0,(value/maxValue)*200,15,5,5); //scaled to the maximum amount possible (value/maxValue)*200
			bar.graphics.endFill();
		}
		
		//set the location of the graph arbitrarily in relation to its container
		public function setXY(x:Number,y:Number):void
		{
			bar.x=x;
			bar.y=y;
			updateSprite();
		}
	}
}