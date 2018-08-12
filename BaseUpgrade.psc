Scriptname SimSettlementsHQ:BaseUpgrade extends ObjectReference Const

struct UpgradeCosts
	Int WorkshopRatingScavengeBuildingAmount
	Int WorkshopRatingScavengeGeneralAmount
	Int WorkshopRatingScavengePartsAmount
	Int WorkshopRatingScavengeRareAmount
endstruct

Message Property UpgradeInfo Auto Const Mandatory
{the message that will display for this base upgrade explaining costs and benefits.}


Bool Property AvailableToBuild Auto Const
	Bool Function Get()
		return true
	EndFunction
EndProperty

Bool Property MeetsUpgradeRequirements
	Bool Function Get()
		
	EndFunction
EndProperty


