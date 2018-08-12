Scriptname SimSettlementsHQ:HQFoodManagement extends Quest

Group ParentQuest
SimSettlementsHQ:HQManaagement Property SS_HQ_Management_Main Auto
EndGroup

Int Property CurrentStoredPristineFood Auto
{a running total of stored food.  At the end of the day some percent of stored food (if any) will spoil and be moved to the spoiled food store.}

Float Property StoredPristineFoodQuality
  Float Function Get()
    Return 0.75 ;this should reflect the current food storage mechanisms (with "nothing" being the lowest and chemical preservatives being the best (with the side effect of reduced average health)) modified by the cooks skill and recipie quality.
  EndFunction
EndProperty

Int Property CurrentStoredSpoiledFood Auto
{a running total of spoiled food.  At the end of the day, some percent of stored spoiled food (if any) will rot and be removed entirely.}

Float Property StoredSpoilingFoodQuality
  Float Function Get()
    Return Math.Max(StoredPristineFoodQuality - 0.30, 0.0)
  EndFunction
EndProperty

Int TodaysFreshFood = 0 ;how much food was produced for the current day.  Calculated and stored at the beginning of the days processing then reduced throughout the process as needed until empty.  Leftover fresh food will be placed into storage at the end of the daily processing.

Float Property FreshFoodQuality
  Float Function Get()
    Return Math.Min(StoredPristineFoodQuality + 0.20, 1.0)
  EndFunction
EndProperty

Float Property PercentStoredFoodToSpoil
  Float Function Get()
    Return 0.20 ;leaving this as a property so I can update the logic later to be based on the storage system installed on the base.  For initial testing we'll just mock it out to 20%.  Fresh and spoiled food will be modified up or down based on this basic score.
  EndFunction
EndProperty

;Calculates new food daily.  This can be obtained in several ways: via trade from the commonwealth (requires caravan workers or similar?), production from settlements with supply trains to HQ (special plot in the settlements?), provided by Player (donation box), or grown in HQ (very limited until Food Paste is provided?)
Int Function CalculateNewFood()
  return 10 ;currently stubbed out to just provide a flat 10, but this should be calculated based on the various food sources as the HQ system develops.
EndFunction

;Food is consumed in the following order and has effects as the food consumtion progresses through the stages.  Normally a worker consumes 1 food, but I'm building this to allow for multiple food units to be consumed at a time for flexibility:
;1) Food is consumed from Prestine Stored Food.  The maximum amount and quality of stored food is dependant on preservation methods (pickling, salting, refridgeration, preservatives, etc). Due to basic rotation practices, stored food is consumed first.
;2) Food is consumed from New Food (Fresh Food).  If this happens, flag a bool to indicate that we don't have enough food reserves to handle an emergency. Food quality is increased a small amount however.
;3) Food is consumed from Spoiling Stored Food.  This is food that is beyond the point of good consumtion (not rotten yet, but on the verge).  Dipping into this reserve will result in severe reduction in food quality for this NPC.
;4) Rotten or no food.  At this level we are hand-waving a bit.  There is no editable food left, so NPCs at this point are either going hungry or eating rotten food. Food quality of 0 which will also result in a huge morale penalty to this NPC.
;Returns: the quality (from 0 to 1) of the food consumed, this is calculated as the average for the base food and then modified by freshness.
float Function ConsumeFood(int amountToConsume = 1)
  float avgQualityConsumed = 0;
  int foodToProvide = amountToConsume

  ;first we serve Stored food.
  if foodToProvide > CurrentStoredPristineFood
    avgQualityConsumed = CurrentStoredPristineFood * StoredPristineFoodQuality
    foodToProvide -= CurrentStoredPristineFood ;deduct however much stored food we have left.
    CurrentStoredPristineFood = 0 ;consumed all the good stored food.
  else
    avgQualityConsumed = foodToProvide * StoredPristineFoodQuality
    CurrentStoredPristineFood -= foodToProvide
    foodToProvide = 0 ;all necessary food provided.
  endif

  ;if the NPC is still needs food, dip into fresh deliveries for the day if any.
  if foodToProvide > 0 && TodaysFreshFood > 0
    if foodToProvide > TodaysFreshFood
      avgQualityConsumed += (TodaysFreshFood * FreshFoodQuality)
      foodToProvide -= TodaysFreshFood; deduct however much fresh food we have left.
      TodaysFreshFood = 0 ;consumed all the fresh food.
    else
      avgQualityConsumed += (foodToProvide * FreshFoodQuality)
      TodaysFreshFood -= foodToProvide
      foodToProvide = 0 ;all necessary food provided.
    endif
  endif

  ;if the NPC still needs food, dip into the spoiling food. Yuk.
  if foodToProvide > 0 && CurrentStoredSpoiledFood > 0
    if foodToProvide > CurrentStoredSpoiledFood
      avgQualityConsumed = avgQualityConsumed + (CurrentStoredSpoiledFood * StoredSpoilingFoodQuality)
      foodToProvide -= CurrentStoredSpoiledFood; deduct however much spoiling food we have left.
      CurrentStoredSpoiledFood = 0 ;consumed all the shitty stored food.
    else
      avgQualityConsumed += (foodToProvide * StoredSpoilingFoodQuality)
      CurrentStoredSpoiledFood -= foodToProvide
      foodToProvide = 0 ;all necessary food provided.
    endif
  endif

  ;finally, we're out of food completely. Egads! Nothing to actually calculate here, so just calculate the final average quality and return.  If there was no food, this will be 0, which is bad.
  return (avgQualityConsumed / amountToConsume)
EndFunction

Function DailyUpkeep(SimSettlementsHQ:HQWorkerManagement workerManagementQuest)
  ;calculate new food for the day.
  TodaysFreshFood = CalculateNewFood()

  ;trigger food consumption by workers.
  workerManagementQuest.FeedWorkers(self)

  ;spoil or stored food.
  ;1) first rot food from the spoiled food list.
  ;2) then calculate the amount of stored food to spoil.
  ;3) finally move as much food as possible (up to the calculated amount) from the prestine to the spoiled category
  int foodToSpoil = Math.Floor(CurrentStoredPristineFood * PercentStoredFoodToSpoil)
  CurrentStoredSpoiledFood -= Math.Min(foodToSpoil,CurrentStoredSpoiledFood) As Int
  int spoiledFood = Math.Min(CurrentStoredPristineFood,foodToSpoil) As Int
  CurrentStoredPristineFood -= spoiledFood
  CurrentStoredSpoiledFood += spoiledFood

  ;finally, if there is any fresh food left, move it into the storedprestine food grouping.
  CurrentStoredPristineFood += TodaysFreshFood
EndFunction
