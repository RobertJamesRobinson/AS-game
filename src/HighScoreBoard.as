package
{
	public class HighScoreBoard
	{
		protected var highScoreNames:Array;
		protected var highScoreScores:Array;
		protected var highScoreLevels:Array;
		protected var listLength:int;
		
		//constructor, this class stores a high score board and implements an insertion sort (of sorts) to add new high scores
		//max number of people allowed on the list is given by num.
		public function HighScoreBoard(num:int)
		{
			highScoreNames=new Array(num);
			highScoreScores=new Array(num);
			highScoreLevels=new Array(num);
			listLength=num;
			
			for(var i:int;i<listLength;i++)
			{
				highScoreNames[i]=new String();
				highScoreScores[i]=0;
				highScoreLevels[i]=0;
			}
		}
		
		//add a new high score to the list
		public function addScore(name:String,score:int,level:int):void
		{
			var placeInList:int=0;
			var found:Boolean=false;
			
			var oldName:String;
			var oldScore:int;
			var oldLevel:int;
			
			//find the place in the list for the new score
			for (var i:int=0;i<listLength;i++)
			{
				if(score>highScoreScores[i]&&!found)
				{
					placeInList=i;
					found=true;
				}
			}
			//if a place for the new score is found, bubble the rest of the scores down one then enter the score
			if(found)
			{
				//shuffle old scores down 1, dropping last one off list (just overwriting it)
				for (i=listLength-1;i>=placeInList+1;i--)
				{
					highScoreNames[i]=highScoreNames[i-1];
					highScoreScores[i]=highScoreScores[i-1];
					highScoreLevels[i]=highScoreLevels[i-1];
				}
				//insert new score
				highScoreNames[placeInList]=name;
				highScoreScores[placeInList]=score;
				highScoreLevels[placeInList]=level;
			}
			//obviously if a place is not found then the new highscore isn't good enough to get on the board = you suck and it ain't goin on there
		}
		
		//return the name at a certain index in the highscore list
		public function getNameAt(index:int):String
		{
			return highScoreNames[index];
		}
		
		//return the score at a certain index in the highscore list
		public function getScoreAt(index:int):int
		{
			return highScoreScores[index];
		}
		
		//return the level attained at a certain index in the high score list
		public function getLevelAt(index:int):int
		{
			return highScoreLevels[index];
		}
	}
}