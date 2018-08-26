Scriptname SimSettlementsHQ:HQReputationManagement extends Quest
{Reputation of the player in the game world.  Improves worker confedence in the player and adjusts the desertion threshhold (workers are willing to put up with more shit if they think they are working with someone famous/a good cause)}

;this page is very important for what we're doing here: https://www.creationkit.com/fallout4/index.php?title=QueryStat_-_Game since it is the method used to get game tracked Stats.
;this page lists the known tracked stats: https://www.creationkit.com/fallout4/index.php?title=IncrementStat_-_Game

Int Property ReputationPerMinorQuest = 1 Auto 
{Amount of reputation gained per minor quest completed.}

Int Property ReputationPerMajorQuest = 5 Auto 
{Amount of reputation gained per major quest completed.}

Int Property ReputationPerFactionQuest = 1 Auto 
{The amount of faction experience you get per faction quest completed. Does not add to Base Reputation.}

Int Property BOSFaction = 1 Auto Const
{Do not change. Used as a reference only.}
Int Property InstituteFaction = 2 Auto Const
{Do not change. Used as a reference only.}
Int Property RailRoadFaction = 3 Auto Const
{Do not change. Used as a reference only.}
Int Property MinutemenFaction = 4 Auto Const
{Do not change. Used as a reference only.}
Int Property SSCustomFaction = 5 Auto Const
{Do not change. Used as a reference only.}


Int Property BaseReputation
	Int Function Get()
		int reputation = (Game.QueryStat("Main Quests Completed") * ReputationPerMajorQuest) + (Game.QueryStat("Side Quests Completed") * ReputationPerMinorQuest) + AcheivementReputation + QuestReputation
	EndFunction
EndProperty

Int Property AcheivementReputation
	Int Function Get()
		return 0 ;later on we'll introduce various ways to add acheivement reputation by either providing extra reputation for certain types of kills, for completing quests certain ways, etc.
	EndFunction
EndProperty

Int Property QuestReputation
	Int Function Get()
		return 0 ;later on we'll introduce methods for quest stages, etc and associated reputation changes.
	EndFunction
EndProperty

Int Function GetBOSReputation()
	return GetFactionReputation(BOSFaction)
EndFunction

Int Function GetInstituteReputation()
	return GetFactionReputation(InstituteFaction)
EndFunction

Int Function GetRailroadReputation()
	return GetFactionReputation(RailRoadFaction)
EndFunction

Int Function GetMinutemenReputation()
	return GetFactionReputation(MinutemenFaction)
EndFunction

Int Function GetFactionReputation(int factionNumber)
	if (factionNumber == BOSFaction)
		return (Game.QueryStat("Brotherhood of Steel Quests Completed") * ReputationPerFactionQuest)
	elseif (factionNumber == InstituteFaction)
		return (Game.QueryStat("Institute Quests Completed") * ReputationPerFactionQuest)
	elseif (factionNumber == RailRoadFaction)
		return (Game.QueryStat("Railroad Quests Completed") * ReputationPerFactionQuest)
	elseif (factionNumber == MinutemenFaction)
		return (Game.QueryStat("Minutemen Quests Completed") * ReputationPerFactionQuest)
	elseif (factionNumber == SSCustomFaction)
		return BaseReputation ;for now your base reputation is your custom faction reputation.  We might want to create a stat to track that will contain the completed custom faction quests.
	else
		return 0
	endif	
EndFunction