Scriptname SimSettlementsHQ:WorkerContainer extends ObjectReference

SimSettlementsHQ:HQWorkerManagement:worker[] Property Workers Auto

Int Property BaseFoodMoraleAdjustment = 200 AutoReadOnly
Int Property BaseWaterMoraleAdjustment = 200 AutoReadOnly
Int Property BaseWaterCleanlinessAdjustment = 100 AutoReadOnly
Int Property BaseWaterHealthAdjustment = 50 AutoReadOnly

ActorValue Property FoodPickinessAV Auto
ActorValue Property WaterPickinessAV Auto

Bool Property IsFull
  Bool Function Get()
    return Workers.Length == 128
  EndFunction
EndProperty

Function Initialize()
  Workers = new SimSettlementsHQ:HQWorkerManagement:worker[0]
EndFunction

bool Function AddActor(Actor actorToAdd)
  if !workers
    Initialize()
  endif

  SimSettlementsHQ:HQWorkerManagement:worker newWorker = new SimSettlementsHQ:HQWorkerManagement:worker
  newWorker.NPC = actorToAdd
  if(!IsFull)
    Workers.Add(newWorker)
    return true
  else
    return false
  endif
EndFunction

Function FeedWorkers(SimSettlementsHQ:HQFoodManagement foodMgtQuest)
  int index = 0
  while index < Workers.Length
    float foodQualityEaten = foodMgtQuest.ConsumeFood(DetermineDailyConsumedFoodForWorker(Workers[index].NPC))
    int moraleAdjustment = CalculateMoraleAdjustmentForFood(index, foodQualityEaten)
	Workers[index].Morale += moraleAdjustment
    index += 1
  endwhile
EndFunction

Function WaterWorkers(SimSettlementsHQ:HQWaterManagement mgtQuest)
  int index = 0
  while index < Workers.Length
    float quality = mgtQuest.ConsumeWater(DetermineDailyConsumedWaterForWorker(Workers[index].NPC))
    int moraleAdjustment = CalculateMoraleAdjustmentForFood(index, quality)
	
	;adjust morale directly based on water quality.
	Workers[index].Morale += moraleAdjustment
	
	
	;now check for a hit to cleanliness.  Cleanliness hits will just adjust the cleanliness itself, we'll deal with the impact on morale from low cleanliness in that section.
	int CleanlinessAdjustment = CalculateCleanlinessAdjustmentForWater(index, quality, mgtQuest)
	
	Workers[index].Cleanliness -= CleanlinessAdjustment
	
	;finally we check if there was no water or the water was non-poteable.  At this level there is a direct hit to health. Again we only deal with damaging the NPCs health, not the other impacts that damage might have.
	int HealthAdjustment = CalculateHealthAdjustmentForWater(index, quality, mgtQuest)
	Workers[index].GeneralHealth -= HealthAdjustment
	
    index += 1
  endwhile
EndFunction

int Function DetermineDailyConsumedFoodForWorker(Actor worker)
  return 1 ;right now we just return 1. Later on we can check the Actor for the hunger increasing perk or high levels of training that will make them demand more food.
endFunction

int Function DetermineDailyConsumedWaterForWorker(Actor worker)
  return 1 ;right now we just return 1. Later on we can check the Actor for the thirst increasing perk or high levels of training that will make them demand more water.
endFunction

float Function GetActorFoodPickiness(SimSettlementsHQ:HQWorkerManagement:worker thisWorker)
  float value = thisWorker.FoodPickinessValue
  if !value
    value = 0.5 ;default food pickiness is 0.5  If the actor doesn't have a food pickiness AV, just use .5.  Later we can update this function to call back to the worker management script and roll the AV if needed.
  endif
  return value
EndFunction

float Function GetActorWaterPickiness(SimSettlementsHQ:HQWorkerManagement:worker thisWorker)
  float value = thisWorker.WaterPickinessValue
  if !value
    value = 0.5 ;default food pickiness is 0.5  If the actor doesn't have a water pickiness AV, just use .5.  Later we can update this function to call back to the worker management script and roll the AV if needed.
  endif
  return value
EndFunction

int Function CalculateMoraleAdjustmentForFood(int index, float foodQuality)
  return Math.Floor(BaseFoodMoraleAdjustment * (foodQuality * GetActorFoodPickiness(Workers[index]))) ;pickier workers gain less from high quality food (it's more "base-line" and lose more morale for low quality food (it's even further below their standard for good).
Endfunction

int Function CalculateMoraleAdjustmentForWater(int index, float waterQuality)
  return Math.Floor(BaseWaterMoraleAdjustment * (waterQuality * GetActorWaterPickiness(Workers[index]))) ;pickier workers gain less from high quality water (it's more "base-line" and lose more morale for low quality water (it's even further below their standard for good).
EndFunction

int Function CalculateCleanlinessAdjustmentForWater(int index, float waterQuality, SimSettlementsHQ:HQWaterManagement mgtQuest)
	int CleanlinessHit = 0
	
	if(waterQuality <= mgtQuest.StoredDirtyWaterQuality)
		;the water is dirty water or lower, calculate the impact on cleanliness.  The dirtier the water, the bigger the impact.
		CleanlinessHit = Math.Floor(BaseWaterCleanlinessAdjustment - BaseWaterCleanlinessAdjustment * waterQuality)
	endif
	
	return CleanlinessHit
EndFunction

int Function CalculateHealthAdjustmentForWater(int index, float waterQuality, SimSettlementsHQ:HQWaterManagement mgtQuest)
	int HealthHit = 0
	
	if(waterQuality <= (mgtQuest.StoredDirtyWaterQuality / 2.0))
		;water was half the dirty score or less, calculate the impact on health.  The dirtier the water, the bigger the impact.
		HealthHit = Math.Floor(BaseWaterHealthAdjustment - BaseWaterHealthAdjustment * waterQuality)
	endif
	
	return HealthHit
EndFunction
