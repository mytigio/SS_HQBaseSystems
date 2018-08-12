Scriptname SimSettlementsHQ:HQWorkerManagement extends Quest

struct worker
  ;the actual actor this worker represents.
  Actor NPC
  
  ;The personality profile.  Copied over from the Actor when he is first added to HQ.
  float FoodPickinessValue = 0.5 ;defaults to 0.5.  How large the impact from food quality related losses and gains to morale is.  A pickier person gaines more from high quality food and and losses more from low quality food.
  float WaterPickinessValue = 0.5 ;defaults to 0.5.  How large the impact from water quality related losses and gains to morale is.  A pickier person gaines more from high quality water and and losses more from low quality water.
  float CleanlinessPickinessValue = 0.5 ;default to 0.5.  How large the impact from cleanliness related losses and gains to morale is.  A pickier person gains more from high cleanliness and losses more from low cleanliness.
  
  float LoyaltyLevel = 0.5 ;defaults to 0.2.  The characters loyalty level.  More loyal characters will take more shit (sustain a lower morale) before deserting HQ or defecting/sabatoging the base.
  float Morale = 0.0 ;the current total morale for this worker.  Accumulates over time. Consider breaking into multiple values
  float GeneralHealth = 0.0 ;the current health level for this worker.  If it's at or above the base health value (determiend by endurance), the worker is at full or improved productivity.  If it is below the base health value, the worker will be at reduced productivity
endStruct

Group ParentQuest
SimSettlementsHQ:HQManaagement Property SS_HQ_Management_Main Auto
EndGroup

;by having an array of workerContainers we can have up to 128^2 (16,384) workers at HQ.  We shouldn't ever need that many of course, but in theory we may be able to create off-screen "workers" or something as well, so this should accomidate our upperbound fairly well.  
;If we find we need more then 16,384 however, we'll need to either build a container of containers of workers or manually manage multple arrays of workerContainers.  New workerContainers will be spawned as needed in a holding Cell.
SimSettlementsHQ:WorkerContainer[] workerContainers


Function Initialize()
  workerContainers = new SimSettlementsHQ:WorkerContainer[0]
EndFunction

;we pass the mangement quest from the calling script.  This should make testing easier since we could extend the normal management quest with a stubbed out version for simpler testing.
Function FeedWorkers(SimSettlementsHQ:HQFoodManagement foodMgtQuest)
  int index = 0
  while index < workerContainers.Length
    workerContainers[index].FeedWorkers(foodMgtQuest)
    index += 1
  endwhile
EndFunction

;we pass the mangement quest to use from the calling script.  This should make testing easier since we could extend the normal management quest with a stubbed out version for simpler testing.
Function WaterWorkers(SimSettlementsHQ:HQWaterManagement waterMgtQuest)
	int index = 0
	while index < workerContainers.Length
		workerContainers[index].WaterWorkers(waterMgtQuest)
		index += 1
	endwhile
EndFunction

Function AddToHQ(Actor actorToAdd, WorkshopScript arrivingFrom)
  if IsActorWorthyOfHQ(actorToAdd)
    AcceptWorker(actorToAdd)
  else
    RejectWorker(actorToAdd, arrivingFrom)
  endif
Endfunction

Int Property MinimumSpecialScore = 20 AutoReadOnly
Int Property IndividualQualifyingSpecialScore = 8 AutoReadOnly

Bool Function IsActorWorthyOfHQ(Actor actorToAdd)
  float[] SPECIALScores = new float[7]

  float totalSpecialScore = 0.0
  bool hasSpecialOverEight = false

  int index = 0
  while index < SPECIALScores.Length
	;probably makes sense to replace this specials array with a common one from the Training quest or somewhere else in SS just so we don't have multiple copies.
    SPECIALScores[index] = actorToAdd.GetBaseValue(SS_HQ_Management_Main.Specials[index])
    if SPECIALScores[index] > IndividualQualifyingSpecialScore
      hasSpecialOverEight = true
    endif
    totalSpecialScore += SPECIALScores[index]
    index += 1
  endwhile

  return (hasSpecialOverEight || (totalSpecialScore >= MinimumSpecialScore))
EndFunction

Function AcceptWorker(Actor actorToAdd)
  SimSettlementsHQ:WorkerContainer containerForActor = GetUnfilledContainer()
  containerForActor.AddActor(actorToAdd)
EndFunction

Function RejectWorker(Actor actorToReject, WorkshopScript returnTo)
  SS_HQ_Management_Main.WorkshopParent.AddActorToWorkshop(actorToReject as WorkshopNPCScript, returnTo)
EndFunction

SimSettlementsHQ:Workercontainer Function GetUnfilledContainer()
  int index = 0
  int indexOfFoundContainer = -1
  while index < workerContainers.Length && indexOfFoundContainer < 0
    if workerContainers[index].IsFull == false
		indexOfFoundContainer = index      
    endif
    index += 1
  endwhile
  
  ;spawn a new container of workers and add this worker to it.
  if indexOfFoundContainer == -1
	workerContainers.Add(CreateNewWorkerContainer())
	indexOfFoundContainer += 1
  endif
  
  return workerContainers[indexOfFoundContainer]
  
EndFunction

SimSettlementsHQ:Workercontainer Function CreateNewWorkerContainer()
	;HQManagement.
EndFunction
