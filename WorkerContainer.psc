Scriptname SimSettlementsHQ:WorkerContainer extends ObjectReference

SimSettlementsHQ:HQWorkerManagement:worker[] Property Workers Auto

Int Property BaseFoodMoraleAdjustment = 200 AutoReadOnly
ActorValue Property FoodPickinessAV Auto

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
    float foodQualityEaten = mgtQuest.ConsumeWater(DetermineDailyConsumedFoodForWorker(Workers[index].NPC))
    int moraleAdjustment = CalculateMoraleAdjustmentForFood(index, foodQualityEaten)
	Workers[index].Morale += moraleAdjustment
    index += 1
  endwhile
EndFunction

int Function DetermineDailyConsumedFoodForWorker(Actor worker)
  return 1
endFunction

float Function GetActorFoodPickiness(SimSettlementsHQ:HQWorkerManagement:worker thisWorker)
  float value = thisWorker.FoodPickinessValue
  if !value
    value = 0.5 ;default food pickiness is 0.5  If the actor doesn't have a food pickiness AV, just use .5.  Later we can update this function to call back to the worker management script and roll the AV if needed.
  endif
  return value
EndFunction

int Function CalculateMoraleAdjustmentForFood(int index, float foodQuality)
  return Math.Floor(BaseFoodMoraleAdjustment * (foodQuality * GetActorFoodPickiness(Workers[index]))) ;pickier workers gain less from high quality food (it's more "base-line" and lose more morale for low quality food (it's even further below their standard for good).
Endfunction
