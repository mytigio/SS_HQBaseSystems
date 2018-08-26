Scriptname SimSettlementsHQ:HQReputationManagement extends Quest
{Reputation of the player in the game world.  Improves worker confedence in the player and adjusts the desertion threshhold (workers are willing to put up with more shit if they think they are working with someone famous/a good cause)}

;this page is very important for what we're doing here: https://www.creationkit.com/fallout4/index.php?title=QueryStat_-_Game since it is the method used to get game tracked Stats.
;this page lists the known tracked stats: https://www.creationkit.com/fallout4/index.php?title=IncrementStat_-_Game

Int Property ReputationPerMinorQuest = 10 Auto 
{Amount of reputation gained per minor quest completed.}

Int Property ReputationPerMajorQuest = 50 Auto 
{Amount of reputation gained per major quest completed.}

Int Property BaseReputation
	Function Get()
		int reputation = (Game.QueryStat("Main Quests Completed") * ReputationPerMajorQuest) + (Game.QueryStat("Side Quests Completed") * ReputationPerMinorQuest) + AcheivementReputation
	EndFunction
EndProperty

Int Property AcheivementReputation
	Function Get()
		return 0 ;later on we'll introduce various ways to add acheivement reputation by either providing extra reputation for certain types of kills, for completing quests certain ways, etc.
	EndFunction
EndProperty