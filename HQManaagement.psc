Scriptname SimSettlementsHQ:HQManaagement extends Quest
Group ChildManagementQuests
  SimSettlementsHQ:HQFoodManagement Property SS_HQ_Management_Food Auto Mandatory
  SimSettlementsHQ:HQWaterManagement Property SS_HQ_Management_Water Auto Mandatory
  SimSettlementsHQ:HQMoraleManagement Property SS_HQ_Management_Morale Auto Mandatory
  SimSettlementsHQ:HQReputationManagement Property SS_HQ_Management_Reputation Auto Mandatory
  SimSettlementsHQ:HQWorkerManagement Property SS_HQ_Management_Workers Auto Mandatory
EndGroup

Group GeneralHelperReferences
  WorkshopParentScript Property WorkshopParent Auto
  ActorValue[] Property Specials Auto
EndGroup

Group FoodStorage
  ;The amount of fresh food in storage.  Used to handle shortfalls, sudden spikes or losses from quests, attacks or upgrades, etc.  Can be purchased from the commonwealth, shipped in from settlements or brought by the player. Food is consumed from storage first, then if more food is needed is taken from incoming food, if more is needed it is taken from spoiling food (below).  Once all workers are fed, if any food is left in storage, rot is applied and moved to spoiling, then finally remaining ;new food is added to storage.
  Int Property StoredPristineFood
    Int Function Get()      
		if SS_HQ_Management_Food.CurrentStoredPristineFood
		  return SS_HQ_Management_Food.CurrentStoredPristineFood
		else
		  return 0
		endif      
    EndFunction
  EndProperty


  ;The amount of spoiling food in storage.  When rot is applying, it will delete food from spoiling food if any remains after feeding workers but before adding new spoilage from fresh food.  If spoiled food stores are used, a morale penalty is applied.
  Int Property StoredSpoilingFood
    Int Function Get()
      if SS_HQ_Management_Food
        if SS_HQ_Management_Food.CurrentStoredSpoiledFood
          return SS_HQ_Management_Food.CurrentStoredSpoiledFood
        else
          return 0
        endif
      endif
    EndFunction
  EndProperty
EndGroup

Group WaterStorage
  Int Property StoredCleanWater Auto
  {The amount of clean water in storage.  Used to handle shortfalls, sudden spikes or losses from quests, attacks or upgrades, etc. Can be purchased from the commonwealth, purified from dirty water storage, or shipped in from settlements.}
  Int Property StoredDirtyWater Auto
  {The amount of dirty water in storage.  Clean water becomes dirty over time as it is contaminated.  The amount of clean water that becomes contaminated each day is reduced as better water storage and transport methods are found.  Dirty water can also be purified back into clean water with purification methods.  If clean water is insufficient to meet HQ needs, dirty water will be used at a morale penalty.}
EndGroup

Group ConflictScores
  Int Property DefenseScore Auto
  {Calculated from upgrades on the base and worker specializations into this total defense score. Used to reduce chance of attacks if greater then tech score and reputation.}
  Int Property EspionageScore Auto
  {Calculated from upgrades on the base and worker specializations into this total defense score. Used to send spies into Institute, BoS and Railroad operations and gather intel or steal research and tech.}
EndGroup

Group SocialScores
  Int Property CurrentMorale Auto
  {Calculated each day by averaging out the morale of all individual workers in HQ.}
  Int Property CurrentReputation Auto
  {How well-known throughout the commonwealth you are.  As more quests are completed, add reputation.  Calculated based on number of main quests and side quests completed (per the stats page), number of dungeons cleared and workshops unlocked.}
EndGroup

Group StaticReferences
	ObjectReference Property StorageCellXMarker Auto Const
EndGroup
