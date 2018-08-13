Scriptname SimSettlementsHQ:HQWaterManagement extends Quest

Group ParentQuest
SimSettlementsHQ:HQManaagement Property SS_HQ_Management_Main Auto
EndGroup

Int Property CurrentStoredPristineWater Auto
{a running total of stored water.  At the end of the day some percent of stored water (if any) will become contaminated and be moved to the dirty water store.}

Float Property StoredPristineWaterQuality
  Float Function Get()
    Return 0.75 ;this should reflect the current water storage and transport mechanisms (with "nothing" being the lowest and chemical preservatives or purifiers being the best (with the side effect of increased power usage and a contant need for purifying agents)).
  EndFunction
EndProperty

Int Property CurrentStoredDirtyWater Auto
{a running total of dirty water.  At the end of the day, some percent of stored dirty water (if any) will rot and be removed entirely.}

Float Property StoredDirtyWaterQuality
  Float Function Get()
    Return Math.Max(StoredPristineWaterQuality - 0.30, 0.0)
  EndFunction
EndProperty

Int TodaysFreshWater = 0 ;how much water was produced for the current day.  Calculated and stored at the beginning of the days processing then reduced throughout the process as needed until empty.  Leftover fresh water will be placed into storage at the end of the daily processing.

Float Property FreshWaterQuality
  Float Function Get()
    Return Math.Min(StoredPristineWaterQuality + 0.20, 1.0)
  EndFunction
EndProperty

Float Property PercentStoredWaterToDirty
  Float Function Get()
    Return 0.20 ;leaving this as a property so I can update the logic later to be based on the storage system installed on the base.  For initial testing we'll just mock it out to 20%.  Fresh and dirty water will be modified up or down based on this basic score.
  EndFunction
EndProperty

;Calculates new water daily.  This can be obtained in several ways: via trade from the commonwealth (requires caravan workers or similar?), production from settlements with supply trains to HQ (special plot in the settlements?), provided by Player (donation box), or grown in HQ (very limited until Water Paste is provided?)
Int Function CalculateNewWater()
  return 10 ;currently stubbed out to just provide a flat 10, but this should be calculated based on the various water sources as the HQ system develops.
EndFunction

;Water is consumed in the following order and has effects as the water consumtion progresses through the stages.  Normally a worker consumes 1 water, but I'm building this to allow for multiple water units to be consumed at a time for flexibility:
;1) Water is consumed from Prestine Stored Water.  The maximum amount and quality of stored water is dependant on preservation methods (boiling, chemical additives to reduce bacterial growth & lead plumbing or plastic plumbing). Due to basic rotation practices, stored water is consumed first and fresh water added to the storage tanks.
;2) Water is consumed from New Water (Fresh Water).  If this happens, flag a bool to indicate that we don't have enough water reserves to handle an emergency. Water quality is increased a small amount however, which is nice
;3) Water is consumed from Dirty Stored Water.  This is water that is beyond the point of good consumtion (grey water from showers, planters, etc).  Dipping into this reserve will result in severe reduction in water quality for this NPC and a severe decrease in cleanliness (drinking dirty water is a quick way to get sick).
;4) No water.  At this level we are hand-waving a bit.  There is no potable water left, so NPCs at this point are either going thirsty or drinking contaminated water. Water quality of 0 which will also result in a huge morale penalty to this NPC and large penalties to cleanliness and health.
;Returns: the quality (from 0 to 1) of the water consumed, this is calculated as the average for the base water and then modified by freshness.
float Function ConsumeWater(int amountToConsume = 1)
  float avgQualityConsumed = 0;
  int waterToProvide = amountToConsume

  ;first we serve Stored water.
  if waterToProvide > CurrentStoredPristineWater
    avgQualityConsumed = CurrentStoredPristineWater * StoredPristineWaterQuality
    waterToProvide -= CurrentStoredPristineWater ;deduct however much stored water we have left.
    CurrentStoredPristineWater = 0 ;consumed all the good stored water.
  else
    avgQualityConsumed = waterToProvide * StoredPristineWaterQuality
    CurrentStoredPristineWater -= waterToProvide
    waterToProvide = 0 ;all necessary water provided.
  endif

  ;if the NPC is still needs water, dip into fresh deliveries for the day if any.
  if waterToProvide > 0 && TodaysFreshWater > 0
    if waterToProvide > TodaysFreshWater
      avgQualityConsumed += (TodaysFreshWater * FreshWaterQuality)
      waterToProvide -= TodaysFreshWater; deduct however much fresh water we have left.
      TodaysFreshWater = 0 ;consumed all the fresh water.
    else
      avgQualityConsumed += (waterToProvide * FreshWaterQuality)
      TodaysFreshWater -= waterToProvide
      waterToProvide = 0 ;all necessary water provided.
    endif
  endif

  ;if the NPC still needs water, dip into the dirty water. Yuk.
  if waterToProvide > 0 && CurrentStoredDirtyWater > 0
    if waterToProvide > CurrentStoredDirtyWater
      avgQualityConsumed = avgQualityConsumed + (CurrentStoredDirtyWater * StoredDirtyWaterQuality)
      waterToProvide -= CurrentStoredDirtyWater; deduct however much dirty water we have left.
      CurrentStoredDirtyWater = 0 ;consumed all the shitty stored water.
    else
      avgQualityConsumed += (waterToProvide * StoredDirtyWaterQuality)
      CurrentStoredDirtyWater -= waterToProvide
      waterToProvide = 0 ;all necessary water provided.
    endif
  endif

  ;finally, we're out of water completely. Egads! Nothing to actually calculate here, so just calculate the final average quality and return.  If there was no water, this will be 0, which is bad.
  return (avgQualityConsumed / amountToConsume)
EndFunction

Function DailyUpkeep(SimSettlementsHQ:HQWorkerManagement workerManagementQuest)
  ;calculate new water for the day.
  TodaysFreshWater = CalculateNewWater()

  ;trigger water consumption by workers.
  workerManagementQuest.WaterWorkers(self)

  ;spoil or stored water.
  ;1) first rot water from the dirty water list.
  ;2) then calculate the amount of stored water to spoil.
  ;3) finally move as much water as possible (up to the calculated amount) from the prestine to the dirty category
  int waterToContaminate = Math.Floor(CurrentStoredPristineWater * PercentStoredWaterToDirty)
  CurrentStoredDirtyWater -= Math.Min(waterToContaminate,CurrentStoredDirtyWater) As Int
  int dirtyWater = Math.Min(CurrentStoredPristineWater,waterToContaminate) As Int
  CurrentStoredPristineWater -= dirtyWater
  CurrentStoredDirtyWater += dirtyWater

  ;finally, if there is any fresh water left, move it into the storedprestine water grouping.
  CurrentStoredPristineWater += TodaysFreshWater
EndFunction